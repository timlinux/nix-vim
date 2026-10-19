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

    # Right-hand side panel that shows diagnostics (and, failing that, hover
    # docs) for whatever line the cursor is resting on. Replaces the old
    # approach of inline virtual-text ghost text, which shifts far to the
    # right on long lines and becomes unreadable right when you need it —
    # the panel instead has a fixed position/width and wraps to use all the
    # vertical space it's given.
    luaConfigRC.diagnostics_side_panel = ''
      _G.side_panel_bufnr = nil
      _G.side_panel_winid = nil

      local function side_panel_close()
        if _G.side_panel_winid and vim.api.nvim_win_is_valid(_G.side_panel_winid) then
          vim.api.nvim_win_close(_G.side_panel_winid, true)
        end
        _G.side_panel_winid = nil
      end

      -- Exposed so <Esc> (see core/keymaps.nix) can dismiss the panel on demand.
      _G.close_diagnostics_side_panel = side_panel_close

      local function side_panel_geometry()
        local width = math.min(100, math.max(40, math.floor(vim.o.columns * 0.35)))
        local height = vim.o.lines - vim.o.cmdheight - 4
        local col = vim.o.columns - width - 1
        local row = 1
        return width, height, col, row
      end

      local function side_panel_show(lines)
        if not lines or #lines == 0 then
          side_panel_close()
          return
        end

        if not _G.side_panel_bufnr or not vim.api.nvim_buf_is_valid(_G.side_panel_bufnr) then
          _G.side_panel_bufnr = vim.api.nvim_create_buf(false, true)
          vim.bo[_G.side_panel_bufnr].buftype = "nofile"
          vim.bo[_G.side_panel_bufnr].bufhidden = "hide"
          vim.bo[_G.side_panel_bufnr].swapfile = false
          vim.bo[_G.side_panel_bufnr].filetype = "markdown"
        end

        vim.bo[_G.side_panel_bufnr].modifiable = true
        vim.api.nvim_buf_set_lines(_G.side_panel_bufnr, 0, -1, false, lines)
        vim.bo[_G.side_panel_bufnr].modifiable = false

        local width, height, col, row = side_panel_geometry()

        if _G.side_panel_winid and vim.api.nvim_win_is_valid(_G.side_panel_winid) then
          vim.api.nvim_win_set_config(_G.side_panel_winid, {
            relative = "editor",
            row = row,
            col = col,
            width = width,
            height = height,
          })
        else
          _G.side_panel_winid = vim.api.nvim_open_win(_G.side_panel_bufnr, false, {
            relative = "editor",
            row = row,
            col = col,
            width = width,
            height = height,
            style = "minimal",
            border = "rounded",
            focusable = false,
            zindex = 50,
            title = " Messages ",
            title_pos = "center",
          })
          vim.wo[_G.side_panel_winid].wrap = true
          vim.wo[_G.side_panel_winid].linebreak = true
          vim.wo[_G.side_panel_winid].breakindent = true
        end
      end

      local function format_diagnostic_lines(diags)
        local lines = {}
        for i, d in ipairs(diags) do
          local severity = vim.diagnostic.severity[d.severity] or "INFO"
          local heading = severity .. (d.source and (" — " .. d.source) or "")
          table.insert(lines, "### " .. heading)
          table.insert(lines, "")
          for _, l in ipairs(vim.split(d.message, "\n", { plain = true })) do
            table.insert(lines, l)
          end
          if i < #diags then
            table.insert(lines, "")
            table.insert(lines, "---")
            table.insert(lines, "")
          end
        end
        return lines
      end

      local function format_hover_lines(result)
        if not result or not result.contents then
          return {}
        end
        local ok, lines = pcall(vim.lsp.util.convert_input_to_markdown_lines, result.contents)
        if not ok then
          return {}
        end
        return lines
      end

      -- Side panel is on by default; <leader>tw toggles it.
      _G.cursorhold_diagnostics_enabled = true

      local function side_panel_update()
        if not _G.cursorhold_diagnostics_enabled or vim.fn.mode() ~= "n" then
          return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
        local diags = vim.diagnostic.get(bufnr, { lnum = lnum })

        if #diags > 0 then
          side_panel_show(format_diagnostic_lines(diags))
          return
        end

        if vim.fn.expand("<cword>") == "" then
          side_panel_close()
          return
        end

        local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/hover" })
        if #clients == 0 then
          side_panel_close()
          return
        end

        local params = vim.lsp.util.make_position_params(0, clients[1].offset_encoding)
        vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(_, result)
          if not _G.cursorhold_diagnostics_enabled then
            return
          end
          -- Cursor may have moved on before the response arrived.
          if vim.api.nvim_get_current_buf() ~= bufnr or vim.api.nvim_win_get_cursor(0)[1] - 1 ~= lnum then
            return
          end
          side_panel_show(format_hover_lines(result))
        end)
      end

      _G.toggle_cursorhold_diagnostics = function()
        _G.cursorhold_diagnostics_enabled = not _G.cursorhold_diagnostics_enabled
        if not _G.cursorhold_diagnostics_enabled then
          side_panel_close()
        end
        vim.notify(
          "Diagnostics side panel " .. (_G.cursorhold_diagnostics_enabled and "enabled" or "disabled"),
          vim.log.levels.INFO
        )
      end

      -- K / <leader>nh route into the same panel instead of the default
      -- floating hover box, so manual lookups land in the same place.
      _G.show_hover_in_panel = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/hover" })
        if #clients == 0 then
          vim.notify("No LSP client supports hover here", vim.log.levels.INFO)
          return
        end
        local params = vim.lsp.util.make_position_params(0, clients[1].offset_encoding)
        vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(_, result)
          local lines = format_hover_lines(result)
          if #lines == 0 then
            vim.notify("No hover information available", vim.log.levels.INFO)
            return
          end
          side_panel_show(lines)
        end)
      end

      local side_panel_group = vim.api.nvim_create_augroup("DiagnosticsSidePanel", { clear = true })

      vim.api.nvim_create_autocmd("CursorHold", {
        group = side_panel_group,
        pattern = "*",
        callback = side_panel_update,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter", "BufLeave", "WinLeave" }, {
        group = side_panel_group,
        pattern = "*",
        callback = side_panel_close,
      })

      -- Virtual text (ghost text) diagnostics are off by default — the side
      -- panel above is now the primary way to read full messages without
      -- the inline shift-to-the-right problem long ghost text causes.
      _G.virtual_text_diagnostics_enabled = false

      local function virtual_text_opts()
        if not _G.virtual_text_diagnostics_enabled then
          return false
        end
        return {
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
        }
      end

      vim.diagnostic.config({
        virtual_text = virtual_text_opts(),
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      _G.toggle_virtual_text_diagnostics = function()
        _G.virtual_text_diagnostics_enabled = not _G.virtual_text_diagnostics_enabled
        vim.diagnostic.config({ virtual_text = virtual_text_opts() })
        vim.notify(
          "Virtual text diagnostics " .. (_G.virtual_text_diagnostics_enabled and "enabled" or "disabled"),
          vim.log.levels.INFO
        )
      end
    '';
  };
}
