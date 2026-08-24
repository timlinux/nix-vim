{
  vim.formatter.conform-nvim = {
    enable = true;

    setupOpts = {
      default_format_opts = {
        lsp_format = "fallback";
      };
      formatters_by_ft = {
        java = [ "google-java-format" ];
        python = [ "black" ];
        nix = [ "nixfmt" ];
        lua = [ "stylua" ];
        bash = [ "shfmt" ];
        sh = [ "shfmt" ];
        markdown = [ "prettier" ];
        mdx = [ "prettier" ];
        rst = [ "rstfmt" ];
        rust = [ "rustfmt" ];
        go = [
          "goimports"
          "gofmt"
        ];
      };
      # format_after_save, not format_on_save: the on-save variant blocks the
      # write while the formatter runs, which is felt on every autosave. This
      # runs the formatter asynchronously and writes the result back.
      format_after_save = {
        lsp_format = "fallback";
      };
    };
  };
}
