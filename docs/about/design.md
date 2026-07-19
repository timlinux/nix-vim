# Design Aesthetic

<span class="kz-eyebrow">KARTOZA · BRAND</span>

timvim wears the Kartoza brand. The look is deliberately **flat and calm**: no
shadows, bevels or glows, generous breathing room, and a restrained palette where
Blue is the primary accent and Amber the highlight. The goal is an editor that
feels consistent and joyful to spend a day in, not one that shouts.

## Palette

<div class="kz-swatches" markdown>
<div class="kz-swatch" style="background:#54A2CC;color:white"><strong>Kartoza Blue</strong><code>#54A2CC</code><span>Primary accent</span></div>
<div class="kz-swatch" style="background:#EEB348"><strong>Kartoza Amber</strong><code>#EEB348</code><span>Highlight / secondary accent</span></div>
<div class="kz-swatch" style="background:#8A8B8B;color:white"><strong>Kartoza Grey</strong><code>#8A8B8B</code><span>Muted UI, comments, rules</span></div>
<div class="kz-swatch" style="background:#383939;color:white"><strong>Charcoal</strong><code>#383939</code><span>Body text</span></div>
<div class="kz-swatch" style="background:#F5F5F2"><strong>Cloud</strong><code>#F5F5F2</code><span>Surfaces and panels</span></div>
</div>

Blue and Amber are accents only — never body text, since they fail WCAG AA on
white. Charcoal carries text; Cloud carries surfaces. The in-editor theme leans
on the same family (a Kartoza teal for strings, amber for numbers and constants,
blue for line numbers) so the editor and this handbook feel like one product.

!!! info "One source of truth"
    Colours and type live in `stylesheets/kartoza-tokens.css`, consumed by the
    Material for MkDocs adapter in `stylesheets/extra.css`. There are no
    hard-coded hexes scattered through the docs — the swatches above are the
    exception that documents the rule.

## Signature UI touches

The editor's chrome is where the brand shows up most clearly.

- **Powerline bubble statusline.** A lualine statusline with powerline bubbles
  and rounded caps. The cap colour tracks the current mode — amber in normal
  mode, teal in insert, blue in visual — so you can read your mode at a glance.
  The statusline is hidden on the dashboard so the start screen stays clean.
- **Amber UI borders.** Floating windows, popups and panels are outlined in the
  Kartoza amber, giving a warm, consistent frame across the interface.
- **Bubble tabline.** Buffers appear as rounded bubbles; the default tabline is
  hidden to keep the top of the screen quiet until you need it.
- **Clickable Copilot toggle.** The AI status is surfaced in the statusline and
  can be toggled by clicking it — AI is always visible and always optional.
- **A Kartoza dashboard.** The alpha start screen shows the Kartoza logo rendered
  into the terminal (generated with `catimg` and `term2alpha`) above a set of
  quick actions.

## Typography

- **Nunito** for the handbook UI and body text.
- **JetBrains Mono** for code, both here and in the editor (shipped via the
  JetBrains Mono Nerd Font for icon support).

## Design principles

- **Flat.** Depth comes from layout and the Kartoza map motif, not from drop
  shadows or gradients on UI elements.
- **Consistent.** The same palette and type run through the editor, the dashboard
  and this handbook.
- **Legible.** Contrast targets WCAG 2.2 AA; accents stay out of body text.
- **Calm.** Chrome recedes until it is needed — hidden tabline, hidden dashboard
  statusline, quiet borders.
