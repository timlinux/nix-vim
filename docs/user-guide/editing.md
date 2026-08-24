# Editing

timvim keeps core Vim motions intact while layering on modern conveniences from
Flash, mini.nvim and conform. Two handy line motions are remapped for comfort.

## Line motions

| Key | Mode | Action |
|-----|------|--------|
| `H` | n, v | Jump to first non-blank character (`^`) |
| `L` | n, v | Jump to end of line (`$`) |

## Flash navigation

Flash provides fast, label-based hops. Press the trigger, type the characters
you are aiming for, then press the label that appears.

| Key | Mode | Action |
|-----|------|--------|
| `s` | n, x, o | Flash jump to any location on screen |
| `S` | n, x, o | Flash Treesitter — select a syntax node |
| `r` | o | Remote flash for an operator |
| `R` | o, x | Treesitter search |

## Surround

Surround operations use a `gz` / `gZ` prefix to avoid clashing with Flash's `s`.

| Key | Mode | Action |
|-----|------|--------|
| `gz{motion}{char}` | n | Add surround around a motion (e.g. `gziw"`) |
| `gzz{char}` | n | Surround the entire line |
| `gzd{char}` | n | Delete a surrounding pair (e.g. `gzd"`) |
| `gzr{old}{new}` | n | Change surrounding (e.g. `gzr"'`) |
| `gz{char}` | v | Surround the visual selection |

## Autosave

Autosave is **off by default**. Toggle it with `<leader>ta`, and which-key shows
whether it is currently ON or OFF.

When enabled, buffers are written as you leave insert mode, leave the buffer, or
the terminal loses focus — never on every text change, which used to put a
synchronous formatter run in the middle of typing. `'autowrite'` and
`'autowriteall'` follow the same toggle, so nothing writes behind your back while
autosave is off. `gitcommit`, `gitrebase` and `fugitive` buffers are never
autosaved.

## Formatting on save

Formatting is handled by **conform.nvim**. It runs automatically *after* a save
(asynchronously, so the write never blocks on the formatter), and you can also
format on demand.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>cf` | n | Format the current buffer |
| `<leader>cc` | n | Check which formatters are available |

!!! info "Per-language formatters"
    Nix uses `nixfmt`, Python uses `black`, Rust uses `rustfmt`, and web files
    use `prettier`. See the [LSP guide](lsp.md) for the full language list.

## Navigation comfort

| Key | Mode | Action |
|-----|------|--------|
| `<Esc>` | n | Clear search highlight |
| `n` / `N` | n | Next / previous match, kept centred |
| `]b` / `[b` | n | Next / previous buffer |
| `]d` / `[d` | n | Next / previous diagnostic |
| `<leader>fr` | n | Recent files |
| `<leader>fs` | n | Search for the word under the cursor |
| `<leader>tn` | n | Toggle inlay hints |
| `<leader>ta` | n | Toggle autosave |

## Spell checking

| Key | Mode | Action |
|-----|------|--------|
| `<leader>zs` | n | Toggle spell check |
| `<leader>z=` | n | Show suggestions |
| `<leader>za` | n | Add word to dictionary |
| `<leader>zf` | n | Quick-fix with first suggestion |
| `]s` / `[s` | n | Next / previous misspelled word |

!!! tip "mini.nvim niceties"
    Pick a colour under the cursor with `<leader>cp` (mini.colors), and enjoy
    mini's autopairs and text-object improvements automatically.
