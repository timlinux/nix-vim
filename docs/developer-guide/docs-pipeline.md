# The Docs Pipeline

This handbook is part of the flake. The same repository that builds the editor
also serves the documentation locally, builds it into a static site, and
renders it to a Kartoza-branded PDF — all through `nix run .#…` apps that
carry their own toolchain, so you never need a nested `nix develop`.

## The three apps

| Command | What it does |
| ------- | ------------ |
| `nix run .#handbook` | Serves the site locally with live reload at `http://localhost:8001`. |
| `nix run .#handbook-build` | Builds the static site into `./site` with `--strict`. |
| `nix run .#handbook-pdf -- out.pdf` | Renders the whole handbook to a Kartoza-branded PDF. |

Run them from the repository root — they operate on `mkdocs.yml` and `docs/`
in the current directory.

### Serve locally

```bash
nix run .#handbook
```

This runs `mkdocs serve -a localhost:8001`. Open
[http://localhost:8001](http://localhost:8001) and edit files under `docs/`;
the browser reloads automatically. The MkDocs and Material stack is provided
by the flake's `docsPython` (a `python3.withPackages` bundling `mkdocs`,
`mkdocs-material`, the Material extensions, glightbox and the git-revision-date
plugin), placed directly on `PATH`.

### Build the site

```bash
nix run .#handbook-build
```

This runs `mkdocs build --strict` and writes the site to `./site`. The
`--strict` flag turns warnings — broken internal links, pages missing from the
nav, bad references — into hard errors, so this is the command that proves the
docs are publishable.

!!! tip "Run the strict build before you push docs"
    A page you added but forgot to list in the `mkdocs.yml` nav, or a link
    with a typo, passes a casual `serve` but fails `--strict`. CI runs the
    strict build; run it locally first.

### Render the PDF

```bash
nix run .#handbook-pdf -- timvim-handbook.pdf
```

This assembles a single Kartoza-branded PDF via **pandoc** + **texlive**. The
app puts pandoc, a trimmed `pdfLatex` combine, `librsvg` and shell utilities
on `PATH`, exports the docs and PDF-template directories, and executes
`lib/docs-pdf.sh`. The `pdfLatex` combine is built from `scheme-medium` plus
explicit extras (including the Kartoza brand font **Lato** and the
**Inconsolata** code font) to keep the closure lean rather than pulling in
`scheme-full`.

## Where the Kartoza theming lives

The brand presentation is factored out of `mkdocs.yml` so it can be reused:

| Location | Contents |
| -------- | -------- |
| `docs/stylesheets/kartoza-tokens.css` | The brand tokens — the Kartoza palette and type variables. |
| `docs/stylesheets/extra.css` | The adapter that maps those tokens onto Material for MkDocs (custom primary/accent, eyebrows, CTA styling, grid cards). |
| `docs/assets/brand/` | Brand imagery: logos, favicon, cover banner, motif and slant dividers. |
| `docs/pdf/` | The LaTeX templates for the PDF: `preamble.tex` (fonts, colours, headers) and `cover.tex` (the branded cover page). |

Both stylesheets are wired in through `extra_css` in `mkdocs.yml`; the mermaid
runtime is loaded via `extra_javascript`.

## `lib/docs-pdf.sh`

The PDF is not produced by a MkDocs plugin — it is assembled by
`lib/docs-pdf.sh`, invoked by the `handbook-pdf` app. Understanding it matters
because it has one maintenance obligation that is easy to miss.

What the script does:

1. **Orders the chapters.** It holds an explicit `PAGES` array listing every
   markdown file in reading order, then concatenates them with `\newpage`
   between chapters.
2. **Transforms each page** from MkDocs-flavoured Markdown into something
   pandoc/pdflatex can render: it strips YAML front-matter, **replaces each
   mermaid fenced block with a pointer to the online handbook**, flattens
   admonitions to bold labels (dedenting their 4-space bodies), drops
   grid-card and raw-HTML wrappers and `++key++` markup, and transliterates
   Unicode glyphs that pdflatex lacks.
3. **Runs pandoc** with the `docs/pdf/` templates: `preamble.tex` as the
   in-header include, `cover.tex` before the body, a table of contents, the
   Kartoza blue link colours and the Lato body font.

!!! warning "Keep `PAGES` in sync with the mkdocs nav"
    The `PAGES` array in `lib/docs-pdf.sh` must match the `nav:` section of
    `mkdocs.yml`. When you add, remove or reorder a page, update **both**. If
    you add a page to the nav but not to `PAGES`, it silently vanishes from
    the PDF; the reverse feeds the PDF a page that no longer exists and the
    build fails.

!!! info "Why mermaid becomes a pointer in the PDF"
    Mermaid renders as live JavaScript on the site but pdflatex cannot draw
    it, so the transform swaps each diagram for a short note directing readers
    to the online handbook. This is why the architecture diagram lives on the
    web version and is referenced — not reproduced — in print.

## The Kartoza credit

Per the brand guidelines, the handbook carries the credit triplet — *Made with
💗 by Kartoza · Donate! · GitHub* — in the MkDocs footer (via the `copyright`
setting in `mkdocs.yml`) and on the landing page. Preserve it when editing
those surfaces.
