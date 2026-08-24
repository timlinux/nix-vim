# Notifications

Messages travel through **noice**, which routes them, and **nvim-notify**, which
draws them in the bottom-right corner. On top of that sits a small policy layer
that decides what is worth your attention.

## How long messages stay

Severity sets the lifetime, because an error you cannot finish reading is worse
than no error, and "Autosave enabled" does not deserve five seconds.

| Level | On screen |
|-------|-----------|
| Error | 10 seconds |
| Warning | 6 seconds |
| Info | 2 seconds |
| Debug / Trace | 1.5 seconds |

Anything that passes an explicit timeout of its own keeps it.

## What never appears

Identical messages repeated within two seconds are collapsed — language servers
and formatters tend to fail in bursts, and five copies carry no more information
than one. A short mutelist drops known chatter outright: direnv's export
messages on every directory change, `No information available` from an empty
hover, and Neovim's `position_encoding` deprecation warning.

The list lives in `config/plugins/notify.nix` as `_G.notify_mutelist`; entries
are Lua patterns matched against the message text.

## Reading what you missed

| Key | Mode | Action |
|-----|------|--------|
| `<leader>Nl` | n | Show the last message again — the one that just faded |
| `<leader>Nh` | n | Notification history (Telescope) |
| `<leader>Na` | n | All messages, in a split |
| `<leader>Ne` | n | Errors only |
| `<leader>Nd` | n | Dismiss everything on screen |

!!! tip "The one to remember"
    `<leader>Nl` is the answer to "wait, what did that say?". Info messages are
    deliberately brisk because nothing is lost — it is all still in the history.

## Do not disturb

`<leader>tN` mutes notifications while you present, record or pair. Errors still
get through, so a silent failure cannot hide behind it. Which-key shows the
current state as `[ON]` / `[OFF]` alongside the other toggles.
