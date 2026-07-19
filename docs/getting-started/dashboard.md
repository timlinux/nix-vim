# The Dashboard

Every timvim session opens on the **alpha dashboard** — a start screen built
with [alpha-nvim](https://github.com/goolord/alpha-nvim). It is the first thing
you see and your launchpad into the editor.

## The Kartoza banner

The dashboard is headed by a full-colour Kartoza logo rendered directly in the
terminal. It is not an image file loaded at runtime: it is a block of
pre-computed, highlighted text so it displays instantly and works over SSH.

!!! info "How the banner is generated"
    The logo is produced from a PNG using two tools:

    - **`catimg`** converts the image into 24-bit-colour terminal output.
    - **`term2alpha`** turns that output into Lua highlight groups plus a
      header table that alpha-nvim can render.

    Both tools are available in the development shell (`nix develop`).

## Regenerating the banner

To refresh or replace the logo, generate the header Lua and paste it into the
dashboard config:

```bash
catimg -H 30 kartoza-logo.png | term2alpha > header.lua
```

- `-H 30` sets the height in terminal lines — adjust to taste.
- `term2alpha` only understands the 24-bit colour codes emitted by `catimg`;
  other renderers such as `chafa` produce incompatible ANSI codes.

The generated file contains two parts: a set of `vim.api.nvim_set_hl(...)`
highlight definitions and a header table (`val` lines plus per-line `opts.hl`
specs). Copy both into `config/plugins/alpha.nix`, replacing the existing
highlight groups and the `dashboard.section.header` block, then rebuild with
`nix run`.

!!! tip "Full walkthrough"
    The complete banner-update recipe lives in the project's `CLAUDE.md` under
    *Updating the Startup Banner*.

## Common dashboard actions

The dashboard offers single-key shortcuts for the tasks you reach for most:

| Key | Action |
| --- | ------ |
| `n` | New file |
| `f` | Find file (Telescope) |
| `r` | Recent files (Telescope) |
| `s` | Restore last session |
| `q` | Quit |

!!! note "Beyond the shortcuts"
    Once you are past the dashboard, press ++space++ to open the
    [which-key menu](first-launch.md#opening-the-which-key-menu) and reach the
    full command set.
