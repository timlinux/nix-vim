{ ... }:

{
  # See https://github.com/3rd/image.nvim
  # Image preview configuration using Kitty graphics protocol
  # The main image.nvim plugin is configured in config/utility/image-nvim.nix
  # Global toggle keymap <leader>tI is in config/core/keymaps.nix
  vim = {
    pluginRC.image-nvim-setup = ''
      -- Initialize image preview state
      _G.toggle_states = _G.toggle_states or {}
      _G.image_preview_enabled = true

      -- Track windows we've processed (must be defined before close_image_popup_windows)
      local processed_wins = {}

      -- Toggle image preview function
      _G.toggle_image_preview = function()
        local ok, img = pcall(require, 'image')
        if not ok then
          vim.notify('image.nvim not loaded', vim.log.levels.ERROR)
          return
        end

        if img.is_enabled() then
          img.disable()
          _G.image_preview_enabled = false
          vim.notify('Image preview disabled', vim.log.levels.INFO)
        else
          img.enable()
          _G.image_preview_enabled = true
          vim.notify('Image preview enabled', vim.log.levels.INFO)
        end

        -- Update toggle state for whichkey
        _G.toggle_states['<leader>tI'] = not _G.image_preview_enabled
        if _G.update_toggle_desc then
          _G.update_toggle_desc('<leader>tI', 'Image Preview', _G.image_preview_enabled)
        end
      end

      -- Close all image popup floating windows
      local function close_image_popup_windows()
        local current_win = vim.api.nvim_get_current_win()
        for _, win_id in ipairs(vim.api.nvim_list_wins()) do
          if win_id ~= current_win then
            local ok, config = pcall(vim.api.nvim_win_get_config, win_id)
            if ok and config.relative and config.relative ~= "" then
              -- This is a floating window - check if it's an image popup
              local buf = vim.api.nvim_win_get_buf(win_id)
              local buf_name = vim.api.nvim_buf_get_name(buf)
              -- Image.nvim creates floating windows with empty buffer names
              if buf_name == "" then
                pcall(vim.api.nvim_win_close, win_id, true)
                processed_wins[win_id] = nil
              end
            end
          end
        end
      end

      -- Clear/hide images function
      _G.hide_image_preview = function()
        local ok, img = pcall(require, 'image')
        if ok then
          img.clear()
        end
        -- Also close the popup windows
        close_image_popup_windows()
      end

      -- Clear images in current buffer keymap
      vim.keymap.set('n', '<leader>ic', function()
        _G.hide_image_preview()
        vim.notify('Images cleared', vim.log.levels.INFO)
      end, { desc = '󰹍 Clear Images in Buffer' })

      -- Escape key clears image preview (in markdown files)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'markdown', 'vimwiki', 'norg' },
        callback = function()
          vim.keymap.set('n', '<Esc>', function()
            _G.hide_image_preview()
            -- Also run normal Esc behavior (clear search highlight, etc.)
            vim.cmd('nohlsearch')
          end, { buffer = true, desc = '󰹍 Clear images and search highlight' })
        end,
      })

      -- Reposition a floating window to bottom right corner (preserve image.nvim sizing)
      local function reposition_to_bottom_right(win_id)
        if not vim.api.nvim_win_is_valid(win_id) then return false end
        if processed_wins[win_id] then return false end

        local ok, config = pcall(vim.api.nvim_win_get_config, win_id)
        if not ok then return false end

        -- Only reposition floating windows
        if not config.relative or config.relative == "" then return false end

        -- Get current window size (let image.nvim control sizing via scale_factor)
        local win_width = config.width or vim.api.nvim_win_get_width(win_id)
        local win_height = config.height or vim.api.nvim_win_get_height(win_id)

        -- Get editor dimensions
        local editor_width = vim.o.columns
        local editor_height = vim.o.lines - vim.o.cmdheight - 1

        -- Calculate bottom right position with padding
        local padding = 2
        local new_row = editor_height - win_height - padding
        local new_col = editor_width - win_width - padding

        -- Ensure we don't go negative
        new_row = math.max(0, new_row)
        new_col = math.max(0, new_col)

        -- Reposition to bottom right corner (don't change size)
        local success = pcall(vim.api.nvim_win_set_config, win_id, {
          relative = 'editor',
          row = new_row,
          col = new_col,
        })

        if success then
          processed_wins[win_id] = true
          return true
        end
        return false
      end

      -- Find and reposition image popup windows
      local function find_and_reposition_image_popups()
        local current_win = vim.api.nvim_get_current_win()

        for _, win_id in ipairs(vim.api.nvim_list_wins()) do
          -- Skip current window and already processed windows
          if win_id ~= current_win and not processed_wins[win_id] then
            local ok, config = pcall(vim.api.nvim_win_get_config, win_id)
            if ok and config.relative and config.relative ~= "" then
              -- This is a floating window - check if it's an image popup
              local buf = vim.api.nvim_win_get_buf(win_id)
              local buf_name = vim.api.nvim_buf_get_name(buf)

              -- Image.nvim creates floating windows with empty buffer names
              -- and minimal style for image popups
              if buf_name == "" then
                reposition_to_bottom_right(win_id)
              end
            end
          end
        end
      end

      -- Clean up tracking when windows close
      vim.api.nvim_create_autocmd('WinClosed', {
        callback = function(args)
          local win_id = tonumber(args.match)
          if win_id then
            processed_wins[win_id] = nil
          end
        end,
      })

      -- Use multiple events to catch image popup creation
      local group = vim.api.nvim_create_augroup('ImagePopupReposition', { clear = true })

      -- Poll for new floating windows after cursor events in markdown files.
      --
      -- This used to queue three defer_fn timers per event, so holding `j` in a
      -- markdown buffer stacked three window scans per line. One debounced
      -- timer catches the popup just as well without the pile-up.
      local reposition_timer = nil
      local function schedule_reposition()
        if reposition_timer then
          reposition_timer:stop()
        end
        reposition_timer = vim.defer_fn(function()
          reposition_timer = nil
          find_and_reposition_image_popups()
        end, 150)
      end

      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorMoved' }, {
        group = group,
        pattern = { '*.md', '*.markdown', '*.norg', '*.wiki' },
        callback = schedule_reposition,
      })

      -- Also check when any window is created
      vim.api.nvim_create_autocmd('WinNew', {
        group = group,
        callback = schedule_reposition,
      })
    '';
  };
}
