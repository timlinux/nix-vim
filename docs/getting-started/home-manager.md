# Home Manager Integration

For a permanent install, add timvim to your [Home Manager](https://github.com/nix-community/home-manager)
configuration. The flake exposes two things you can use:

- `packages.${system}.default` — the wrapped Neovim package, ready to drop into
  `home.packages`.
- `homeModules.default` — a Home Manager module that installs timvim together
  with its companion tooling (formatters, language servers, Node.js for
  Copilot, and more).

!!! info "Which should I use?"
    Add `packages.${system}.default` if you only want the editor. Import
    `homeModules.default` if you also want the bundled development tools on your
    `PATH`.

## Add the flake input

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    timvim.url = "github:timlinux/nix-vim";
  };
}
```

## Standalone Home Manager (package only)

```nix
{
  outputs = { nixpkgs, home-manager, timvim, ... }: {
    homeConfigurations."yourname" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        {
          home.packages = [ timvim.packages.x86_64-linux.default ];
        }
      ];
    };
  };
}
```

## Using the Home Manager module

To pull in timvim plus its full toolchain, import the provided module:

```nix
{
  outputs = { nixpkgs, home-manager, timvim, ... }: {
    homeConfigurations."yourname" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        timvim.homeModules.default
      ];
    };
  };
}
```

## NixOS with the Home Manager module

When Home Manager runs as a NixOS module, reference the package through the
current system:

```nix
{ inputs, pkgs, ... }:
{
  home-manager.users.yourname = {
    home.packages = [ inputs.timvim.packages.${pkgs.system}.default ];
  };
}
```

!!! tip "Rebuild to apply"
    After editing your configuration, run `home-manager switch` (or your usual
    `nixos-rebuild switch`) to make `nvim` point at timvim.

Once installed, continue to [First Launch](first-launch.md).
