<!--
SPDX-FileCopyrightText: 2026 Kartoza (Pty) Ltd <tim@kartoza.com>
SPDX-License-Identifier: MIT
-->
# Changelog

All notable changes to **timvim** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Startup smoke test** (`nix flake check`) — runs the built editor headless,
  fires the startup autocmds and fails on any Lua error, missing colorscheme
  or cleared highlight group. The Nix build only proved the config *evaluated*;
  this proves it *loads*.

### Changed

- **Updated flake inputs** — nixpkgs `2026-07-18` → `2026-08-22`, nvf
  `2026-07-19` → `2026-08-22`, flake-parts `2026-07-01` → `2026-08-01`,
  octo.nvim `2026-07-09` → `2026-07-30`.
- **Migrated `vim.languages.ts`** — nvf split it into `typescript` (ts/js) and
  `tsx`; both are now enabled explicitly.
- **Image popup repositioning is debounced** — `CursorMoved` in a markdown
  buffer used to queue three `defer_fn` timers per event, stacking three
  full window scans per line while scrolling. Now one debounced timer.

### Removed

- `config/plugins/minimap.nix` — codewindow was disabled and `vim.minimap.enable`
  had been commented out; nvf also dropped the `codewindow.mappings` option.

### Fixed

- **Intermittent blank/unstyled editor on startup** — `octo.nvim` invokes `gh`
  from its `setup()` and raises a hard error when it is missing, but `gh` was
  never in the flake's `runtimeDeps`. nvf emits plugin setup calls into the
  *main chunk* of `init.lua`, so that error aborted every module configured
  after it — including the colorscheme, leaving an editor with no highlight
  groups at all. Whether startup succeeded depended entirely on whether `gh`
  happened to be inherited from the surrounding shell, which is why it appeared
  intermittent and unreproducible. `gh` is now a declared runtime dependency,
  and octo's `setup()` is wrapped in `pcall` so a missing external tool can
  never again take down the rest of startup. Caught by the new smoke test.
- **Alpha dashboard raced session restore** — the alpha dashboard and
  `nvim-session-manager` both registered `VimEnter` autocmds and raced.
  Session restore deletes *every* buffer before sourcing the session file,
  while alpha only checked `argc() == 0`, so alpha would start into a
  half-torn-down window (or stomp a freshly restored session). Alpha now
  stands down whenever any real buffer is already on screen.
- **Colorscheme could leave the UI unstyled** — `config/themes/kartoza-theme.nix`
  runs `highlight clear` from `luaConfigRC` (i.e. *after* `pluginRC`), wiping
  groups plugins had already set, then restored only ~40 of them. Added the
  missing groups (`Pmenu`, `SignColumn`, `EndOfBuffer`, `NonText`, `Folded`,
  `StatusLineNC`, tabline, messages, diffs, diagnostics, search) and made the
  theme re-apply on `ColorScheme` so a later scheme swap cannot strip the UI.
  `Visual` also used the `Normal` background, making selections invisible.
- **image.nvim had one option declared twice with opposite values** —
  `editorOnlyRenderWhenFocused = true` (camelCase, not an image.nvim option,
  silently ignored) alongside `editor_only_render_when_focused = false`.
  Rendering while unfocused is a screen-corruption risk under the Kitty
  graphics protocol. Now a single key, set to `true`.
- **Python DAP and Claude Code fought over port 9000** — `claudecode.nvim`
  binds it on every startup (`auto_start = true`). The Python debug adapter
  now defaults to debugpy's conventional 5678.
- Dropped a stray no-op global assignment (`transparent_background = true`)
  from the theme.

## [0.4.0] - 2026-07-20

### Added

- **Handbook Overview section** — a new end-user "Overview" chapter (between
  Getting Started and the User Guide) that maps every add-on in the distribution
  by purpose, with a brand-coloured SVG diagram and a fully linked table.
- **Config-driven add-ons docs** — `lib/addons.json` is the single source of
  truth; `nix run .#handbook-addons` (`lib/gen-addons-docs.py`) renders
  `docs/overview/addons.md` and `docs/assets/diagrams/addons.svg`, and
  **drift-checks** the manifest against the live `config/` tree so the docs can
  never fall out of step with the architecture. Wired into the docs + release CI.

### Changed

- **Upstream attribution** — credited the [Schrovimger] project by Rahul Tudu
  (jack-thesparrow), which timvim was forked from, and the [NVF] framework, in
  the README (root and `.github/`) and the handbook. The root `README.md` is now
  the single canonical README, mirrored into `.github/README.md`.

### Fixed

- **PDF handbook rendering** — the `handbook-pdf` transform now flattens Material
  "grid cards" to a bold lead-in plus body paragraph (previously each card left a
  stray horizontal rule), and transliterates the ✅/⚪ status glyphs, so the whole
  handbook — not just the new Overview — renders cleanly to PDF.

[Schrovimger]: https://github.com/jack-thesparrow/schrovimger
[NVF]: https://github.com/notashelf/nvf

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
[Unreleased]: https://github.com/timlinux/nix-vim/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/timlinux/nix-vim/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/timlinux/nix-vim/compare/v0.2.0...v0.3.0
