# Adding Plugins

Adding a plugin to timvim is a small, repeatable ritual: create a `.nix` file
in the right `config/` sub-tree, import it in that directory's `default.nix`,
and express the plugin's configuration with NVF's option syntax. This page
walks through it, then covers the extra care required when a plugin brings
keybindings — which are governed by a **formal change process**.

## The workflow

### 1. Choose the right sub-tree

Put the file where a future contributor would look for it (see the table in
[Architecture](architecture.md#what-lives-where)):

- LSP, treesitter, language support, git, debugging → `config/plugins/`
- statusline, tabline, fold and window chrome → `config/ui/`
- editing motions and text helpers → `config/utility/`
- AI tooling → `config/assistant/`
- colours and theming → `config/themes/`
- core editor behaviour and keymaps → `config/core/`

### 2. Create the plugin file

Add, say, `config/plugins/my-plugin.nix`. If the plugin has a first-class NVF
module, enabling it is a matter of setting its options:

```nix
{ ... }:
{
  vim.telescope.enable = true;
}
```

If NVF has no module for it, add it as an extra plugin and supply its Lua
setup as a Nix string:

```nix
{ ... }:
{
  vim.extraPlugins.my-plugin = {
    package = pkgs.vimPlugins.my-plugin-nvim;
    setup = ''
      require("my-plugin").setup({})
    '';
  };
}
```

!!! info "Plugins not in nixpkgs"
    If the plugin is not packaged in nixpkgs, add it as a flake input in
    `flake.nix` (with `flake = false;`), build it with
    `vimUtils.buildVimPlugin`, and thread it through `extraSpecialArgs` — the
    way `claudecode.nvim` and `octo.nvim` are handled. Follow the dependency
    sourcing priority: prefer nixpkgs, then a new derivation, then upstream.

### 3. Import it in `default.nix`

NVF only sees files that are imported. Add your file to the sub-tree's
`default.nix`:

```nix
{ ... }:
{
  imports = [
    # …existing entries…
    ./my-plugin.nix
  ];
}
```

!!! warning "Forgetting the import is the classic mistake"
    A `.nix` file that is not listed in its directory's `default.nix` is
    simply ignored — no error, no plugin. If your change seems to do nothing,
    check the import first.

### 4. Build and test

```bash
nix build      # does it evaluate and build?
nix run        # does the editor launch with the plugin?
nix flake check  # formatting, deadnix, statix
```

See [Building & Testing](building.md) for what each command verifies. Format
your new file with `nix fmt` before committing.

## Adding keybindings

Keybindings are declared as Nix and merged by NVF. A mapping can live in the
plugin's own file (close to what it drives) or in `config/core/keymaps.nix`,
and it should be surfaced in the which-key menu via `config/core/whichKey.nix`
so it is discoverable.

A typical mapping:

```nix
{ ... }:
{
  vim.keymaps = [
    {
      key = "<leader>xy";
      mode = "n";
      action = "<cmd>MyPluginDoThing<cr>";
      desc = "My plugin: do the thing";
    }
  ];
}
```

Whenever you add or change a binding you must also:

1. Add or update the matching which-key entry in `config/core/whichKey.nix`,
   including a unique icon consistent with the surrounding menu.
2. Update the documentation so the keymap reference and `CLAUDE.md` stay in
   step with reality.

!!! tip "Keep bindings and menus in lockstep"
    A binding without a which-key entry is undiscoverable; a which-key entry
    without a binding is a lie. Every keybinding change touches both, plus the
    docs. Treat them as one atomic unit of work.

## The formal change process for keybindings

timvim enforces a **hard rule**, recorded in `CLAUDE.md`: keybindings and
which-key menu organisation are never changed on a whim. Before any such
change is made, the proposer must present a clear **before/after for each
atomic change** and obtain **explicit approval**. Only on acceptance is the
change made.

This exists because NVF merges mappings silently (see
[Architecture](architecture.md#how-modules-compose)) — a collision does not
error, it just produces an ambiguous chord — and because past churn in the
which-key menus wasted reviewer time. The process protects everyone.

The procedure:

1. **Propose.** For each atomic change, write out the current binding /
   menu placement (the "before") and exactly what it will become (the
   "after"). One row per change; do not batch unrelated changes together.
2. **Await approval.** Do not touch any mapping or menu structure until the
   proposal is explicitly accepted. Silence is not consent.
3. **Apply exactly what was approved.** Implement only the accepted changes,
   update `whichKey.nix`, and update the docs in the same change.
4. **Verify.** Run `nix run` and confirm the mapping behaves and appears in
   which-key as described.

!!! warning "This is not optional"
    Do not rearrange the which-key tree, rename menu groups, or re-map keys
    "while you're in there". Any such change — however small it looks — goes
    through propose → approve → apply. Bundling an unapproved binding tweak
    into an otherwise-approved plugin PR is a process violation.

## Checklist

- [ ] File created in the correct `config/` sub-tree.
- [ ] File imported in that directory's `default.nix`.
- [ ] Plugin configured with NVF option syntax (or added as a flake input if
      not in nixpkgs).
- [ ] Any new binding presented as before/after and **approved** first.
- [ ] `whichKey.nix` updated with a unique icon.
- [ ] Docs (keymap reference, `CLAUDE.md`) updated.
- [ ] `nix fmt`, `nix flake check`, `nix build` and `nix run` all pass.
