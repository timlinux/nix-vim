{ pkgs, ... }:
{
  vim = {

    statusline = {
      lualine = {
        enable = true;
        theme = "auto";
        icons.enable = true;
        disabledFiletypes.statusline = [ "alpha" ];
      };
    };
    luaConfigRC = {
      lualine_kartoza = ''
        -- Kartoza lualine theme with powerline bubbles and rounded caps
        local colors = {
          bg       = "#1e2020",
          fg       = "#f1f1f1",
          yellow   = "#DF9E2F",
          cyan     = "#569FC6",
          darkblue = "#569FC6",
          green    = "#06969A",
          orange   = "#DF9E2F",
          violet   = "#06969A",
          magenta  = "#569FC6",
          blue     = "#f8faf6",
          red      = "#CC0403",
          gray     = "#8A8B8B",
        }

        -- Mode color mapping for dynamic cap coloring
        local mode_colors = {
          n = colors.yellow, no = colors.yellow, nov = colors.yellow,
          i = colors.green, ic = colors.green, ix = colors.green,
          v = colors.cyan, V = colors.cyan, ['\22'] = colors.cyan,
          s = colors.cyan, S = colors.cyan,
          R = colors.red, Rv = colors.red,
          c = colors.orange, cv = colors.orange,
          t = colors.green,
        }

        local kartoza = {
          normal = {
            a = { fg = colors.fg, bg = colors.yellow, gui = 'bold' },
            b = { fg = colors.fg, bg = colors.darkblue },
            c = { fg = colors.fg, bg = colors.bg },
          },
          insert = {
            a = { fg = colors.fg, bg = colors.green, gui = 'bold' },
            b = { fg = colors.fg, bg = colors.darkblue },
            c = { fg = colors.fg, bg = colors.bg },
          },
          visual = {
            a = { fg = colors.fg, bg = colors.cyan, gui = 'bold' },
            b = { fg = colors.fg, bg = colors.darkblue },
            c = { fg = colors.fg, bg = colors.bg },
          },
          replace = {
            a = { fg = colors.fg, bg = colors.red, gui = 'bold' },
            b = { fg = colors.fg, bg = colors.darkblue },
            c = { fg = colors.fg, bg = colors.bg },
          },
          command = {
            a = { fg = colors.fg, bg = colors.orange, gui = 'bold' },
            b = { fg = colors.fg, bg = colors.darkblue },
            c = { fg = colors.fg, bg = colors.bg },
          },
          inactive = {
            a = { fg = colors.fg, bg = colors.bg, gui = 'bold' },
            b = { fg = colors.fg, bg = colors.bg },
            c = { fg = colors.fg, bg = colors.bg },
          },
        }

        -- Global variable to track last yanked register
        vim.g.last_yanked_register = ""
        vim.g.yank_timer = nil

        -- Function to show yank indicator temporarily
        local function show_yank_indicator(register)
          vim.g.last_yanked_register = register
          if vim.g.yank_timer then
            vim.fn.timer_stop(vim.g.yank_timer)
          end
          vim.g.yank_timer = vim.fn.timer_start(3000, function()
            vim.g.last_yanked_register = ""
            vim.g.yank_timer = nil
            vim.cmd('redrawstatus')
          end)
          vim.cmd('redrawstatus')
        end

        -- Set up autocmd for yank detection
        vim.api.nvim_create_autocmd("TextYankPost", {
          callback = function()
            local event = vim.v.event
            if event.regname and event.regname ~= "" then
              show_yank_indicator(event.regname)
            else
              show_yank_indicator('"')
            end
          end,
        })

        require('lualine').setup {
          options = {
            theme = kartoza,
            section_separators = { left = "", right = "" },
            component_separators = { left = "\u{e0b0}", right = "\u{e0b2}" },
            globalstatus = true,
            -- Hide the statusline on the alpha dashboard. This manual setup
            -- overrides the nvf-generated config, so disabled_filetypes must be
            -- declared here too (the module option alone has no effect).
            disabled_filetypes = { statusline = { "alpha" }, winbar = {} },
          },
          sections = {
            -- All left content in section a for unified bubble bar
            lualine_a = {
              -- Mode - orange (theme-controlled, changes with mode)
              { 'mode' },
              -- Filename - blue
              { 'filename', color = { fg = colors.fg, bg = colors.darkblue } },
              -- Branch - gray
              { 'branch', color = { fg = colors.fg, bg = colors.gray }, separator = "" },
              -- Diff - gray (same bubble, no separator)
              { 'diff', color = { bg = colors.gray }, separator = "" },
              -- Diagnostics - gray (same bubble, no separator)
              { 'diagnostics', color = { bg = colors.gray }, separator = "" },
              -- Rounded right cap (gray to match branch/diff/diagnostics bubble)
              { function() return "\u{e0b4}" end,
                color = { fg = colors.gray, bg = colors.bg },
                padding = 0 },
            },
            lualine_b = {},
            -- Transient indicators float in the gap
            lualine_c = {
              -- Macro recording indicator
              {
                function()
                  local recording_register = vim.fn.reg_recording()
                  if recording_register == "" then
                    return ""
                  else
                    return "Recording @" .. recording_register
                  end
                end,
                color = { fg = colors.fg, bg = colors.red, gui = 'bold' },
              },
              -- Yank indicator
              {
                function()
                  if vim.g.last_yanked_register and vim.g.last_yanked_register ~= "" then
                    return "Yanked @" .. vim.g.last_yanked_register
                  else
                    return ""
                  end
                end,
                color = { fg = colors.fg, bg = colors.green, gui = 'bold' },
              },
            },
            lualine_x = {},
            lualine_y = {},
            -- All right content in section z for unified bubble bar (mirrored: gray -> blue -> orange)
            lualine_z = {
              -- Rounded left cap
              { function() return "\u{e0b6}" end,
                color = { fg = colors.gray, bg = colors.bg },
                padding = 0 },
              -- Copilot dot indicator (red = active, gray = disabled)
              {
                function()
                  local ok, cc = pcall(require, 'copilot.client')
                  if ok and cc then return "\u{25cf}" end
                  return ""
                end,
                color = function()
                  local ok, cc = pcall(require, 'copilot.client')
                  if ok and cc and not cc.is_disabled() then
                    return { fg = colors.red, bg = colors.gray }
                  else
                    return { fg = '#666666', bg = colors.gray }
                  end
                end,
                on_click = function()
                  local cmd = require('copilot.command')
                  local client = require('copilot.client')
                  if client.is_disabled() then
                    cmd.enable()
                  else
                    cmd.disable()
                  end
                end,
                padding = { left = 1, right = 0 },
                separator = "",
              },
              -- Copilot text (white, only shown when active)
              {
                function()
                  local ok, cc = pcall(require, 'copilot.client')
                  if ok and cc and not cc.is_disabled() then
                    return "Ctrl-y"
                  end
                  return ""
                end,
                color = { fg = colors.fg, bg = colors.gray },
                on_click = function()
                  local cmd = require('copilot.command')
                  local client = require('copilot.client')
                  if client.is_disabled() then
                    cmd.enable()
                  else
                    cmd.disable()
                  end
                end,
                padding = { left = 1, right = 1 },
                separator = "",
              },
              -- Encoding - gray (same bubble)
              { 'encoding', color = { fg = colors.fg, bg = colors.gray }, separator = "" },
              -- Fileformat - gray (last in gray bubble, default separator creates triangle to blue)
              { 'fileformat', color = { fg = colors.fg, bg = colors.gray } },
              -- Filetype - blue
              { 'filetype', color = { fg = colors.fg, bg = colors.darkblue } },
              -- Progress - orange
              { 'progress', color = { fg = colors.fg, bg = colors.yellow }, separator = "" },
              -- Location - orange (same bubble)
              { 'location', color = { fg = colors.fg, bg = colors.yellow } },
            },
          }
        }
      '';
    };
  };
}
