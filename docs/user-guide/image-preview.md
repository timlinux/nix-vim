# Image Preview

timvim can render images directly in the editor using **image.nvim** and the
**Kitty graphics protocol**. When the cursor sits on an image path in a markdown
file, a popup preview appears — ideal for reviewing screenshots and diagrams
inline.

## Controls

| Key | Mode | Action |
|-----|------|--------|
| `<leader>tI` | n | Toggle image preview on/off (global) |
| `<leader>ic` | n | Clear all rendered images in the buffer |

!!! tip "Clearing quickly"
    In markdown files, pressing `Esc` also clears rendered images along with any
    search highlight.

## Requirements

Image preview relies on a terminal that speaks the Kitty graphics protocol:

```text
- Kitty terminal (28.0+), or
- Another Kitty-graphics-compatible terminal (e.g. WezTerm, Ghostty)
```

!!! warning "Terminal support"
    If images do not appear, your terminal probably lacks Kitty graphics
    support. Preview is disabled gracefully in that case — the rest of timvim
    works normally.

!!! info "Where it triggers"
    Previews are shown for image paths inside markdown buffers. Move the cursor
    onto a path such as `![diagram](assets/flow.png)` to see it render, and use
    `<leader>ic` to clear the display when you are done.
