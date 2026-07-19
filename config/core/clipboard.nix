{ ... }:
{
  vim.clipboard = {
    enable = true;
    providers.wl-copy.enable = true;
    # "unnamedplus" syncs default register with system clipboard (+)
    # "unnamed" syncs default register with primary selection (*)
    # Using both ensures yanks go to both clipboards
    registers = "unnamed,unnamedplus";
  };
}
