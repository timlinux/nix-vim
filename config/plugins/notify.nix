{ ... }:
{
  # nvim-notify is configured once, here. It used to be set up three times --
  # this module, a duplicate `extraPlugins` copy of the same package, and again
  # in noice.nix -- each with a different background colour, so the winner was
  # whichever DAG entry ran last.
  vim.notify.nvim-notify = {
    enable = true;

    setupOpts = {
      stages = "fade_in_slide_out";
      timeout = 5000;
      top_down = false; # Notifications stack up from the bottom right
      minimum_width = 50;
      max_width = 60;
      max_height = 20;
      background_colour = "#292525";
      render = "wrapped-compact";
      fps = 30;
      level = 2; # vim.log.levels.INFO
      icons = {
        ERROR = "";
        WARN = "";
        INFO = "";
        DEBUG = "";
        TRACE = "✎";
      };
    };
  };

  # Keybindings for notification management
  vim.luaConfigRC.notify-keybinds = ''
    -- Dismiss all visible notifications
    vim.keymap.set("n", "<leader>Nd", function()
      require("notify").dismiss({ silent = true, pending = true })
    end, { desc = "󰅖 Dismiss All Notifications" })

    -- Show notification history
    vim.keymap.set("n", "<leader>Nh", function()
      require("telescope").extensions.notify.notify()
    end, { desc = "󰋚 Notification History" })
  '';
}
