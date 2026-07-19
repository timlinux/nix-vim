# timvim

<div class="kz-hero" markdown>
<span class="kz-eyebrow">KARTOZA · NEOVIM</span>

# A declarative Neovim you'll actually enjoy

A fully Nix-built Neovim with LSP, AI assistance, git tooling and a Kartoza-branded UI — reproducible on every machine.

<div class="kz-cta" markdown>
[:material-rocket: Get started](getting-started/index.md){ .kz-cta__primary }
[:material-github: GitHub](https://github.com/timlinux/nix-vim){ .kz-cta__secondary }
</div>
</div>

timvim is a batteries-included Neovim configuration built with the
[NVF (Neovim Flake)](https://github.com/notashelf/nvf) framework. Everything —
plugins, language servers, formatters, AI assistance and theming — is described
declaratively in Nix, so the same flake produces the exact same editor on Linux,
macOS and WSL2. No plugin manager to babysit, nothing to compile by hand.

## Explore the handbook

<div class="grid cards" markdown>

-   :material-rocket-launch:{ .lg .middle } **Getting Started**

    ---

    Install Nix, enable flakes and launch timvim in a single command — then find
    your way around the dashboard.

    [:material-arrow-right: Get started](getting-started/index.md)

-   :material-book-open-variant:{ .lg .middle } **User Guide**

    ---

    Editing, motion, completion, AI, search, git, diagnostics, debugging and
    refactoring — the everyday workflows.

    [:material-arrow-right: Read the guide](user-guide/index.md)

-   :material-keyboard:{ .lg .middle } **Keybindings**

    ---

    The which-key menus, the full keymap and the harmonised completion keys, all
    in one reference.

    [:material-arrow-right: Browse keybindings](reference/index.md)

-   :material-wrench:{ .lg .middle } **Developer Guide**

    ---

    Architecture, the dev shell, adding plugins, building, testing and the docs
    pipeline for contributors.

    [:material-arrow-right: Start hacking](developer-guide/index.md)

</div>

## Why timvim

- **Declarative and reproducible** — the flake is the single source of truth.
  Roll it out to a fresh machine and get a byte-for-byte identical editor.
- **AI on your terms** — Claude Code chat and Copilot ghost text are wired in,
  but always optional and user-controlled.
- **Language-ready out of the box** — LSP, treesitter, formatting and debugging
  for Python, Nix, Lua, Go, shell, web and Java.
- **Fast navigation** — FZF and Telescope for fuzzy finding, flash motions and
  smart splits for getting around.
- **Kartoza-branded UI** — a powerline bubble statusline, amber UI borders and a
  themed dashboard that feels calm and consistent.
- **A which-key menu for everything** — discoverable shortcuts, no memorisation
  required.

!!! tip "New to Nix?"
    You only need Nix with flakes enabled. Head to
    [Getting Started](getting-started/index.md) and you will be running timvim in
    minutes.

<p class="kz-footer-credits" markdown>Made with 💗 by [Kartoza](https://kartoza.com) · [Donate!](https://github.com/sponsors/timlinux) · [GitHub](https://github.com/timlinux/nix-vim)</p>
