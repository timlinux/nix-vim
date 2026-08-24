{
  vim.utility = {
    images = {
      image-nvim = {
        enable = true;
        setupOpts = {
          backend = "kitty";
          integrations = {
            markdown = {
              enabled = true;
              clear_in_insert_mode = false;
              download_remote_images = true;
              only_render_image_at_cursor = true;
              only_render_image_at_cursor_mode = "popup";
              filetypes = [
                "markdown"
                "vimwiki"
              ];
            };
            neorg = {
              enabled = true;
              clear_in_insert_mode = false;
              download_remote_images = true;
              only_render_image_at_cursor = true;
              only_render_image_at_cursor_mode = "popup";
              filetypes = [ "norg" ];
            };
          };
          # Scale down images before rendering
          scale_factor = 0.4;
          window_overlap_clear_enabled = true;
          window_overlap_clear_ft_ignore = [
            "cmp_menu"
            "cmp_docs"
            "which-key"
            "notify"
            "cmdline"
            "popup"
            ""
          ];
          # Was declared twice: `editorOnlyRenderWhenFocused = true` (camelCase,
          # not an image.nvim option, silently ignored) and this one set to the
          # opposite. Kitty graphics writes escape sequences straight to the tty,
          # so rendering while unfocused is a live screen-corruption risk.
          editor_only_render_when_focused = true;
          tmux_show_only_in_active_window = true;
        };
      };
      img-clip.enable = true;
    };
  };
}
