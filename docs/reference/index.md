# Keybindings Reference

This section is the definitive, tested reference for every keybinding in
**timvim**. It is generated from the same Nix source that builds the editor, so
what you read here is exactly what the running configuration does.

## How keybindings are organised

timvim uses a single **leader key** — the <kbd>Space</kbd> bar — as the gateway
to almost every action. Related commands are grouped under a second key after
the leader. For example, everything to do with Git lives under
`<leader>g`, and everything to do with the AI assistant lives under
`<leader>a`.

There are three broad families of binding:

| Family | Trigger | Example |
|--------|---------|---------|
| **Leader menus** | `<leader>` (Space) then a group letter | `<leader>gg` opens Lazygit |
| **Direct keys** | A single key or chord, no leader | `s` for a Flash jump, `F5` to continue debugging |
| **Mode popups** | Keys active only inside a popup | `Ctrl+j` to move down the completion menu |

!!! tip "which-key shows you the way"
    You never need to memorise these tables. Press the leader key and pause —
    the **which-key** popup appears, listing every group. Press a group letter
    and it expands to show the actions inside, each with an icon and label. The
    reference below simply mirrors those live menus so you can read them offline.

## Toggle states

The Toggles group (`<leader>t`) contains features you switch on and off. Each
toggle has a **dynamic icon**: it is rendered in grey when the feature is
**OFF** and in blue when **ON**, and its label updates to show `[ON]` or
`[OFF]`. So which-key always tells you the current state before you press.

## Where to go next

<div class="grid cards" markdown>

-   :material-menu: **Which-Key Menus** — The group structure behind the leader
    key: every `<leader>` prefix, its name, its icon and what it contains.
    [Browse the menus](which-key.md)

-   :material-keyboard: **Full Keymap** — Every binding as grouped tables, with
    key, mode and action. Normal and visual mode covered.
    [See the keymap](keymap.md)

-   :material-text-box-search: **Completion Keys** — The harmonised
    completion-menu and Copilot ghost-text keys, and how the two differ.
    [Learn completion](completion.md)

</div>

!!! note "Leader is Space"
    Throughout this reference, `<leader>` means the <kbd>Space</kbd> key. So
    `<leader>ac` is read as "Space, then `a`, then `c`".
