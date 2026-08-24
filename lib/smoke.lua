-- SPDX-FileCopyrightText: 2026 Kartoza (Pty) Ltd <tim@kartoza.com>
-- SPDX-License-Identifier: MIT
--
-- Headless startup smoke test. Run by `nix flake check` via checks.smoke:
--   SMOKE_REPORT=out.txt nvim --headless -c 'luafile lib/smoke.lua' +qa
--
-- Every previous startup bug in timvim (a broken `<cmd>` mapping, a
-- `require("cmp")` in a blink-cmp config, an alpha/session-manager race that
-- produced an intermittent blank dashboard) failed *silently* at runtime: the
-- Nix build succeeded because the config evaluated, and the Lua only blew up
-- once a real editor session hit that code path. This test starts the fully
-- built editor, fires the startup autocmds, and turns any Lua error raised
-- during startup into a build failure.

local report = {}
local function log(line)
  report[#report + 1] = line
end

-- Errors raised inside scheduled callbacks and autocmds do not propagate to
-- the caller -- they land in :messages. Capture both routes.
local raised = {}
local orig_notify = vim.notify
vim.notify = function(msg, level, opts)
  if level == vim.log.levels.ERROR and type(msg) == "string" then
    raised[#raised + 1] = msg
  end
  return orig_notify(msg, level, opts)
end

-- Fire the startup autocmds. These are the ones that actually race: session
-- restore, the alpha dashboard, and the colorscheme application.
local ok, err = pcall(vim.api.nvim_exec_autocmds, "VimEnter", {})
if not ok then
  raised[#raised + 1] = "VimEnter: " .. tostring(err)
end

-- Let deferred work (vim.schedule / vim.defer_fn) actually run before we look.
vim.wait(2000, function()
  return false
end)

-- Scrape :messages for errors that never came through vim.notify.
local msgs = ""
local mok, mres = pcall(vim.api.nvim_exec2, "messages", { output = true })
if mok and type(mres) == "table" then
  msgs = mres.output or ""
end

-- Fatal: these mean something actually failed to run.
--
-- Deliberately NOT matching a bare "stack traceback" -- vim.deprecate() prints
-- one with every deprecation warning, which is noise, not failure. Match the
-- error markers themselves.
local fatal_patterns = {
  "E5108", -- Error executing lua
  "E5113", -- Error in Lua chunk (what a throwing plugin setup() produces)
  "E492", -- Not an editor command
  "Error executing",
  "Error detected while processing",
  "attempt to index",
  "attempt to call",
  "module '[^']*' not found",
}

-- Non-fatal but worth surfacing: APIs on their way out. Reported, not failed,
-- so a nixpkgs bump that deprecates something does not block the build.
local deprecations = {}

for _, line in ipairs(vim.split(msgs, "\n", { trimempty = true })) do
  local matched = false
  for _, pat in ipairs(fatal_patterns) do
    if line:match(pat) then
      raised[#raised + 1] = line
      matched = true
      break
    end
  end
  if not matched and (line:match("[Dd]eprecated") or line:match("will be removed")) then
    deprecations[#deprecations + 1] = line
  end
end

-- Sanity assertions about the state a healthy startup must reach. These are
-- the invariants the black-screen bug violated.
if vim.g.colors_name ~= "kartoza" then
  raised[#raised + 1] = "colorscheme not applied: g:colors_name = " .. tostring(vim.g.colors_name)
end

local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
if not (normal and normal.bg) then
  raised[#raised + 1] = "Normal highlight group has no background (screen would render bare)"
end

for _, group in ipairs({ "Pmenu", "StatusLineNC", "EndOfBuffer", "Folded", "SignColumn" }) do
  local hl = vim.api.nvim_get_hl(0, { name = group })
  if not hl or vim.tbl_isempty(hl) then
    raised[#raised + 1] = "highlight group cleared and never restored: " .. group
  end
end

log("timvim smoke test")
log("nvim: " .. tostring(vim.version()))
log("colorscheme: " .. tostring(vim.g.colors_name))
log("errors: " .. #raised)
for _, e in ipairs(raised) do
  log("  ERROR " .. e)
end
log("deprecations: " .. #deprecations)
for _, d in ipairs(deprecations) do
  log("  WARN  " .. d)
end

local path = vim.env.SMOKE_REPORT
if path then
  local f = io.open(path, "w")
  if f then
    f:write(table.concat(report, "\n") .. "\n")
    f:close()
  end
end

for _, line in ipairs(report) do
  io.stderr:write(line .. "\n")
end

if #raised > 0 then
  vim.cmd("cquit 1")
end
