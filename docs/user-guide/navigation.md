# Navigation

Finding files, symbols and projects is fast in timvim thanks to **Telescope**,
**FZF**, session and project management, **smart-splits** and the **Yazi** file
manager.

## Finding files & text

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ff` | n | Find files (FZF, includes hidden) |
| `<leader>fp` | n | Find Python files |
| `<leader>fn` | n | Find Nix files |
| `<leader>fg` | n | Live grep (fixed strings) |
| `<leader>fG` | n | Live grep (regex) |
| `<leader>fm` | n | Find media files with preview |
| `<leader>bb` | n | Find open buffers |

## Sessions & projects

| Key | Mode | Action |
|-----|------|--------|
| `<leader>sm` | n | Open the session manager |

!!! info "Projects"
    Project detection restores your working directory and recent files, so
    reopening timvim in a repo picks up where you left off.

## Splits & windows

Movement and resizing are handled by **smart-splits**, which is aware of window
boundaries.

| Key | Action |
|-----|--------|
| `Ctrl+h` / `Ctrl+j` / `Ctrl+k` / `Ctrl+l` | Move to the left / lower / upper / right split |
| `Alt+h` / `Alt+j` / `Alt+k` / `Alt+l` | Resize the split in that direction |
| `<leader>bj` / `bk` / `bs` / `bd` | Swap the buffer down / up / left / right |

## File manager & outline

| Key | Mode | Action |
|-----|------|--------|
| `-` | n | Open Yazi at the current file |
| `<leader>fo` | n | Open Yazi at the current file |
| `<leader>fO` | n | Open Yazi in the working directory |
| `<leader>fy` | n | Toggle / resume the last Yazi session |
| `<leader>to` | n | Toggle the code outline panel (Aerial) |

!!! tip "Quick file browsing"
    Press `-` in normal mode to jump straight into Yazi at your current file —
    no leader key needed. See [Terminal & Files](terminal-files.md) for more.
