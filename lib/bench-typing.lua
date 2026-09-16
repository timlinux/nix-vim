-- SPDX-FileCopyrightText: 2026 Kartoza (Pty) Ltd <tim@kartoza.com>
-- SPDX-License-Identifier: MIT
--
-- Typing-latency benchmark. Run by lib/bench_record.py via:
--   BENCH_SCENARIO=code BENCH_FILE=... BENCH_REPORT=... nvim --headless \
--     -c 'luafile lib/bench-typing.lua' +qa
--
-- Simulates a human typing a document into the *built* editor and records
-- how long each keystroke takes to process -- the time between a key being
-- available and the editor being ready for the next one, which is what a
-- human actually feels as "typing lag".
--
-- This has to feed a whole phase (all of insert mode, start to Escape) as
-- ONE `nvim_feedkeys(..., 'x', ...)` call, not one call per character.
-- Insert mode is implemented as its own nested input loop in Nvim's core
-- (it does not return control until Escape), so a headless run with no UI
-- attached and no more queued input blocks forever trying to read the
-- *next* character from stdin the moment typeahead runs dry mid-insert --
-- there is no "process one keystroke and hand control back" outside of
-- Escape. Per-keystroke timing instead comes from `vim.on_key()`, a
-- listener invoked synchronously for every key as Nvim's core processes
-- it, so it fires once per character even while one big feedkeys call
-- drives the whole phase.
--
-- Debounced/async work (LSP round-trips, timers) intentionally falls
-- outside what this measures, same as it falls outside what a typing human
-- notices keystroke-to-keystroke.

local scenario_name = vim.env.BENCH_SCENARIO or "code"
local target_file = vim.env.BENCH_FILE
local report_path = vim.env.BENCH_REPORT

if not target_file then
  io.stderr:write("BENCH_FILE is required\n")
  vim.cmd("cquit 1")
end

-- Scenarios are plain ASCII on purpose: nvim_feedkeys is fed one byte at a
-- time below, so multi-byte UTF-8 would need to be split by codepoint, not
-- byte, to stay valid. Kept short enough that a pre-commit run stays quick
-- (a few seconds per scenario) but long enough (500+ timed keystrokes) for
-- percentile stats to mean something.
local scenarios = {
  code = {
    filetype_ext = "lua",
    warmup = [[-- warmup: give LSP/treesitter lazy init a head start
local Warmup = {}
]],
    body = [[
local M = {}

--- Compute the running average of a list of samples, dropping outliers
--- that sit more than two standard deviations from the mean.
function M.trimmed_average(samples)
  local sum = 0
  for _, value in ipairs(samples) do
    sum = sum + value
  end
  local mean = sum / #samples

  local variance = 0
  for _, value in ipairs(samples) do
    variance = variance + (value - mean) ^ 2
  end
  local stdev = math.sqrt(variance / #samples)

  local kept = {}
  for _, value in ipairs(samples) do
    if math.abs(value - mean) <= stdev * 2 then
      table.insert(kept, value)
    end
  end

  if #kept == 0 then
    return mean
  end

  local kept_sum = 0
  for _, value in ipairs(kept) do
    kept_sum = kept_sum + value
  end
  return kept_sum / #kept
end

function M.format_report(scenario, stats)
  return string.format(
    "%s: mean=%.2fms p95=%.2fms max=%.2fms",
    scenario,
    stats.mean,
    stats.p95,
    stats.max
  )
end

return M
]],
  },

  prose = {
    filetype_ext = "md",
    warmup = [[# Warmup

Give harper/spell/render-markdown a head start before we measure.

]],
    body = [[
## Typing responsiveness baseline

This document describes how the timvim typing-latency benchmark works and
why it exists. Every editor session is a long conversation between the
person typing and the software translating each keystroke into a change on
screen. When that translation takes too long, the conversation stutters:
letters appear late, the cursor jumps, and the whole editor starts to feel
unreliable even though nothing is actually broken.

The benchmark simulates a person typing a real paragraph of prose into a
markdown buffer, one character at a time, and records how long the editor
takes to absorb each keystroke. Grammar checking, spell suggestions, and
markdown rendering all hook into the same insert-mode events a human
typing would trigger, so the numbers this produces should track what a
person actually feels while writing documentation, commit messages, or
notes.

Results are stored alongside the commit they were measured against so a
regression can be traced back to the change that caused it, rather than
discovered weeks later as a vague sense that "typing feels slower now".
]],
  },
}

local scenario = scenarios[scenario_name]
if not scenario then
  io.stderr:write("unknown BENCH_SCENARIO: " .. tostring(scenario_name) .. "\n")
  vim.cmd("cquit 1")
end

-- Open the scenario file *inside the repo* (not /tmp) so LSP root-dir
-- detection (.git, *.nix, etc.) behaves exactly as it does for a real
-- editing session -- a benchmark against a server that never attached
-- would not tell us anything about steady-state typing cost.
vim.cmd("edit " .. vim.fn.fnameescape(target_file))
vim.bo.filetype = vim.filetype.match({ filename = target_file }) or scenario.filetype_ext

-- Give a real LSP client a chance to attach, same as it would for a human
-- opening the file, without letting a slow/missing server block the run.
local lsp_attached = vim.wait(4000, function()
  return #vim.lsp.get_clients({ bufnr = 0 }) > 0
end, 50)

local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true)

--- Convert plain text into a feedkeys-ready string ("\n" -> <CR>) and type
--- it as one "i" ... <Esc> insert-mode phase. When `record` is true,
--- registers a vim.on_key() listener for the duration so a timestamp is
--- captured for every key Nvim's core actually processes, and returns the
--- per-key latencies in milliseconds (one fewer than the character count:
--- the first key -- entering insert mode -- has no preceding timestamp to
--- diff against, and the trailing Escape is dropped since it is not a
--- typed document character).
local function type_phase(text, record)
  local keys = "i" .. text:gsub("\n", cr) .. esc

  local timestamps
  local ns
  if record then
    timestamps = {}
    ns = vim.api.nvim_create_namespace("bench-typing")
    vim.on_key(function(_)
      timestamps[#timestamps + 1] = vim.uv.hrtime()
    end, ns)
  end

  vim.api.nvim_feedkeys(keys, "x", false)

  if not record then
    return nil
  end

  vim.on_key(nil, ns)

  local latencies = {}
  -- timestamps[1] is the "i" keystroke itself; timestamps[#timestamps] is
  -- the trailing Escape. Deltas in between are one per typed character.
  for i = 2, #timestamps - 1 do
    table.insert(latencies, (timestamps[i] - timestamps[i - 1]) / 1e6)
  end
  return latencies
end

type_phase(scenario.warmup, false)

local latencies = type_phase(scenario.body, true)

table.sort(latencies)

local function percentile(sorted, p)
  if #sorted == 0 then
    return 0
  end
  local idx = math.max(1, math.ceil(p / 100 * #sorted))
  return sorted[idx]
end

local sum = 0
for _, v in ipairs(latencies) do
  sum = sum + v
end
local mean = #latencies > 0 and (sum / #latencies) or 0

local variance = 0
for _, v in ipairs(latencies) do
  variance = variance + (v - mean) ^ 2
end
local stdev = #latencies > 0 and math.sqrt(variance / #latencies) or 0

local report = {
  scenario = scenario_name,
  filetype = vim.bo.filetype,
  keystrokes = #latencies,
  lsp_attached = lsp_attached,
  nvim_version = tostring(vim.version()),
  total_ms = sum,
  mean_ms = mean,
  median_ms = percentile(latencies, 50),
  p95_ms = percentile(latencies, 95),
  p99_ms = percentile(latencies, 99),
  max_ms = latencies[#latencies] or 0,
  stdev_ms = stdev,
  latencies_ms = latencies,
}

local encoded = vim.json.encode(report)
if report_path then
  local f = io.open(report_path, "w")
  if f then
    f:write(encoded)
    f:close()
  else
    io.stderr:write("could not write BENCH_REPORT to " .. report_path .. "\n")
    vim.cmd("cquit 1")
  end
else
  io.stdout:write(encoded .. "\n")
end

vim.cmd("qa!")
