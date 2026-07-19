# Dev Shell

The flake ships a development shell (`devShells.default`) that puts every tool
a contributor needs onto `PATH` — formatters, linters, language servers, media
utilities and the handbook toolchain's dependencies. Working inside it means
your local tool versions match CI exactly, so a passing check locally is a
passing check in the pipeline.

## Entering the shell

From the repository root:

```bash
nix develop
```

This drops you into a shell with all of the packages below available. If you
use [direnv](https://direnv.net), an `.envrc` containing `use flake` will load
the shell automatically whenever you `cd` into the project.

!!! tip "You often do not need the shell"
    The `nix run .#…` apps (`.#handbook`, `.#handbook-build`, `.#handbook-pdf`)
    and the flake checks bring their own toolchains. Reach for `nix develop`
    when you want the tools interactively — for example to run a formatter by
    hand or debug a language server.

## What's in the shell

The packages come straight from `devShells.default` in `flake.nix`, sourced
from nixpkgs in line with the project's dependency policy.

### Nix tooling

| Tool | Purpose |
| ---- | ------- |
| `nixfmt-rfc-style` | The canonical Nix formatter (also the flake `formatter`). |
| `nixd` | Nix language server. |
| `deadnix` | Detects dead / unused Nix code. |
| `statix` | Nix style and anti-pattern linter. |
| `pre-commit` | Runs the local commit-time quality hooks. |

### Language servers, formatters and debuggers

| Language | Tools provided |
| -------- | -------------- |
| Python | `pyright` (LSP), `black` (formatter), `debugpy` (debugger). |
| Go | `go`, `gopls` (LSP), `delve` (debugger), `gotools`, `go-tools`. |
| Lua | `stylua` (formatter). |
| Shell | `shfmt` (formatter). |
| Web / Markdown | `prettier` (Markdown, JS, HTML). |
| Java | `google-java-format`. |
| Prose | `harper` (grammar-checking LSP). |
| reStructuredText / Sphinx | `rstcheck`, `doc8`, `sphinx`, `sphinx-autobuild`, `rst2pdf`. |

### JavaScript runtime

`nodejs_22` is included because GitHub Copilot's inline completion requires
Node 22 or newer.

### Media and preview tools

These support the dashboard banner generation and file/image previews:

| Tool | Purpose |
| ---- | ------- |
| `catimg` | Terminal image viewer used to generate the alpha dashboard header. |
| `chafa` | Terminal graphics for image previews. |
| `imagemagick` | Image conversion and manipulation. |
| `epub-thumbnailer`, `ffmpegthumbnailer`, `poppler-utils` | Thumbnails/preview for EPUB, video and PDF. |
| `nerd-fonts.jetbrains-mono` | The coding font with icon glyphs. |
| `ripgrep`, `fd`, `git` | Search and version-control basics. |
| `fontpreview` | Font previewing (Linux only). |
| `term2alpha` | Converts `catimg` output to the alpha header's coloured Lua (from a flake input). |

!!! info "Regenerating the dashboard banner"
    `catimg` and `term2alpha` are here specifically so you can regenerate the
    Kartoza logo on the start screen. See the banner-generation notes in
    `CLAUDE.md` for the exact `catimg … | term2alpha` incantation.

## Verifying the shell

A quick sanity check that the shell is wired up correctly:

```bash
nix develop --command echo "Dev shell works!"
```

CI runs exactly this command, so if it succeeds locally the pipeline will be
happy too.
