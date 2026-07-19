# LSP

Language servers power navigation, diagnostics, hover documentation and code
actions. timvim wires these into two discoverable groups — `Space n` for
navigation and `Space l` for diagnostics — backed by **Trouble** for rich list
windows.

## Navigation

| Key | Mode | Action |
|-----|------|--------|
| `<leader>nd` | n | Go to definition |
| `<leader>nD` | n | Go to declaration |
| `<leader>ni` | n | Find implementations |
| `<leader>nt` | n | Find type definitions |
| `<leader>nr` | n | Find references |
| `<leader>nh` | n | Hover documentation |
| `<leader>ns` | n | Find document symbols |

!!! tip "Quick keys"
    `Ctrl+l` jumps to the definition, `Ctrl+h` returns from it, and `K` shows
    hover documentation without leaving your place.

## Diagnostics & Trouble

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ln` | n | Next diagnostic |
| `<leader>lp` | n | Previous diagnostic |
| `<leader>ld` | n | Document diagnostics (Trouble) |
| `<leader>lw` | n | Workspace diagnostics (Trouble) |
| `<leader>lr` | n | References (Trouble) |
| `<leader>cr` | n | Rename symbol |

## Grammar & prose

**Harper** adds a grammar checker for prose and comments.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>tg` | n | Toggle the Harper grammar checker |
| `<leader>tv` | n | Toggle virtual-text diagnostics |
| `<leader>tw` | n | Toggle CursorHold error tooltips |

## Per-language servers

timvim enables LSP, formatting and diagnostics for a broad set of languages:

| Language | Server |
|----------|--------|
| Python | `pyright` (format: black) |
| Nix | `nixd` (statix, deadnix) |
| Go | `gopls` |
| Rust | `rust-analyzer` |
| Lua, Bash, C/C++, Java, TypeScript, HTML, YAML, Markdown | enabled |

!!! info "Format on save"
    Every language with formatting enabled is auto-formatted on save via
    conform.nvim — see the [Editing guide](editing.md).
