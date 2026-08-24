{ ... }:
{
  vim = {
    luaConfigRC.formatting = ''
      -- Manual format function
      _G.format_buffer = function()
        local conform = require("conform")
        local success, err = pcall(function()
          conform.format({
            lsp_fallback = true,
            timeout_ms = 2000,
          })
        end)
        
        if success then
          print("Buffer formatted successfully")
        else
          print("Formatting failed: " .. tostring(err))
        end
      end

      -- Debug function to check available formatters
      _G.check_formatters = function()
        local conform = require("conform")
        local ft = vim.bo.filetype
        local formatters = conform.list_formatters(0)
        vim.notify("Filetype: " .. ft, vim.log.levels.INFO)
        vim.notify("Available formatters: " .. vim.inspect(formatters), vim.log.levels.INFO)
      end

      -- Smart Enter handler for blink-cmp completion confirmation
      -- Enter confirms completion when menu is visible, otherwise inserts newline
      _G.smart_enter = function()
        local cmp = require('blink.cmp')
        if cmp.is_visible() then
          cmp.accept()
          return true
        end
        return false
      end

      -- Global quick spell fix function
      _G.quick_spell_fix = function()
        -- Check if spell checking is enabled
        if not vim.opt.spell:get() then
          print('Spell checking is not enabled. Use <leader>zs to enable it.')
          return
        end
        
        -- Get the word under cursor
        local word = vim.fn.expand('<cword>')
        
        -- Check if word is misspelled
        local badword = vim.fn.spellbadword(word)[1]
        if badword ~= "" then
          -- Get suggestions
          local suggestions = vim.fn.spellsuggest(word, 1)
          if #suggestions > 0 then
            -- Replace with first suggestion
            vim.cmd("normal! ciw" .. suggestions[1])
            print("Replaced '" .. word .. "' with '" .. suggestions[1] .. "'")
          else
            print("No suggestions found for '" .. word .. "'")
          end
        else
          print("Word '" .. word .. "' is spelled correctly")
        end
      end
    '';
  };
}
