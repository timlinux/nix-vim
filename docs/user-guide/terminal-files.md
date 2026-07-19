# Terminal & Files

timvim integrates a **toggleterm**-based terminal and the **Yazi** file manager
so you can run commands and browse the filesystem without leaving the editor.

## Terminal

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+t` | n | Toggle a terminal (horizontal split) |
| `<leader>tt` | n, t | Toggle a floating terminal |

!!! tip "Floating vs split"
    Use `Ctrl+t` for a persistent split alongside your work, and `<leader>tt`
    for a quick floating terminal that overlays the editor.

## Yazi file manager

Yazi replaces netrw and opens in a floating window with rounded borders. It
appears automatically when you open a directory.

| Key | Mode | Action |
|-----|------|--------|
| `-` | n | Open Yazi at the current file |
| `<leader>fo` | n | Open Yazi at the current file |
| `<leader>fO` | n | Open Yazi in the working directory |
| `<leader>fy` | n | Toggle / resume the last Yazi session |

### Inside the Yazi window

| Key | Action |
|-----|--------|
| `F1` | Show help |
| `Ctrl+v` | Open the file in a vertical split |
| `Ctrl+x` | Open the file in a horizontal split |
| `Ctrl+t` | Open the file in a new tab |
| `Ctrl+s` | Grep within the directory |
| `Ctrl+g` | Find and replace within the directory |
| `Ctrl+y` | Copy the relative path of the selected files |
| `Tab` | Cycle through open buffers |

!!! info "Directory buffers"
    Opening any directory hands off to Yazi automatically, so `nvim .` drops
    you straight into the file manager.
