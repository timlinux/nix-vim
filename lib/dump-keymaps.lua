-- SPDX-FileCopyrightText: 2026 Kartoza (Pty) Ltd <tim@kartoza.com>
-- SPDX-License-Identifier: MIT
--
-- Headless keymap dumper. Run by the docs pipeline:
--   KEYMAP_JSON=out.json nvim --headless -c 'luafile lib/dump-keymaps.lua' +qa
-- It records every keymap timvim actually sets, so the handbook's keymap
-- tables and keyboard diagrams are generated from the live configuration and
-- can never drift from it.
-- Fire VimEnter and force-load lazily-mapped plugins so their global keymaps
-- (smart-splits Ctrl+hjkl, toggleterm Ctrl+t, …) are registered before we read
-- them. Without this the dump misses keymaps set on plugin load.
pcall(vim.api.nvim_exec_autocmds, "VimEnter", {})
for _, p in ipairs({ "smart-splits", "toggleterm", "flash", "which-key" }) do
  pcall(require, p)
end
vim.wait(400, function()
  return false
end)

local ok, err = pcall(function()
  local out = { modes = {} }
  for _, m in ipairs({ "n", "i", "v", "x", "o", "c", "t" }) do
    local list = {}
    for _, km in ipairs(vim.api.nvim_get_keymap(m)) do
      list[#list + 1] = {
        lhs = km.lhs,
        desc = km.desc or "",
        rhs = km.rhs or "",
      }
    end
    out.modes[m] = list
  end
  local path = vim.env.KEYMAP_JSON or "keymaps.json"
  local f = assert(io.open(path, "w"))
  f:write(vim.json.encode(out))
  f:close()
  io.stderr:write("dump-keymaps: wrote " .. path .. "\n")
end)
if not ok then
  io.stderr:write("dump-keymaps ERROR: " .. tostring(err) .. "\n")
  vim.cmd("cquit 1")
end
