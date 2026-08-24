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
      # Per-level timeouts are applied by the policy wrapper below; this is only
      # the fallback for anything that reaches nvim-notify directly.
      timeout = 2000;
      top_down = false; # Notifications stack up from the bottom right
      minimum_width = 20; # Short messages get short boxes
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

  # One place that decides what is shown, for how long, and what is dropped.
  # This wraps whatever `vim.notify` is by the time luaConfigRC runs, which is
  # noice's router -- and noice forwards `opts` (including `timeout`) straight
  # through to nvim-notify.
  vim.luaConfigRC.notify-policy = ''
    local levels = vim.log.levels

    -- Messages that are pure noise. Matched as Lua patterns against the text.
    _G.notify_mutelist = {
      "^direnv:", -- direnv's export chatter on every directory change
      "@mdirenv",
      "No information available", -- LSP hover with nothing to say
      "position_encoding param is required", -- nvim 0.11 deprecation spam
    }

    -- How long each severity stays on screen. An error you cannot read is
    -- worse than no error, and "Autosave enabled" does not deserve 5 seconds.
    local timeouts = {
      [levels.ERROR] = 10000,
      [levels.WARN] = 6000,
      [levels.INFO] = 2000,
      [levels.DEBUG] = 1500,
      [levels.TRACE] = 1500,
    }

    -- Do-not-disturb: when muted, only errors get through.
    _G.notifications_muted = false

    local recent = {}
    local DEDUP_MS = 2000

    -- Pure decision function, kept separate from the wrapper so it can be
    -- exercised directly (and so the wrapper stays trivial).
    -- Returns nil to drop the message, or the opts table to notify with.
    _G.notify_policy = function(msg, level, opts)
      if type(level) == "string" then
        level = levels[level:upper()] or levels.INFO
      end
      level = level or levels.INFO

      if type(msg) == "string" then
        for _, pattern in ipairs(_G.notify_mutelist) do
          if msg:match(pattern) then
            return nil
          end
        end
      end

      if _G.notifications_muted and level < levels.ERROR then
        return nil
      end

      -- Collapse identical repeats: LSP and formatter failures arrive in
      -- bursts, and five copies of one message carry no more information
      -- than one.
      if type(msg) == "string" then
        local key = tostring(level) .. "|" .. msg
        local now = (vim.uv or vim.loop).now()
        if recent[key] and (now - recent[key]) < DEDUP_MS then
          return nil
        end
        recent[key] = now
      end

      opts = opts or {}
      if opts.timeout == nil then
        opts.timeout = timeouts[level] or 3000
      end
      return opts, level
    end

    local base_notify = vim.notify
    vim.notify = function(msg, level, opts)
      local resolved_opts, resolved_level = _G.notify_policy(msg, level, opts)
      if resolved_opts == nil then
        return
      end
      return base_notify(msg, resolved_level, resolved_opts)
    end

    _G.toggle_notifications = function()
      _G.notifications_muted = not _G.notifications_muted
      _G.toggle_states = _G.toggle_states or {}
      _G.toggle_states["<leader>tN"] = not _G.notifications_muted
      if _G.update_toggle_desc then
        _G.update_toggle_desc("<leader>tN", "Notifications", not _G.notifications_muted)
      end
      -- Announced at ERROR level so the "muted" message itself gets through.
      base_notify(
        _G.notifications_muted and "Notifications muted (errors still shown)" or "Notifications unmuted",
        levels.INFO,
        { timeout = 2000 }
      )
    end
  '';

  # Notification management. <leader>Nl is the one worth remembering: it brings
  # back the message that just faded before you could read it.
  vim.luaConfigRC.notify-keybinds = ''
    vim.keymap.set("n", "<leader>Nd", function()
      require("notify").dismiss({ silent = true, pending = true })
      pcall(vim.cmd, "NoiceDismiss")
    end, { desc = "󰅖 Dismiss All Notifications" })

    vim.keymap.set("n", "<leader>Nh", function()
      require("telescope").extensions.notify.notify()
    end, { desc = "󰋚 Notification History" })

    vim.keymap.set("n", "<leader>Nl", "<cmd>NoiceLast<CR>", { desc = "󰃀 Show Last Message" })
    vim.keymap.set("n", "<leader>Na", "<cmd>Noice<CR>", { desc = "󰍩 All Messages" })
    vim.keymap.set("n", "<leader>Ne", "<cmd>Noice errors<CR>", { desc = "󰅚 Errors Only" })
  '';
}
