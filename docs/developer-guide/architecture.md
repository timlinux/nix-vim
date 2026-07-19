# Architecture

timvim is assembled entirely in Nix. The flake takes NVF's module system,
feeds it the `config/` tree, and wraps the resulting Neovim so that every
runtime dependency it needs is on `PATH`. This page explains how those pieces
fit together so you know where a change belongs.

## The big picture

The flake (`flake.nix`) uses [`flake-parts`](https://flake.parts) to define
per-system outputs. The heart of it is a single call to NVF's
`neovimConfiguration`:

```nix
nvimConfig = nvf.lib.neovimConfiguration {
  inherit pkgs;
  extraSpecialArgs = {
    claude-code-plugin = claude-code-plugin;
    octo-plugin = octo-plugin;
  };
  modules = [ ./config ];
};
```

Everything you edit as a contributor lives under `./config`. NVF evaluates
that module tree and produces `nvimConfig.neovim` — a Neovim derivation with
all plugins and settings baked in. Two plugins that are not packaged in
nixpkgs (`claudecode.nvim` and `octo.nvim`) are built from flake inputs with
`vimUtils.buildVimPlugin` and threaded into the config via `extraSpecialArgs`.

!!! info "Why no Lua files?"
    NVF exposes plugin options as typed Nix. Instead of writing `init.lua`
    you set attributes like `vim.telescope.enable = true`. When a plugin has
    no NVF module, you enable it through `vim.extraPlugins` / `vim.luaConfigRC`
    and supply the Lua as a Nix string — but the *source of truth* is always
    Nix, never a loose Lua file.

## The `config/` module tree

`config/default.nix` is the entry point NVF is pointed at. It simply imports
the six themed sub-trees:

```nix
{ pkgs, ... }:
{
  imports = [
    ./assistant
    ./core
    ./plugins
    ./themes
    ./ui
    ./utility
  ];

  vim.extraPackages = with pkgs; [
    nodejs_22 # Required for GitHub Copilot inline completion
  ];
}
```

Each sub-directory has its own `default.nix` that imports the individual
`.nix` files inside it. Adding a file to a sub-tree is therefore a two-step
act: create the file, then list it in that directory's `default.nix`.

![The timvim module tree and build pipeline — flake.nix feeds the config/ tree
through NVF into a wrapped Neovim exposed as packages.default / apps.default](../assets/diagrams/architecture.svg){ .kz-figure }

### What lives where

| Sub-tree      | Responsibility |
| ------------- | -------------- |
| `core/`       | Editor fundamentals: `options.nix`, `keymaps.nix`, `whichKey.nix`, `clipboard.nix`, `formatting.nix`, `autocmp.nix`, `session.nix`, `autosave.nix`, `autopairs.nix`, `luaLoader.nix`. |
| `plugins/`    | The bulk of functionality: LSP, treesitter, telescope, fzf, git, the debugger, per-language support, the alpha dashboard, Trouble, and more. |
| `themes/`     | Colour scheme selection and the Kartoza brand theme (`theme.nix`, `kartoza-theme.nix`). |
| `ui/`         | Visual chrome: statusline (`lualine`), `noice`, `tabline`, `barbecue`, fold UI (`ufo`), `direnv` integration. |
| `utility/`    | Editing helpers: flash navigation, surround, refactoring, multi-cursors, smart splits, outline, snacks, preview. |
| `assistant/`  | AI tooling: Claude Code integration (`claude-code.nix`) and GitHub Copilot (`copilot.nix`). |

!!! note "Choosing the right sub-tree"
    Put a change where a future contributor would look for it. A new language
    server belongs in `plugins/` (near `lsp.nix` / `languages.nix`); a
    cosmetic statusline tweak belongs in `ui/`; an editing motion belongs in
    `utility/`. When in doubt, follow the pattern of the file nearest in
    purpose.

## How modules compose

NVF merges every imported module into one big option set. Because it is the
Nix module system underneath, order does not matter and options are merged,
not overwritten — two files can both contribute to `vim.keymaps` and NVF
concatenates them. This is why keybindings can be defined close to the plugin
they belong to *and* surfaced centrally in `core/whichKey.nix`.

!!! warning "Merges, not overrides"
    Because everything merges, a duplicated or conflicting mapping does not
    error loudly — it silently produces two mappings or an ambiguous chord.
    This is exactly why keybinding changes go through the
    [formal change process](adding-plugins.md#the-formal-change-process-for-keybindings):
    a human reviews the before/after so nothing collides.

## The wrapped Neovim and runtime dependencies

NVF produces `nvimConfig.neovim`, but many plugins shell out to external
tools (ripgrep for telescope, `gopls` for Go, `node` for Copilot, and so on).
The flake collects these in a `runtimeDeps` list and wraps Neovim so they are
always on `PATH`, regardless of what the user has installed:

```nix
runtimeDeps = [
  pkgs.ripgrep pkgs.fd pkgs.fzf pkgs.chafa pkgs.git
  pkgs.go pkgs.gopls pkgs.gotools pkgs.delve
  pkgs.harper
  pkgs.python3Packages.rstcheck pkgs.python3Packages.doc8
  pkgs.nodejs_22
];

wrappedNeovim = pkgs.symlinkJoin {
  name = "timvim-wrapped";
  paths = [ nvimConfig.neovim ] ++ runtimeDeps;
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/nvim \
      --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps}
  '';
};
```

`wrappedNeovim` is what `packages.default` and `apps.default` expose, and what
`homeModules.default` installs. It also means these tools are part of the
build closure and get cached alongside the editor.

!!! tip "A missing runtime tool is a flake edit"
    If a plugin needs an external binary at runtime, add it to `runtimeDeps`
    in `flake.nix` — do not rely on the user having it. That keeps timvim
    self-contained and reproducible.

## Where the flake exposes things

| Output | What it is |
| ------ | ---------- |
| `packages.default` | The wrapped Neovim. |
| `apps.default` | `nix run` — launches the editor. |
| `apps.handbook` / `handbook-build` / `handbook-pdf` | The docs pipeline (see [The Docs Pipeline](docs-pipeline.md)). |
| `checks.{format-check,deadnix,statix}` | Quality gates (see [Building & Testing](building.md)). |
| `formatter` | `nixfmt-rfc-style`, driven by `nix fmt`. |
| `devShells.default` | The contributor toolbox (see [Dev Shell](dev-shell.md)). |
| `homeModules.default` | Home Manager integration installing the wrapped editor plus formatters. |
