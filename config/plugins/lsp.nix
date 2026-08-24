{
  vim = {
    lsp = {
      enable = true;
      lspconfig.enable = true;
      formatOnSave = false; # Disabled to avoid conflict with conform
      lspSignature.enable = false;
      lspkind.enable = true;

      lspsaga = {
        enable = true;
        setupOpts = {
          lightbulb = {
            enable = false;
          };
        };
      };

      inlayHints.enable = true;
      lightbulb.enable = false;
      # none-ls/null-ls is kept only because gitsigns' code actions are
      # registered as a null-ls source (see plugins/git.nix). Formatting is
      # conform's job and extra diagnostics go through nvim-lint, so turning
      # off `gitsigns.codeActions` would let this go too.
      null-ls.enable = true;
    };

    ui.borders.plugins.lspsaga = {
      enable = true; # optional: enables pretty borders for saga
      style = "rounded"; # optional: pick your border style
    };
    # Inlay hints are on by default; this makes them toggleable from <leader>tn
    # because they get noisy in Python/TypeScript.
    luaConfigRC.inlay_hints_toggle = ''
      _G.inlay_hints_enabled = true
      _G.toggle_inlay_hints = function()
        _G.inlay_hints_enabled = not _G.inlay_hints_enabled
        vim.lsp.inlay_hint.enable(_G.inlay_hints_enabled, { bufnr = nil })
        if _G.update_toggle_desc then
          _G.update_toggle_desc("<leader>tn", "Inlay Hints", _G.inlay_hints_enabled)
        end
        vim.notify("Inlay hints " .. (_G.inlay_hints_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
      end
    '';

    # Source custom Lua for lspsaga CursorHold diagnostics popup (disabled by default)
    luaConfigRC.lspsaga_cursorhold = ''
      -- Global variable to track CursorHold diagnostic state
      _G.cursorhold_diagnostics_enabled = false

      -- Global variable to track virtual text diagnostic state
      _G.virtual_text_diagnostics_enabled = true

      -- Function to show diagnostic popup
      local function show_diagnostic_popup()
        if vim.fn.mode() == "n" then
          local winwidth = vim.api.nvim_get_option("columns")
          vim.diagnostic.open_float(nil, { 
            focus = false, 
            scope = "line",
            border = "rounded",
            max_width = 60,
            max_height = 60,
            anchor = "NE",
            row = 1,
            col = winwidth - 1,
            close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre" }
          })
        end
      end

      -- CursorHold autocmd (initially disabled)
      local cursorhold_group = vim.api.nvim_create_augroup("CursorHoldDiagnostics", { clear = true })

      -- Function to toggle CursorHold diagnostics
      _G.toggle_cursorhold_diagnostics = function()
        _G.cursorhold_diagnostics_enabled = not _G.cursorhold_diagnostics_enabled
        
        -- Clear existing autocmds
        vim.api.nvim_clear_autocmds({ group = cursorhold_group })
        
        if _G.cursorhold_diagnostics_enabled then
          -- Enable CursorHold diagnostics
          vim.api.nvim_create_autocmd("CursorHold", {
            group = cursorhold_group,
            pattern = "*",
            callback = show_diagnostic_popup,
          })
          vim.notify("CursorHold diagnostics enabled", vim.log.levels.INFO)
        else
          vim.notify("CursorHold diagnostics disabled", vim.log.levels.INFO)
        end
      end

      -- Configure diagnostic virtual text (ghost text) for inline error display
      vim.diagnostic.config({
        virtual_text = {
          enabled = true,
          spacing = 4,
          source = "if_many",
          prefix = "●",
          -- Customize the format to include error type and truncate long messages
          format = function(diagnostic)
            local message = diagnostic.message
            if #message > 80 then
              message = string.sub(message, 1, 77) .. "..."
            end
            return string.format("%s %s", diagnostic.source or "", message)
          end,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Function to toggle virtual text diagnostics
      _G.toggle_virtual_text_diagnostics = function()
        _G.virtual_text_diagnostics_enabled = not _G.virtual_text_diagnostics_enabled
        
        vim.diagnostic.config({
          virtual_text = _G.virtual_text_diagnostics_enabled and {
            enabled = true,
            spacing = 4,
            source = "if_many",
            prefix = "●",
            format = function(diagnostic)
              local message = diagnostic.message
              if #message > 80 then
                message = string.sub(message, 1, 77) .. "..."
              end
              return string.format("%s %s", diagnostic.source or "", message)
            end,
          } or false
        })
        
        local status = _G.virtual_text_diagnostics_enabled and "enabled" or "disabled"
        vim.notify("Virtual text diagnostics " .. status, vim.log.levels.INFO)
      end
    '';
  };
}
