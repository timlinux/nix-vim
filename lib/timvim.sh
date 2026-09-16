#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Kartoza (Pty) Ltd <tim@kartoza.com>
# SPDX-License-Identifier: MIT
#
# timvim: namespaced CLI for this project's `nix run .#<app>` commands,
# meant for use inside `nix develop` (where it's already on PATH). One
# implementation -- the flake's `apps.*` -- two entry points: `nix run
# .#foo` directly, or `timvim foo` from here. Keep the command list below
# in sync with flake.nix's `apps.*` attributes.
set -euo pipefail

FLAKE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# "cli name|nix app|description"
commands=(
  "run|default|Launch timvim (the built editor)"
  "handbook|handbook|Serve the handbook locally (mkdocs serve)"
  "handbook-build|handbook-build|Build the handbook site into ./site"
  "handbook-keymaps|handbook-keymaps|Regenerate keymap docs + keyboard SVGs from the live config"
  "handbook-addons|handbook-addons|Regenerate the add-ons overview + diagram"
  "handbook-pdf|handbook-pdf|Assemble the handbook into a Kartoza-branded PDF"
  "sbom|sbom|Generate a CycloneDX + SPDX SBOM"
  "bench-typing|bench-typing|Benchmark typing latency and record it to SQLite"
)

print_help() {
  echo "timvim -- project commands (run from inside \`nix develop\`)"
  echo
  for entry in "${commands[@]}"; do
    IFS='|' read -r name _ desc <<<"$entry"
    printf "  timvim %-17s %s\n" "$name" "$desc"
  done
  echo
  echo "Each command also works directly as \`nix run .#<app>\`; see flake.nix."
  echo
  echo "Made with 💗 by Kartoza (https://kartoza.com) | Donate: https://github.com/sponsors/timlinux | GitHub: https://github.com/timlinux/timvim"
}

if [ $# -eq 0 ] || [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  print_help
  exit 0
fi

sub="$1"
shift

app=""
for entry in "${commands[@]}"; do
  IFS='|' read -r name candidate _ <<<"$entry"
  if [ "$name" = "$sub" ]; then
    app="$candidate"
    break
  fi
done

if [ -z "$app" ]; then
  echo "timvim: unknown command '$sub'" >&2
  echo >&2
  print_help >&2
  exit 1
fi

exec nix run "$FLAKE_ROOT#$app" -- "$@"
