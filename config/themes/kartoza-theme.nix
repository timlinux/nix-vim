{
  vim.theme = {
    enable = false;
  };
  vim.luaConfigRC = {
    kartoza = ''
      -- Kartoza Custom Theme
      --
      -- `highlight clear` wipes EVERY group, and this runs from luaConfigRC --
      -- i.e. after pluginRC -- so it also wipes highlights plugins set at load
      -- time. Anything not restored below renders with no colour at all, which
      -- is what a "black screen" actually is. The group list therefore has to
      -- stay exhaustive, and we re-apply on ColorScheme so a later
      -- `:colorscheme` cannot leave the UI half-cleared.

      -- Base colors from Kartoza palette
      local colors = {
        kartozablue = "#569FC6",    -- Kartoza blue (highlight2)
        kartozaorange = "#DF9E2F",    -- Kartoza yellow/orange (highlight1)
        kartozagray = "#8A8B8B",    -- Kartoza grey (highlight3)
        base03 = "#1e2020",    -- dark background
        red = "#CC0403",       -- Kartoza alert red
        green = "#06969A",     -- Kartoza teal (highlight4)
        yellow = "#DF9E2F",    -- Kartoza yellow/orange (highlight1)
        blue = "#f8faf6",      -- light foreground
        magenta = "#569FC6",   -- Kartoza blue (highlight2)
        cyan = "#569FC6",      -- Kartoza blue (highlight2)
        base2 = "#f1f1f1",     -- light foreground - text on lualine, vim editor main text and splash
        base02 = "#2b2e2e",    -- secondary dark background - also used as lualine background and popup
        orange = "#DF9E2F",    -- Kartoza yellow/orange (highlight1)
        base01 = "#569FC6",    -- Kartoza blue (highlight2) - popup panel arrows
        base00 = "#ff65ff",    -- base00
        base0 = "#00c8ad",     -- base0
        violet = "#56f341",    -- violet
        base1 = "#f23abb",     -- base1
        base3 = "#c8856e",      -- light background
        darktext = "#569FC6"  -- for line numbers (Kartoza blue)
      }

      -- Apply highlights using proper Lua syntax
      local highlights = {
        Normal = { fg = colors.base2, bg = colors.base03 },
        NormalFloat = { fg = colors.base2, bg = colors.base02 },
        Comment = { fg = colors.kartozagray, italic = true },
        Constant = { fg = colors.yellow },
        String = { fg = colors.green },
        Character = { fg = colors.green },
        Number = { fg = colors.orange },
        Boolean = { fg = colors.magenta },
        Function = { fg = colors.blue, bold = true },
        Statement = { fg = colors.magenta, bold = true },
        Operator = { fg = colors.red },
        Type = { fg = colors.yellow, bold = true },
        Special = { fg = colors.cyan },
        Error = { fg = colors.red, bg = colors.base03, bold = true },
        Search = { fg = colors.base03, bg = colors.yellow },
        CursorLine = { bg = colors.base02 },
        LineNr = { fg = colors.darktext, bg = colors.base03 },
        CursorLineNr = { fg = colors.yellow, bg = colors.base02, bold = true },
        StatusLine = { fg = colors.base2, bg = colors.base02 },
        Visual = { bg = colors.base01, fg = colors.base03 },
        VisualNOS = { bg = colors.base02 },

        -- Groups that `highlight clear` wipes. Without these the editor
        -- renders with no colour information at all.
        NormalNC = { fg = colors.base2, bg = colors.base03 },
        NonText = { fg = colors.base02 },
        EndOfBuffer = { fg = colors.base03 },
        Whitespace = { fg = colors.base02 },
        SpecialKey = { fg = colors.base02 },
        Conceal = { fg = colors.kartozagray },
        Directory = { fg = colors.cyan, bold = true },
        Title = { fg = colors.yellow, bold = true },
        MatchParen = { fg = colors.yellow, bg = colors.base02, bold = true },
        ColorColumn = { bg = colors.base02 },
        CursorColumn = { bg = colors.base02 },
        QuickFixLine = { bg = colors.base02, bold = true },

        -- Line-number gutter (relativenumber is on, so the Above/Below
        -- variants are live groups, not decoration).
        LineNrAbove = { fg = colors.kartozagray, bg = colors.base03 },
        LineNrBelow = { fg = colors.kartozagray, bg = colors.base03 },
        SignColumn = { fg = colors.kartozagray, bg = colors.base03 },
        FoldColumn = { fg = colors.kartozagray, bg = colors.base03 },
        Folded = { fg = colors.kartozagray, bg = colors.base02, italic = true },

        -- Popup menu (completion). Unset here means an unreadable menu.
        Pmenu = { fg = colors.base2, bg = colors.base02 },
        PmenuSel = { fg = colors.base03, bg = colors.kartozaorange, bold = true },
        PmenuSbar = { bg = colors.base02 },
        PmenuThumb = { bg = colors.kartozagray },

        -- Statusline / winbar / tabline
        StatusLineNC = { fg = colors.kartozagray, bg = colors.base02 },
        WinBar = { fg = colors.base2, bg = colors.base03 },
        WinBarNC = { fg = colors.kartozagray, bg = colors.base03 },
        TabLine = { fg = colors.kartozagray, bg = colors.base02 },
        TabLineFill = { bg = colors.base03 },
        TabLineSel = { fg = colors.base03, bg = colors.kartozaorange, bold = true },

        -- Messages
        MsgArea = { fg = colors.base2, bg = colors.base03 },
        ModeMsg = { fg = colors.yellow, bold = true },
        MoreMsg = { fg = colors.green },
        Question = { fg = colors.cyan },
        WarningMsg = { fg = colors.orange, bold = true },
        ErrorMsg = { fg = colors.red, bold = true },

        -- Search
        IncSearch = { fg = colors.base03, bg = colors.orange, bold = true },
        CurSearch = { fg = colors.base03, bg = colors.orange, bold = true },

        -- Syntax groups not covered above
        Identifier = { fg = colors.cyan },
        PreProc = { fg = colors.magenta },
        Todo = { fg = colors.base03, bg = colors.yellow, bold = true },
        Underlined = { fg = colors.cyan, underline = true },

        -- Diffs
        DiffAdd = { fg = colors.green, bg = colors.base02 },
        DiffChange = { fg = colors.yellow, bg = colors.base02 },
        DiffDelete = { fg = colors.red, bg = colors.base02 },
        DiffText = { fg = colors.base03, bg = colors.yellow },

        -- Diagnostics (DiagnosticInfo is set with the border groups below)
        DiagnosticError = { fg = colors.red },
        DiagnosticWarn = { fg = colors.orange },
        DiagnosticHint = { fg = colors.cyan },
        DiagnosticOk = { fg = colors.green },

        -- UI frames/borders in Kartoza orange
        FloatBorder = { fg = colors.kartozaorange, bg = colors.base02 },
        WinSeparator = { fg = colors.kartozaorange },
        VertSplit = { fg = colors.kartozaorange },
        TelescopeBorder = { fg = colors.kartozaorange },
        TelescopePromptBorder = { fg = colors.kartozaorange },
        TelescopeResultsBorder = { fg = colors.kartozaorange },
        TelescopePreviewBorder = { fg = colors.kartozaorange },
        FzfLuaBorder = { fg = colors.kartozaorange },
        NotifyBorder = { fg = colors.kartozaorange },
        WhichKeyBorder = { fg = colors.kartozaorange },
        LspInfoBorder = { fg = colors.kartozaorange },
        DiagnosticInfo = { fg = colors.kartozaorange },

        -- Noice / cmdline borders
        NoiceCmdlinePopupBorder = { fg = colors.kartozaorange },
        NoiceCmdlinePopupBorderSearch = { fg = colors.kartozaorange },
        NoicePopupBorder = { fg = colors.kartozaorange },
        NoiceConfirmBorder = { fg = colors.kartozaorange },

        -- Completion / misc popup borders
        CmpBorder = { fg = colors.kartozaorange },
        SagaBorder = { fg = colors.kartozaorange },
        TroubleNormal = { fg = colors.base2, bg = colors.base03 },
        LazyNormal = { fg = colors.base2, bg = colors.base03 },
        MasonNormal = { fg = colors.base2, bg = colors.base03 },
      }

      local function apply_kartoza()
        vim.cmd([[
          highlight clear
          if exists("syntax_on")
            syntax reset
          endif
          set background=dark
          let g:colors_name = "kartoza"
        ]])
        for group, opts in pairs(highlights) do
          vim.api.nvim_set_hl(0, group, opts)
        end
      end

      _G.kartoza_apply_theme = apply_kartoza
      apply_kartoza()

      -- Re-apply whenever anything else swaps colorscheme (which calls
      -- `highlight clear` again and would otherwise strip the UI back to bare).
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          if vim.g.colors_name ~= "kartoza" then
            return
          end
          for group, opts in pairs(highlights) do
            vim.api.nvim_set_hl(0, group, opts)
          end
        end,
      })
    '';
  };
}
