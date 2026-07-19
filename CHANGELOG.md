<!--
SPDX-FileCopyrightText: 2026 Kartoza (Pty) Ltd <tim@kartoza.com>
SPDX-License-Identifier: MIT
-->
# Changelog

All notable changes to **timvim** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-07-19

### Added

- **Documentation handbook** — a Kartoza-branded [Material for MkDocs] site with
  a full user guide, keybindings reference, developer guide and about section,
  published to GitHub Pages on every merge to `main`.
- **PDF handbook** — a Kartoza-branded PDF built with pandoc + TeXLive
  (`nix run .#handbook-pdf`), attached to every release as a long-lived asset and
  produced as a short-lived artifact on every pull request.
- **Config-driven keymap docs** — the keymap tables, which-key group map,
  completion tables and keyboard-layout SVGs are generated from timvim's *live*
  keymaps at build time (`nix run .#handbook-keymaps`), so the documentation can
  never drift from the configuration.
- Brand-coloured SVG diagrams (architecture, leader-key map, six keyboard
  layouts, completion keys) using the timvim `kartozaColors` palette.
- **Software Bill of Materials** — `nix run .#sbom` produces CycloneDX + SPDX
  SBOMs (plus a CSV and a Markdown summary) for the runtime closure. CI uploads
  them as an artifact and surfaces the summary table in every PR comment;
  releases attach the CycloneDX + SPDX files and include the summary in the
  notes.
- `nix run .#handbook` and `nix run .#handbook-build` convenience apps.

### Changed

- Freshened all flake inputs (nixpkgs unstable, nvf on nixos 26.05, plugins) —
  resolves the blink-cmp Rust crate availability issue.
- Adapted the configuration to new nvf/nixpkgs schemas: lualine
  `disabledFiletypes`, clipboard register order, rust LSP `settings`, and the
  `prettier` package (`nodePackages` removed upstream).
- Stopped tracking `PROMPT.log` and `CLAUDE.md` (now gitignored; kept locally).
- Restricted the flake to Linux systems (`x86_64-linux`, `aarch64-linux`). The
  editor closure depends on Linux-native tooling (e.g. wayland) so it never
  evaluated on Darwin, and nixpkgs unstable (26.11) has dropped `x86_64-darwin`
  — this unbreaks `nix flake check --all-systems`.

### Fixed

- Guard unchecked `io.popen` handles in the DAP configuration that could crash
  `init.lua` when run headless — this had been silently dropping ~140 keymaps.
- Hide the statusline on the alpha dashboard via lualine `disabled_filetypes`.

[Material for MkDocs]: https://squidfunk.github.io/mkdocs-material/
[Unreleased]: https://github.com/timlinux/nix-vim/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/timlinux/nix-vim/compare/v0.2.0...v0.3.0
