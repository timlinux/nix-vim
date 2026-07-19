# First Launch

When timvim opens for the first time you are greeted by the
[alpha dashboard](dashboard.md) — a Kartoza-branded start screen with quick
actions for creating, finding and restoring files. From here you can jump
straight into editing.

## Everything is already wired up

Because timvim is built declaratively with Nix, there is no plugin manager to
run and nothing to bootstrap. The editor ships complete:

- **Language servers and formatters** are on the editor's `PATH` from the
  first launch — no `:Mason` step, no manual installs. Open a supported file
  and the LSP attaches automatically.
- **Fuzzy finding, git tooling, treesitter and the UI** are all pre-configured.

!!! info "Supported languages out of the box"
    Python (pyright, black), Nix (nixd, nixfmt), Lua (stylua), Shell (shfmt),
    Web/Markdown (prettier) and Java (google-java-format), among others.

## Copilot needs Node.js

GitHub Copilot ghost-text completion requires Node.js 22+. This is bundled with
the timvim package and the Home Manager module, so it works automatically when
you install timvim the supported way.

!!! warning "Running Neovim outside the wrapper"
    If you launch a plain `nvim` that is not the wrapped timvim package, Node.js
    may not be on your `PATH` and Copilot will not start. Use `nix run`, the
    built package, or the Home Manager install so the bundled Node.js is
    available.

## Opening the which-key menu

timvim uses the ++space++ key as its **leader**. Press ++space++ in normal mode
and pause — a which-key popup lists every available command group (git, find,
Claude Code, refactoring, toggles and more) with icons and descriptions.

!!! tip "Discoverability first"
    You do not need to memorise keybindings. Press ++space++, read the menu,
    and drill down. For example `<leader>ff` finds files and `<leader>ac`
    toggles the Claude Code chat.

## Where to get help

- Press ++space++ to browse the which-key menu.
- Run `:help` inside Neovim for the built-in documentation.
- Browse this handbook for guides on features and keybindings.
- File issues or questions at
  [github.com/timlinux/nix-vim](https://github.com/timlinux/nix-vim).

Next, get to know the [dashboard](dashboard.md).
