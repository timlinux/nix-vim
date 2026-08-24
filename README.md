# timvim

A beautiful, fully-featured Neovim configuration built with
[NVF (Neovim Flake)](https://github.com/notashelf/nvf) and Nix. Experience the
power of declarative configuration with modern development tools, AI
integration, and comprehensive language support.

> timvim began as a fork of the excellent
> [**Schrovimger**](https://github.com/jack-thesparrow/schrovimger) project by
> [**Rahul Tudu (jack-thesparrow)**](https://github.com/jack-thesparrow), which
> provides the vast majority of the original source. See
> [Acknowledgements](#-acknowledgements).

## ✨ Features

Testing the fastestdd

- **🎨 Modern UI**: Beautiful themes with statusline, notifications, and
  enhanced visuals
- **🧠 AI Integration**: Built-in Claude Code support with chat interface and
  ghost text completion
- **📝 Language Support**: Full LSP setup with treesitter, formatting, and
  debugging for Python, Nix, Lua, and more
- **🔍 Fuzzy Finding**: FZF and Telescope for lightning-fast navigation
- **📦 Declarative**: Everything configured through Nix expressions - no
  traditional Lua config files
- **🚀 Fast**: Optimized startup time and performance
- **🔧 Extensible**: Modular architecture makes customization simple

## 🚀 Quick Start

### Prerequisites

You need **Nix** with flakes enabled. Follow the platform-specific instructions
below to install Nix.

---

## 📦 Platform Installation

### 🐧 Linux (Ubuntu/Debian/Fedora/Arch)

#### 1. Install Nix

```bash
# Official Nix installer (recommended)
sh <(curl -L https://nixos.org/nix/install) --daemon

# Or use the Determinate Systems installer (better defaults)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

#### 2. Enable Flakes

If you used the official installer, enable flakes by adding to
`~/.config/nix/nix.conf`:

```ini
experimental-features = nix-command flakes
```

Then restart your shell or run `source /etc/profile`.

#### 3. Run timvim

```bash
# Try without installing
nix run github:timlinux/timvim

# Or clone and run locally
git clone https://github.com/timlinux/timvim.git
cd timvim
nix run
```

#### Distribution-Specific Notes

**Ubuntu/Debian:**

```bash
# You may need to add yourself to the nix-users group
sudo usermod -aG nix-users $USER
# Log out and back in for group changes to take effect
```

**Fedora:**

```bash
# SELinux may require restorecon after install
sudo restorecon -RF /nix
```

**Arch Linux:**

```bash
# Alternative: install via pacman
sudo pacman -S nix
sudo systemctl enable --now nix-daemon
```

**NixOS:**

```nix
# In your configuration.nix or home.nix
{
  inputs.timvim.url = "github:timlinux/timvim";

  # Add to environment.systemPackages or home.packages
  environment.systemPackages = [ inputs.timvim.packages.${pkgs.system}.default ];
}
```

---

### 🍎 macOS

#### 1. Install Nix

```bash
# Determinate Systems installer (recommended for macOS)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Or official installer
sh <(curl -L https://nixos.org/nix/install)
```

#### 2. Enable Flakes (if using official installer)

Add to `~/.config/nix/nix.conf`:

```ini
experimental-features = nix-command flakes
```

#### 3. Run timvim

```bash
# Try without installing
nix run github:timlinux/timvim

# Or clone and run
git clone https://github.com/timlinux/timvim.git
cd timvim
nix run
```

#### macOS-Specific Notes

- **Apple Silicon (M1/M2/M3)**: Fully supported, Nix automatically uses
  `aarch64-darwin`
- **Intel Macs**: Uses `x86_64-darwin`
- **Rosetta 2**: Not required; native ARM builds are provided
- **Clipboard**: Uses `pbcopy`/`pbpaste` automatically

---

### 🪟 Windows

Nix runs on Windows through **WSL2** (Windows Subsystem for Linux).

#### 1. Install WSL2

Open PowerShell as Administrator:

```powershell
wsl --install
```

This installs Ubuntu by default. Restart your computer when prompted.

#### 2. Configure WSL2 (recommended settings)

Create or edit `%USERPROFILE%\.wslconfig`:

```ini
[wsl2]
memory=8GB
processors=4
```

#### 3. Install Nix in WSL2

Open your WSL terminal (Ubuntu):

```bash
# Install Nix with Determinate Systems installer
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Restart your shell
exec $SHELL
```

#### 4. Run timvim

```bash
# In WSL terminal
nix run github:timlinux/timvim

# Or clone and run
git clone https://github.com/timlinux/timvim.git
cd timvim
nix run
```

#### Windows-Specific Notes

- **Windows Terminal**: Recommended for best experience with colors and fonts
- **Clipboard Integration**: Works between WSL and Windows automatically
- **File Access**: Access Windows files at `/mnt/c/Users/YourName/`
- **Performance**: Store projects in WSL filesystem (`~/`) not Windows mounts
  for best performance
- **GPU Support**: WSL2 supports GPU passthrough for compatible features

#### Recommended Windows Terminal Settings

Add to your Windows Terminal `settings.json` for best experience:

```json
{
  "profiles": {
    "defaults": {
      "font": {
        "face": "JetBrainsMono Nerd Font",
        "size": 12
      },
      "colorScheme": "One Half Dark"
    }
  }
}
```

Install a Nerd Font from [nerdfonts.com](https://www.nerdfonts.com/) for icon
support.

---

## 🏠 Home Manager Integration

For permanent installation via Home Manager:

### Standalone Home Manager

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    timvim.url = "github:timlinux/timvim";
  };

  outputs = { nixpkgs, home-manager, timvim, ... }: {
    homeConfigurations."yourname" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [{
        home.packages = [ timvim.packages.x86_64-linux.default ];
      }];
    };
  };
}
```

### NixOS with Home Manager Module

```nix
# configuration.nix
{ inputs, pkgs, ... }:
{
  home-manager.users.yourname = {
    home.packages = [ inputs.timvim.packages.${pkgs.system}.default ];
  };
}
```

### nix-darwin (macOS)

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    timvim.url = "github:timlinux/timvim";
  };

  outputs = { darwin, timvim, ... }: {
    darwinConfigurations."yourmac" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";  # or x86_64-darwin for Intel
      modules = [{
        environment.systemPackages = [ timvim.packages.aarch64-darwin.default ];
      }];
    };
  };
}
```

## 🏗️ Architecture

```
config/
├── core/          # Core Neovim settings (options, keymaps, clipboard)
├── plugins/       # Plugin configurations (LSP, telescope, git)
├── themes/        # Color schemes and theming
├── ui/           # UI enhancements (statusline, notifications)
├── utility/      # Utility plugins (surround, flash navigation)
└── assistant/    # AI assistant tools (Claude Code)
```

## 🎯 Key Bindings

| Key           | Action                                 |
| ------------- | -------------------------------------- |
| `<leader>ac`  | Toggle Claude Code chat                |
| `<leader>af`  | Focus Claude terminal                  |
| `<leader>acs` | Select Claude model                    |
| `<leader>am`  | Send selection to Claude (visual mode) |
| `<leader>ff`  | Find files                             |
| `<leader>fg`  | Live grep                              |
| `<leader>gg`  | Open LazyGit                           |

## Clipboard Integration

Timvim provides seamless clipboard integration between Neovim and the system:

### Copying (Yank)

| Action               | Result                                                |
| -------------------- | ----------------------------------------------------- |
| `y` (yank)           | Copies to both system clipboard AND primary selection |
| Mouse highlight text | Copies to primary selection (middle-click paste)      |
| `"+y`                | Explicitly yank to system clipboard                   |
| `"*y`                | Explicitly yank to primary selection                  |

### Pasting

| Action             | Result                                         |
| ------------------ | ---------------------------------------------- |
| `p`                | Paste from default register (last yank/delete) |
| `"+p`              | Paste from system clipboard                    |
| `"*p`              | Paste from primary selection                   |
| `Ctrl+Shift+V`     | Paste system clipboard (insert/command mode)   |
| Middle mouse click | Paste from primary selection                   |

This uses `wl-copy`/`wl-paste` for Wayland clipboard support.

## 🛠️ Development

```bash
# Enter development environment
nix develop

# Run quality checks
nix flake check

# Format code
nix fmt

# Check for dead code
deadnix check .

# Style checks
statix check .
```

## 🎨 Customization

### Adding Plugins

1. Create a new `.nix` file in the appropriate `config/` subdirectory
2. Add the import to the subdirectory's `default.nix`
3. Use NVF's plugin configuration syntax

### Updating the Startup Banner

The Kartoza logo on the alpha dashboard is generated using `catimg` and
`term2alpha`. To regenerate or replace it:

1. **Install the tools**:
   - `catimg` is available in nixpkgs: `nix shell nixpkgs#catimg`
   - `term2alpha` must be built from source:
     `git clone https://git.sr.ht/~zethra/term2alpha && cargo build --release`

2. **Generate the header Lua code**:

   ![kartoza-logo.png](https://raw.githubusercontent.com/timlinux/timvim/main/kartoza-logo.png)

   ```bash
   catimg -H 30 kartoza-logo.png | term2alpha > /tmp/header.lua
   ```

   - `-H 30` controls the height in terminal lines (adjust to taste)
   - `term2alpha` only supports 24-bit color codes from `catimg` output
   - Other terminal image renderers (like chafa) produce different ANSI codes
     that may not be compatible

3. **Integrate into alpha.nix**:
   - The generated `header.lua` contains two sections:
     - Highlight group definitions (`vim.api.nvim_set_hl(...)` calls)
     - A header table with `val` (text lines) and `opts.hl` (per-line highlight
       specs)
   - Copy both sections into `config/plugins/alpha.nix`, replacing the existing
     highlight groups and `dashboard.section.header` block

4. **Build and test**: `nix run`

### Modifying Settings

- **Core options**: Edit files in `config/core/`
- **Plugin settings**: Edit corresponding files in `config/plugins/`
- **Keymaps**: Modify `config/core/keymaps.nix`
- **Themes**: Update `config/themes/theme.nix`

## 📋 Supported Languages

- **Python**: LSP (pyright), formatting (black), debugging
- **Nix**: LSP (nixd), formatting (nixfmt-rfc-style), linting
- **Lua**: Formatting (stylua)
- **Shell**: Formatting (shfmt)
- **Web**: HTML, CSS, JavaScript, Markdown (prettier)
- **Java**: Formatting (google-java-format)

## 🙏 Acknowledgements

timvim stands on the shoulders of others' work. Our sincere thanks to:

- [**Schrovimger** · Rahul Tudu (jack-thesparrow)](https://github.com/jack-thesparrow/schrovimger)
  — the base project this repository was forked from; it provides the vast
  majority of the original source.
- [**NVF (Neovim Flake)** · NotAShelf](https://github.com/notashelf/nvf) — the
  excellent declarative framework timvim is built on.
- [**Sly-Harvey**](https://github.com/Sly-Harvey) — for a clean, readable nixvim
  config used as reference.
- [**elythh/nixvim**](https://github.com/elythh/nixvim) — for feature ideas.
- [**zethra**](https://git.sr.ht/~zethra/) — for the `term2alpha` tool used to
  render the alpha dashboard.
- [**Nix**](https://nixos.org/) — the reproducible build foundation.

## 📄 License

MIT License - see [LICENSE](LICENSE) for details. The original copyright is held
by jack-thesparrow (Rahul Tudu).

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

---

<div align="center">

Made with 💗 by [Kartoza](https://kartoza.com) |
[Donate!](https://github.com/sponsors/timlinux) |
[GitHub](https://github.com/timlinux/timvim)

Forked from [Schrovimger](https://github.com/jack-thesparrow/schrovimger), built
using [NVF](https://github.com/notashelf/nvf) and [Nix](https://nixos.org/)

</div>
