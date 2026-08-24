{ ... }:
{
  vim = {
    luaConfigRC.autosave = ''
      -- Auto-save, off by default and toggled with <leader>ta.
      --
      -- It used to fire on TextChanged, so every pause after any normal-mode
      -- edit wrote the buffer *and* ran conform's synchronous format-on-save
      -- straight through the typing path. When enabled it now saves on leaving
      -- insert mode, leaving a buffer, and losing focus.
      _G.autosave_enabled = false

      local autosave_group = vim.api.nvim_create_augroup("AutoSave", { clear = true })

      -- Filetypes where an implicit write would be wrong
      local excluded_filetypes = {
        gitcommit = true,
        gitrebase = true,
        fugitive = true,
      }

      local function save_if_dirty()
        if not _G.autosave_enabled then
          return
        end
        if vim.bo.modifiable and vim.bo.modified and vim.bo.buftype == "" then
          if excluded_filetypes[vim.bo.filetype] then
            return
          end
          vim.cmd("silent! write")
        end
      end

      vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, {
        group = autosave_group,
        pattern = "*",
        callback = save_if_dirty,
      })

      -- Save everything when the terminal/window loses focus
      vim.api.nvim_create_autocmd("FocusLost", {
        group = autosave_group,
        pattern = "*",
        callback = function()
          if _G.autosave_enabled then
            vim.cmd("silent! wall")
          end
        end,
      })

      _G.toggle_autosave = function()
        _G.autosave_enabled = not _G.autosave_enabled

        -- 'autowrite'/'autowriteall' write on buffer switches, :make, :next and
        -- friends, which is the same implicit-write behaviour under a different
        -- name -- so they follow the toggle rather than staying on behind it.
        vim.opt.autowrite = _G.autosave_enabled
        vim.opt.autowriteall = _G.autosave_enabled

        _G.toggle_states = _G.toggle_states or {}
        _G.toggle_states["<leader>ta"] = _G.autosave_enabled
        if _G.update_toggle_desc then
          _G.update_toggle_desc("<leader>ta", "Autosave", _G.autosave_enabled)
        end
        vim.notify("Autosave " .. (_G.autosave_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
      end
    '';
  };
}
