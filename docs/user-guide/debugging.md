# Debugging

timvim provides full Debug Adapter Protocol (**DAP**) support with a visual
debug UI. Controls live under `Space d`, and the most common actions also have
single-press function-key shortcuts.

## Breakpoints & stepping

| Key | F-key | Action |
|-----|-------|--------|
| `<leader>db` | `F8` | Toggle breakpoint (persistent) |
| `<leader>dc` | `F5` | Continue |
| `<leader>dv` | `F9` | Step over |
| `<leader>dn` | `F10` | Step into |
| — | `F11` | Step out |
| `<leader>dt` | `F12` | Run to cursor |
| `<leader>dq` | `Shift+F5` | Terminate |
| — | `Shift+F8` | Clear all breakpoints |

!!! tip "Conditional breakpoints"
    `<leader>dB` sets a conditional breakpoint and `<leader>dL` sets a log
    point — handy for narrowing down without stopping every iteration.

## The debug UI

| Key | F-key | Action |
|-----|-------|--------|
| `<leader>du` | `Shift+F9` | Toggle the DAP UI |
| `<leader>dr` | — | Toggle the REPL |
| `<leader>dh` | — | Hover to inspect a value |
| `<leader>dR` | — | Restart the session |
| `<leader>d.` | — | Run last |

## Python debugging

| Key | Action |
|-----|--------|
| `<leader>dl` | Start / continue local debugging |
| `<leader>da` | Attach to a remote Python debugger |
| `<leader>ds` | Show debug status |
| `<leader>di` | Check the debugpy installation |
| `<leader>dk` | Kill hanging debug processes |

!!! info "Remote attach"
    `<leader>da` prompts for a port at runtime, defaulting to the last used
    value (or 9000). Pair it with a debugpy listener in your application.

!!! note "Debugging tests"
    Neotest integrates with DAP — press `<leader>Td` to debug the nearest test.
