# Git

timvim ships a complete git workflow: inline hunks and blame from **Gitsigns**,
side-by-side diffs and history from **Diffview**, three-way **conflict
resolution**, and full GitHub integration via **Octo**. Most bindings live under
`Space g`.

## Hunks, staging & blame

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gs` | n, v | Stage hunk (or selected lines) |
| `<leader>gr` | n, v | Reset hunk (or selected lines) |
| `<leader>gS` | n | Stage the whole buffer |
| `<leader>gR` | n | Reset the whole buffer |
| `<leader>gu` | n | Undo stage hunk |
| `<leader>gp` | n | Preview hunk |
| `<leader>gb` | n | Toggle git blame line |

## Diffs & history

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gd` | n | Diff this file |
| `<leader>gD` | n | Diff the whole project |
| `<leader>gv` | n | Open Diffview |
| `<leader>gV` | n | Close Diffview |
| `<leader>gf` | n | File git history |
| `<leader>gF` | n | Project git history |
| `<leader>gl` | n | Git log (Telescope) |
| `<leader>gg` | n | Open Lazygit |

## Conflict resolution

Buffer-local bindings appear when you open a file with conflict markers.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>gc` | n | Choose ours |
| `<leader>gt` | n | Choose theirs |
| `<leader>ga` | n | Choose both |
| `<leader>gn` | n | Choose none |

## GitHub (Octo)

Manage issues, pull requests and reviews without leaving the editor under
`Space o`. Requires an authenticated GitHub session.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>oi` | n | List issues |
| `<leader>op` | n | List pull requests |
| `<leader>oc` | n | Create a PR |
| `<leader>od` | n | View PR diff |
| `<leader>os` | n | Start a review |
| `<leader>oa` | n | Approve the review |
| `<leader>ox` | n | Request changes |

!!! info "More Octo actions"
    The full `Space o` group covers merging, checking out, comments, repos and
    gists — press `Space o` and pause to browse them all.
