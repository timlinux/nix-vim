# Using AI

<span class="kz-eyebrow">KARTOZA · TRANSPARENCY</span>

timvim ships with AI assistance built in, and AI tools were used to help build
timvim itself. This page sets out how — plainly — so you always know what is
happening and stay in control of it.

## AI inside the editor

Two AI integrations are configured out of the box. Both are **optional** and
**user-controlled**.

<div class="grid cards" markdown>

-   :material-message-text-outline:{ .lg .middle } **Claude Code**

    ---

    A chat interface running in a terminal window inside Neovim. You can toggle
    it, focus it, choose a model and send a visual selection to it for
    discussion or editing.

-   :material-ghost-outline:{ .lg .middle } **GitHub Copilot**

    ---

    Inline "ghost text" completion suggestions as you type. Accept a word, a
    line or a full suggestion — or ignore it entirely.

</div>

### You are in control

- **Nothing runs without you invoking it.** Claude Code opens only when you
  toggle it; Copilot suggestions are proposals you choose to accept or dismiss.
- **The AI status is always visible.** A clickable Copilot indicator lives in the
  statusline, so you can see at a glance whether ghost text is active and turn it
  on or off with a click.
- **Your keystrokes decide.** Accepting a suggestion is always an explicit action
  (for example the ghost-text accept keys), never automatic.

!!! warning "Sending code to a third party"
    When you use Claude Code or Copilot, the relevant context (your prompt, the
    selection you send, or the surrounding code) is transmitted to the respective
    provider's service for processing. If you work with sensitive code, review
    each provider's terms and disable the integration when appropriate. Because
    AI is opt-in per action, you can simply not invoke it.

## AI in timvim's development

Parts of timvim's configuration and this handbook were drafted with AI
assistance. We treat that as a normal engineering tool, applied transparently:

- **Humans review everything.** AI-drafted changes are read, tested and revised
  by a maintainer before they land. AI accelerates the work; it does not get the
  final say.
- **The same quality gates apply.** All code passes the project's checks —
  formatting (`nixfmt-rfc-style`), dead-code (`deadnix`) and style (`statix`) —
  regardless of how it was drafted.
- **Disclosure where it helps.** Where AI-drafted content warrants a marker, the
  handbook uses an inline
  <span class="kz-ai">:material-robot-outline: AI-assisted</span> badge so the
  provenance is clear.

## Principles

- **Optional first.** AI never becomes a dependency for using the editor. Turn it
  off and everything else still works.
- **Transparent.** We say where and how AI is used, both in the product and in
  its development.
- **Under your control.** You decide when to invoke AI, what to send and when to
  disable it.
