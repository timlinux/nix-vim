# Installation

timvim is distributed as a Nix flake, so you can try it, build it or run it
locally without touching your existing Neovim setup.

## Prerequisites

!!! info "You will need"
    - **Nix** with flakes enabled (see below).
    - A **Nerd Font** (for example JetBrainsMono Nerd Font) so icons render
      correctly. timvim bundles JetBrains Mono Nerd Font, but your terminal
      must be set to use a Nerd Font.
    - A **Kitty-compatible terminal** if you want inline image preview via the
      Kitty graphics protocol.

## Install Nix and enable flakes

If you do not already have Nix, install it with the official installer:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Then enable flakes by adding this line to `~/.config/nix/nix.conf`:

```ini
experimental-features = nix-command flakes
```

Restart your shell afterwards so the change takes effect.

!!! tip "Determinate Systems installer"
    The [Determinate Systems installer](https://install.determinate.systems)
    enables flakes for you out of the box:

    ```bash
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    ```

## Run without installing

The quickest way to try timvim is to run it straight from GitHub:

```bash
nix run github:timlinux/nix-vim
```

This downloads and launches the editor without changing anything on your
system.

## Clone and run locally

To hack on the configuration, clone the repository and run from the checkout:

```bash
git clone https://github.com/timlinux/nix-vim.git
cd nix-vim
nix run
```

## Build the package

To produce the wrapped Neovim package (a `result` symlink) without launching:

```bash
nix build
```

The build output is a self-contained Neovim with all runtime dependencies —
ripgrep, fd, fzf, git, language servers and Node.js — already on its `PATH`.

!!! note "First run is slower"
    The initial `nix run` or `nix build` fetches and builds the closure. Once
    it is in your Nix store, subsequent launches are near-instant.

## Next steps

For a permanent install, see [Home Manager](home-manager.md). To learn what you
will see on start-up, head to [First Launch](first-launch.md).
