{ ... }:
{
  vim = {
    luaConfigRC.autosave = ''
      -- Auto-save configuration.
      --
      -- This used to fire on TextChanged as well, which meant every pause after
      -- any normal-mode edit wrote the buffer *and* ran conform's synchronous
      -- format-on-save (black/nixfmt/prettier, 1s timeout) straight through the
      -- typing path. Saving on leave/focus events keeps the same "never lose
      -- work" guarantee without formatting mid-thought.
      local autosave_group = vim.api.nvim_create_augroup("AutoSave", { clear = true })

      -- Filetypes where an implicit write would be wrong
      local excluded_filetypes = {
        gitcommit = true,
        gitrebase = true,
        fugitive = true,
      }

      local function save_if_dirty()
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
          vim.cmd("silent! wall")
        end,
      })

      -- No BufWritePost "File saved" echo: it fired a deferred message on every
      -- single write, and noice already filters "written" messages away.
    '';
  };
}
