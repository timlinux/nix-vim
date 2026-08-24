{
  vim = {
    globals = {
      mapleader = " ";
    };
    options = {
      # Numbering
      number = true;
      relativenumber = true;

      # Cursor line highlighting
      cursorline = true;
      cursorlineopt = "both"; # Highlight the line and the number

      # Tab Settings
      tabstop = 2;
      softtabstop = 2;
      showtabline = 0;
      expandtab = true;

      # Indentation
      smartindent = true;
      shiftwidth = 2;
      breakindent = true;

      # Fold Settings
      foldcolumn = "1";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = false;

      shada = "!,'100,<50,s10,h";
      #shadafile = "NONE";

      # Autosave is opt-in: <leader>ta turns it on and flips these with it
      # (they write implicitly on buffer switches, :make, :next and friends).
      autowrite = false;
      autowriteall = false;
      updatetime = 500; # CursorHold delay and swap file write (single authoritative value)

      wrap = false;

      # Keep context around the cursor instead of letting it hit the edges
      scrolloff = 8;
      sidescrolloff = 8;

      # Always reserve the sign column so the text does not shift sideways
      # every time a diagnostic, gitsign or breakpoint appears
      signcolumn = "yes";

      # New splits open where the eye expects them
      splitbelow = true;
      splitright = true;

      # Live preview of :substitute in a scratch split
      inccommand = "split";

      # Ask instead of failing on :q with unsaved changes
      confirm = true;

      # which-key/flash feel: how long a pending key sequence waits.
      # This must be `tm`, not `timeoutlen`: nvf declares `tm` with a default of
      # 500 and emits it after `timeoutlen` in the generated init.lua, so
      # setting the long name alone is silently overwritten.
      tm = 400;

      # Mouse settings for clipboard integration
      mouse = "a"; # Enable mouse in all modes
      mousemodel = "popup_setpos"; # Right-click shows popup menu

      # Project-local config (.nvim.lua, .exrc, .nvimrc)
      exrc = true; # Auto-source project-local config files
      secure = true; # Restrict dangerous commands in exrc files
    };

    luaConfigRC.suppress_direnv = ''
      -- Suppress direnv export messages from cluttering startup
      local original_notify = vim.notify
      vim.notify = function(msg, level, opts)
        if type(msg) == "string" then
          if msg:match("@mdirenv") or msg:match("^direnv:") then
            return
          end
        end
        return original_notify(msg, level, opts)
      end
    '';

    luaConfigRC.spellfile_setup = ''
      -- Set spellfile to a writable location so zg/zw commands work
      local spell_dir = vim.fn.stdpath("data") .. "/spell"
      vim.fn.mkdir(spell_dir, "p")
      vim.opt.spellfile = spell_dir .. "/en.utf-8.add"

      -- Show spell suggestions popup when hovering a misspelled word
      _G.spell_autopopup_enabled = false
      local spell_dismissed = {}

      _G.toggle_spell_autopopup = function()
        _G.spell_autopopup_enabled = not _G.spell_autopopup_enabled
        spell_dismissed = {}
        vim.notify("Spell suggestion autopopup: " .. (_G.spell_autopopup_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
      end

      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          if not _G.spell_autopopup_enabled then
            return
          end
          if not vim.opt_local.spell:get() then
            return
          end
          local word = vim.fn.expand("<cword>")
          if word == "" or spell_dismissed[word] then
            return
          end
          local bad = vim.fn.spellbadword(word)
          if bad[1] == "" then
            return
          end
          local suggestions = vim.fn.spellsuggest(bad[1], 10)
          if #suggestions == 0 then
            return
          end
          vim.ui.select(suggestions, { prompt = "Spelling: " .. bad[1] }, function(choice)
            if choice then
              vim.cmd("normal! ciw" .. choice)
              vim.cmd("stopinsert")
            else
              -- User dismissed without choosing; don't show again for this word
              spell_dismissed[word] = true
            end
          end)
        end,
      })
    '';

    # Restore cursor position when opening files
    luaConfigRC.restore_cursor = ''
      -- Restore cursor position when opening files
      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "*",
        callback = function()
          local line = vim.fn.line("'\"")
          if line > 1 and line <= vim.fn.line("$") and vim.bo.filetype ~= "commit" then
            vim.cmd('normal! g`"')
          end
        end,
      })
    '';
  };
}
