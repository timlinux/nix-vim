# Developer Guide

This section is for contributors — anyone who wants to change how **timvim**
is built, add a plugin, adjust a keybinding, extend the handbook, or cut a
release. It assumes you are comfortable at the command line and have Nix with
flakes enabled; you do not need to be a Nix expert.

timvim is a fully declarative Neovim configuration. There are no hand-managed
Lua plugin lists and no plugin manager to babysit: every plugin, option and
keybinding is expressed as Nix through the [NVF](https://github.com/notashelf/nvf)
module system, and the whole editor is produced reproducibly by the flake.
Because of that, the contributor workflow is a little different from a
traditional `init.lua` setup — this guide explains it.

!!! info "The golden rule"
    Everything is declarative. If you find yourself wanting to edit a file
    inside the Nix store or drop a stray Lua file into your runtime path,
    stop — the change belongs in the `config/` tree and should flow through
    the flake so it stays reproducible for everyone.

## In this section

<div class="grid cards" markdown>

-   :material-sitemap: **Architecture** — How the `config/` tree is organised,
    how NVF composes the modules and how the wrapped Neovim is assembled.
    [Understand the layout](architecture.md)

-   :material-toolbox: **Dev Shell** — What `nix develop` gives you:
    formatters, linters, language servers and media tools.
    [Enter the shell](dev-shell.md)

-   :material-puzzle-plus: **Adding Plugins** — The workflow for adding a
    plugin and wiring up its keybindings and which-key entries.
    [Add a plugin](adding-plugins.md)

-   :material-hammer-wrench: **Building & Testing** — `nix build`, `nix run`,
    `nix flake check` and `nix fmt`, and what each one verifies.
    [Build and test](building.md)

-   :material-file-document-multiple: **The Docs Pipeline** — How this very
    handbook is served, built and rendered to a Kartoza-branded PDF.
    [Work on the docs](docs-pipeline.md)

-   :material-tag: **Release Process** — Version bumps, the changelog and the
    CI that publishes the site and attaches the PDF to releases.
    [Cut a release](release.md)

</div>

## Before you start

!!! tip "Work inside the flake"
    Run everything from within `nix develop` (see [Dev Shell](dev-shell.md)),
    or use the `nix run .#…` convenience apps directly. This guarantees you
    have exactly the same tool versions as CI, so a green check locally means
    a green check in the pipeline.

## The change process for keybindings

timvim has a **formal change process** for keybindings and which-key menus:
no binding or menu change is made without first presenting a before/after for
each atomic change and obtaining approval. This is not optional politeness —
it is a hard rule of the project. See
[Adding Plugins](adding-plugins.md#the-formal-change-process-for-keybindings)
for the full procedure before you touch any mapping.

---

Made with 💗 by [Kartoza](https://kartoza.com) &middot;
[Donate!](https://github.com/sponsors/timlinux) &middot;
[GitHub](https://github.com/timlinux/nix-vim)
