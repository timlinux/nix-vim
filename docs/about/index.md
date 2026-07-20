# About timvim

<span class="kz-eyebrow">KARTOZA · NEOVIM</span>

**timvim** is a fully declarative, Nix-built Neovim configuration. It bundles a
modern editing experience — LSP, treesitter, formatting, debugging, fuzzy
finding, git tooling and optional AI assistance — into a single reproducible
package, dressed in the Kartoza brand.

It is built on the [NVF (Neovim Flake)](https://github.com/notashelf/nvf)
framework, which lets an entire Neovim setup be expressed as Nix modules. There
are no hand-written Lua config files to maintain and no plugin manager to keep in
sync — the flake describes the whole editor, and Nix builds it.

timvim began as a fork of the
[Schrovimger](https://github.com/jack-thesparrow/schrovimger) project by
[Rahul Tudu (jack-thesparrow)](https://github.com/jack-thesparrow), which
provides the bulk of the original source. timvim adds the Kartoza brand,
tooling and documentation on top. Our thanks to Rahul, and to
[NotAShelf](https://github.com/notashelf/nvf) for the NVF framework.

## Philosophy

timvim is guided by three principles that pull in the same direction.

<div class="grid cards" markdown>

-   :material-file-cog:{ .lg .middle } **Declarative**

    ---

    Every plugin, keybinding, language server and theme is defined in Nix
    expressions under `config/`. The configuration is the documentation, and the
    documentation is the configuration.

-   :material-cube-outline:{ .lg .middle } **Reproducible**

    ---

    The same flake produces the same editor on Linux, macOS and WSL2. Runtime
    tools travel inside the closure, so there is no "works on my machine" — it
    works everywhere the flake is run.

-   :material-palette-outline:{ .lg .middle } **Beautiful**

    ---

    A calm, consistent Kartoza-branded interface: a powerline bubble statusline,
    amber UI accents and a themed dashboard. Beauty, consistency and efficiency
    are pursued together, never traded against each other.

</div>

## The NVF + Nix foundation

timvim's flake wires together a small number of moving parts:

- **NVF** turns declarative Nix modules into a working Neovim, resolving plugins
  and their settings for you.
- **Nix flakes** pin every input — nixpkgs, NVF and a handful of upstream plugins
  such as Claude Code and Octo — so builds are pinned and repeatable.
- **A wrapped Neovim** ships its runtime dependencies (ripgrep, fd, fzf, git, Go
  tooling, Node.js and more) on `PATH`, so plugins that shell out just work.
- **Home Manager and NixOS integration** via `homeModules.default` makes a
  permanent install a one-liner.

The handbook you are reading is itself built with Material for MkDocs using the
Kartoza brand pack, and can be assembled into a branded PDF from the same source.

## In this section

<div class="grid cards" markdown>

-   :material-clipboard-text-outline:{ .lg .middle } **Specification**

    ---

    Goals, non-goals, an architecture summary and the supported languages and
    tooling.

    [:material-arrow-right: Read the specification](specification.md)

-   :material-palette-swatch:{ .lg .middle } **Design Aesthetic**

    ---

    The Kartoza palette, the powerline statusline, amber UI borders and the
    bubble tabline.

    [:material-arrow-right: See the design](design.md)

-   :material-robot-outline:{ .lg .middle } **Using AI**

    ---

    How Copilot and Claude Code are used — transparently, optionally and under
    your control.

    [:material-arrow-right: Read the AI policy](ai-policy.md)

-   :material-heart:{ .lg .middle } **Sponsors**

    ---

    Help keep timvim sustainable through GitHub Sponsors.

    [:material-arrow-right: Support the project](sponsors.md)

</div>

<p class="kz-footer-credits" markdown>Made with 💗 by [Kartoza](https://kartoza.com) · [Donate!](https://github.com/sponsors/timlinux) · [GitHub](https://github.com/timlinux/nix-vim)</p>
