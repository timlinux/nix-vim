# Completion & AI

timvim gives you three complementary layers of assistance: structured
completion via **blink-cmp**, inline **Copilot** ghost text, and conversational
help from **Claude Code**.

## Completion menu (blink-cmp)

The completion popup uses a consistent, ergonomic navigation pattern shared
across all popups in timvim.

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+j` | i | Next item in the menu |
| `Ctrl+k` | i | Previous item in the menu |
| `Tab` | i | Accept the selected completion |
| `Enter` | i | Smart accept (or newline if the menu is closed) |
| `Ctrl+e` | i | Close the completion menu |
| `Ctrl+Space` | i | Manually trigger completion |

## Copilot ghost text

Copilot runs in manual-trigger mode: press `Ctrl+y` to summon or accept a
suggestion, then accept it in whole or in part.

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+y` | i | Trigger next suggestion, or accept the visible one |
| `Alt+w` | i | Accept the next word |
| `Alt+e` | i | Accept the current line |
| `Alt+]` | i | Cycle to the next suggestion |
| `Alt+[` | i | Cycle to the previous suggestion |
| `Ctrl+]` | i | Dismiss the current suggestion |
| `Alt+\` | i | Toggle Copilot on/off |

!!! info "Statusline indicator"
    A green circle labelled "Ctl-Y" shows when Copilot is active; a grey circle
    means it is disabled. Toggle it under `<leader>a` (`ae` enable, `ad`
    disable) or click the indicator.

## Claude Code

Claude Code opens a chat terminal alongside your code. Verified against the
`Space a` assistant group.

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ac` | n | Toggle the Claude Code terminal |
| `<leader>af` | n | Focus the Claude Code terminal |
| `<leader>am` | n | Select the Claude model |
| `<leader>as` | v | Send the current selection to Claude |

!!! tip "Send code for review"
    Select a region in visual mode and press `<leader>as` to hand it straight
    to Claude — ideal for explanations, reviews or refactor ideas.
