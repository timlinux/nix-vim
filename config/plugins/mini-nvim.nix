{ pkgs, ... }:
{
  vim = {
    startPlugins = [
      pkgs.vimPlugins.mini-nvim
    ];
    # mini.pairs is the only autopair provider. nvim-autopairs used to be set
    # up alongside it in core/autopairs.nix, so both plugins inserted closing
    # characters on the same keystroke.
    pluginRC.mini-pairs = ''
      require('mini.pairs').setup()
    '';
    pluginRC.mini-colors = ''
      require('mini.colors').setup()
      -- You can use :lua MiniColors.pick() to pick a color
      vim.keymap.set("n", "<leader>cp", function() require('mini.colors').pick() end, { desc = "󰏘 Pick Color" })
    '';
  };
}
