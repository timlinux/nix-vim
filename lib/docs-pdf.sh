#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Kartoza (Pty) Ltd <tim@kartoza.com>
# SPDX-License-Identifier: MIT
#
# Assemble the timvim handbook into a Kartoza-branded PDF via pandoc +
# pdflatex (approach from kartoza/qgis-desktop-docker and timlinux/qgis-dev-env).
# Invoked by `nix run .#handbook-pdf -- [output.pdf]`, which provides the
# toolchain on PATH and these env vars:
#   TIMVIM_DOCS_DIR   docs/ tree (store path in CI, worktree locally)
#   TIMVIM_PDF_DIR    docs/pdf (preamble.tex, cover.tex)
set -euo pipefail

DOCS_DIR="${TIMVIM_DOCS_DIR:?TIMVIM_DOCS_DIR not set (run via nix run .#handbook-pdf)}"
PDF_DIR="${TIMVIM_PDF_DIR:?TIMVIM_PDF_DIR not set}"

OUT="${1:-timvim-handbook.pdf}"
case "$OUT" in
/*) OUT_ABS="$OUT" ;;
*) OUT_ABS="$PWD/$OUT" ;;
esac

WORK="$(mktemp -d -t timvim-handbook-pdf.XXXXXX)"
_cleanup() {
  rc=$?
  if [ "$rc" -eq 0 ]; then
    rm -rf "$WORK"
  else
    echo "handbook-pdf failed; kept work dir at: $WORK" >&2
  fi
  exit "$rc"
}
trap _cleanup EXIT

# Chapter order — keep in sync with the nav in mkdocs.yml.
PAGES=(
  "index.md"
  "getting-started/index.md"
  "getting-started/installation.md"
  "getting-started/home-manager.md"
  "getting-started/first-launch.md"
  "getting-started/dashboard.md"
  "user-guide/index.md"
  "user-guide/editing.md"
  "user-guide/completion-ai.md"
  "user-guide/navigation.md"
  "user-guide/git.md"
  "user-guide/lsp.md"
  "user-guide/debugging.md"
  "user-guide/refactoring.md"
  "user-guide/terminal-files.md"
  "user-guide/image-preview.md"
  "reference/index.md"
  "reference/keyboard.md"
  "reference/which-key.md"
  "reference/keymap.md"
  "reference/completion.md"
  "developer-guide/index.md"
  "developer-guide/architecture.md"
  "developer-guide/dev-shell.md"
  "developer-guide/adding-plugins.md"
  "developer-guide/building.md"
  "developer-guide/docs-pipeline.md"
  "developer-guide/release.md"
  "about/index.md"
  "about/specification.md"
  "about/design.md"
  "about/ai-policy.md"
  "about/sponsors.md"
)

# Per-page transform: mkdocs-flavoured markdown → pandoc/pdflatex-safe.
#  * strip YAML front-matter
#  * guard: if a stray mermaid fence appears, replace it with a pointer
#    (diagrams should be authored as SVGs under docs/assets/diagrams/, which
#    render in both the site and this PDF — mermaid cannot render to PDF)
#  * flatten admonitions (titled and untitled) to bold labels, dedenting
#    their 4-space bodies so pandoc doesn't render them as code blocks
#  * drop grid-card / raw-HTML wrappers, ++key++ markup
#  * transliterate unicode pdflatex has no glyphs for
# shellcheck disable=SC2016  # literal backticks in a sed replacement below
transform() {
  gawk '
    NR == 1 && /^---$/ { infm = 1; next }
    infm && /^---$/ { infm = 0; next }
    infm { next }
    /^```mermaid/ { inmermaid = 1; print "*(Diagram - see the online handbook.)*"; next }
    inmermaid && /^```/ { inmermaid = 0; next }
    inmermaid { next }
    /^!!! [a-z]+ ".*"$/ {
      match($0, /^!!! [a-z]+ "(.*)"$/, m)
      split($0, w, " ")
      printf "**%s%s: %s**\n", toupper(substr(w[2],1,1)), substr(w[2],2), m[1]
      inadmon = 1; next
    }
    /^!!! [a-z]+$/ {
      split($0, w, " ")
      printf "**%s%s:**\n", toupper(substr(w[2],1,1)), substr(w[2],2)
      inadmon = 1; next
    }
    inadmon && /^    / { print substr($0, 5); next }
    inadmon && /^$/ { print; next }
    { inadmon = 0; print }
  ' "$1" |
    sed \
      -e '/^<div/d' -e '/^<\/div>/d' \
      -e '/^<span class="kz-eyebrow">/d' \
      -e '/^<p class="kz-/d' -e '/^<\/p>/d' \
      -e 's#</\?kbd>##g' \
      -e '/!\[.*\](.*slant-title-background\.png)/d' \
      -e "s#](\.\./assets/diagrams/\([a-z0-9-]*\)\.svg)#](${WORK}/img/\1.pdf)#g" \
      -e "s#](assets/diagrams/\([a-z0-9-]*\)\.svg)#](${WORK}/img/\1.pdf)#g" \
      -e 's/:\(material\|simple\|octicons\|fontawesome\)[a-z0-9_-]*: \?//g' \
      -e 's/{ \.[a-zA-Z0-9_. -]* }//g' \
      -e 's/++\([a-zA-Z-]*\)++/`\1`/g' \
      -e 's/💗/love/g' \
      -e 's/🚀 \?//g' -e 's/⌨ \?//g' -e 's/🔒 \?//g' -e 's/📐 \?//g' \
      -e 's/🔧 \?//g' -e 's/🧭 \?//g' -e 's/️ \?//g' \
      -e 's/⚠/WARNING /g' \
      -e 's/✓/OK/g' -e 's/✗/X/g' \
      -e 's/≥/>=/g' -e 's/≤/<=/g' -e 's/≈/~/g' \
      -e 's/·/-/g' \
      -e 's/—/--/g' -e 's/–/-/g' \
      -e 's/…/.../g' \
      -e 's/→/->/g' -e 's/←/<-/g' -e 's/⇒/=>/g' \
      -e 's/§/Section /g' \
      -e 's/│/|/g' -e 's/└/`/g' -e 's/├/|/g' -e 's/─/-/g' \
      -e 's/×/x/g' |
    # Strip Nerd Font / Private Use Area glyphs (which-key icons etc.) that
    # pdflatex has no glyphs for. Byte-wise so the ranges are unambiguous:
    #   3-byte PUA  U+E000–U+F8FF   → lead bytes EE/EF
    #   4-byte PUA  U+F0000–U+FFFFF → lead byte F3, second B0–BF
    LC_ALL=C sed -E \
      -e 's/\xf3[\xb0-\xbf][\x80-\xbf][\x80-\xbf]//g' \
      -e 's/[\xee\xef][\x80-\xbf][\x80-\xbf]//g'
}

# Pre-render SVG diagrams to PDF so pdflatex embeds them as vector graphics.
mkdir -p "$WORK/img"
for svg in "$DOCS_DIR"/assets/diagrams/*.svg; do
  [ -f "$svg" ] || continue
  rsvg-convert -f pdf -o "$WORK/img/$(basename "$svg" .svg).pdf" "$svg"
done

{
  cat <<'META'
---
title: timvim
subtitle: Handbook
lang: en
---

META
  chapter=0
  for page in "${PAGES[@]}"; do
    chapter=$((chapter + 1))
    [ "$chapter" -gt 1 ] && printf '\n\n\\newpage\n\n'
    transform "$DOCS_DIR/$page"
  done
} >"$WORK/combined.md"

cp "$PDF_DIR/preamble.tex" "$WORK/preamble.tex"
cp "$PDF_DIR/cover.tex" "$WORK/cover.tex"
# Kartoza horizontal logo doubles as the cover banner.
cp "$DOCS_DIR/assets/brand/kartoza-logo-horizontal-color.png" "$WORK/cover-banner.png"

mkdir -p "$WORK/texout"
cd "$WORK"
pandoc combined.md \
  --pdf-engine=pdflatex \
  --pdf-engine-opt=-interaction=nonstopmode \
  --pdf-engine-opt=-output-directory="$WORK/texout" \
  --resource-path=".:$DOCS_DIR" \
  --include-in-header=preamble.tex \
  --include-before-body=cover.tex \
  --toc --toc-depth=2 \
  -V fontfamily=lato \
  -V fontfamilyoptions=default \
  -V papersize=a4 \
  -V geometry:margin=2.5cm \
  -V colorlinks=true \
  -V linkcolor=kartozablue \
  -V urlcolor=kartozablue \
  -V toccolor=kartozablue \
  -V documentclass=article \
  -o "$OUT_ABS"

echo ""
echo "Wrote $OUT_ABS"
