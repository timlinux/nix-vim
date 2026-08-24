{ pkgs, ... }:
{
  vim = {
    # nvim-notify and nvim-treesitter come from their own nvf modules; listing
    # them here too loaded the same plugins twice and re-ran notify.setup with
    # a second, conflicting config. See config/plugins/notify.nix.
    startPlugins = [
      pkgs.vimPlugins.noice-nvim
      pkgs.vimPlugins.nui-nvim
    ];

    pluginRC.noice-nvim = ''
      local noice = require("noice")
      noice.setup({
        lsp = {
          progress = { enabled = true },
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = false,
          command_palette = true,
          long_message_to_split = true,
        },
        views = {
          cmdline_popup = {
            position = {
              row = "40%",
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto",
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = {
                Normal = "Normal",
                FloatBorder = "FloatBorder",
              },
            },
          },
          cmdline_search = {
            position = {
              row = "40%",
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto",
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
          },
          cmdline_search_down = {
            position = {
              row = "40%",
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto",
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
          },
          cmdline_search_up = {
            position = {
              row = "40%",
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto",
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
          },
          popupmenu = {
            relative = "editor",
            position = {
              row = 8,
              col = "50%",
            },
            size = {
              width = 60,
              height = 10,
            },
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = {
                Normal = "Normal",
                FloatBorder = "DiagnosticInfo",
              },
            },
          },
        },
        routes = {
          -- Skip mode change notifications
          {
            filter = {
              event = "msg_showmode"
            },
            opts = { skip = true },
          },
          -- Skip search count messages (like "1 of 5 matches")
          {
            filter = {
              event = "msg_show",
              kind = "search_count",
            },
            opts = { skip = true },
          },
          -- Skip recording messages
          {
            filter = {
              event = "msg_show",
              find = "recording",
            },
            opts = { skip = true },
          },
          -- Skip "written" messages when saving files
          {
            filter = {
              event = "msg_show",
              find = "written",
            },
            opts = { skip = true },
          },
          -- Skip LSP progress messages from specific clients
          {
            filter = {
              event = "lsp",
              kind = "progress",
              cond = function(message)
                local client = vim.tbl_get(message.opts, "progress", "client")
                return client == "lua_ls"
              end,
            },
            opts = { skip = true },
          },
        },
      })
    '';
  };
}
