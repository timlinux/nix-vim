{ ... }:

{
  vim = {
    # Python-specific settings.
    #
    # This module used to redefine the whole <leader>z spell keymap set
    # buffer-locally (identical to the global ones in core/keymaps.nix) and
    # inject a page of `syn region` / `syn match` rules to get spell checking
    # inside strings and comments. Treesitter highlighting is enabled, so nvf
    # leaves `syntax on` off -- those rules were re-arming the regex syntax
    # engine on every Python buffer to reproduce what treesitter's @spell
    # captures already do.
    pluginRC.python-setup = ''
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'python',
        group = vim.api.nvim_create_augroup('PythonSpellSettings', { clear = true }),
        callback = function()
          local opt = vim.opt_local
          -- Treesitter's @spell captures restrict this to comments/docstrings.
          opt.spell = true
          opt.spelllang = 'en_us'
          opt.spelloptions = 'camel' -- Also check camelCase words
        end,
      })
    '';
  };
}
