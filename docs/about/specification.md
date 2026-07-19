# Specification Overview

<span class="kz-eyebrow">KARTOZA · NEOVIM</span>

This page gives a concise overview of what timvim sets out to be and how it is
put together. It is a high-level summary; a complete `SPECIFICATION.md` lives in
the repository root and is the authoritative source when the two differ.

## Goals

- **Declarative by default.** The entire editor — plugins, options, keymaps,
  language servers, formatters and theme — is expressed in Nix modules under
  `config/`, with no hand-maintained Lua config files.
- **Reproducible everywhere.** The same flake yields the same editor on Linux,
  macOS and WSL2, with runtime tools carried inside the build closure.
- **Batteries included.** LSP, treesitter, formatting, debugging, fuzzy finding,
  git tooling and optional AI assistance are configured and working on first
  launch.
- **Beautiful and consistent.** A Kartoza-branded UI with a powerline bubble
  statusline, amber accents and a themed dashboard.
- **Discoverable.** A which-key menu covers the shortcuts, so nothing has to be
  memorised.
- **Optional, user-controlled AI.** AI assistance is available but never forced.

## Non-goals

- **Not a plugin manager.** timvim does not layer a runtime plugin manager on top
  of Nix; the flake is the single source of truth.
- **Not a general framework.** It is an opinionated, ready-to-use configuration,
  not a toolkit for building arbitrary Neovim distributions.
- **No imperative, machine-local tweaking as the primary path.** Customisation
  flows through editing Nix modules and rebuilding, not ad-hoc runtime edits.
- **Not tied to a single OS.** Nothing assumes a particular Linux distribution;
  platform specifics are handled by Nix.

## Architecture summary

The configuration follows NVF's modular approach. Modules live under `config/`
and are composed through per-directory `default.nix` files:

| Area | Directory | Responsibility |
| --- | --- | --- |
| Core | `config/core/` | Options, keymaps, clipboard, formatting, sessions, which-key |
| Plugins | `config/plugins/` | LSP, telescope, fzf, git, debugging, treesitter, dashboards |
| Themes | `config/themes/` | Kartoza colour scheme and theming |
| UI | `config/ui/` | Statusline, tabline, notifications, indentation guides, folds |
| Utility | `config/utility/` | Surround, flash motion, refactoring, splits, previews |
| Assistant | `config/assistant/` | Claude Code and Copilot integration |

The flake (`flake.nix`) builds a **wrapped Neovim** via NVF's
`neovimConfiguration`, then bundles runtime dependencies onto `PATH` so plugins
that shell out (ripgrep, fd, fzf, git, Go tooling, Node.js and more) work without
extra setup. The flake also exposes:

- `packages.default` / `apps.default` — build and launch timvim.
- `homeModules.default` — Home Manager and NixOS integration.
- `devShells.default` — a development shell with all formatters, linters and
  language tools.
- `apps.handbook*` — serve, build and render this handbook (including a
  Kartoza-branded PDF).
- `checks` — formatting (`nixfmt-rfc-style`), dead-code (`deadnix`) and style
  (`statix`) gates run by `nix flake check`.

## Supported languages and tooling

| Language | LSP | Formatting | Debug / extras |
| --- | --- | --- | --- |
| Python | pyright | black | debugpy |
| Nix | nixd | nixfmt-rfc-style | deadnix, statix |
| Lua | — | stylua | — |
| Go | gopls | goimports (gotools) | delve |
| Shell | — | shfmt | — |
| Web (HTML/CSS/JS/Markdown) | — | prettier | — |
| Java | — | google-java-format | — |
| RST / Sphinx | — | — | rstcheck, doc8 |

Cross-cutting tooling includes treesitter for syntax, conform.nvim for
formatting, Telescope and FZF for navigation, comprehensive git integration,
session and project management, and the Harper grammar LSP.

!!! info "Where the detail lives"
    Keybindings are documented in the [Keybindings](../reference/index.md)
    reference; day-to-day workflows in the [User Guide](../user-guide/index.md);
    and the build and contribution model in the
    [Developer Guide](../developer-guide/index.md).
