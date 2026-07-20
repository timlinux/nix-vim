#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Kartoza (Pty) Ltd <tim@kartoza.com>
# SPDX-License-Identifier: MIT
#
# Generate the handbook's Overview section — an end-user map of every add-on in
# the timvim distribution — from lib/addons.json. Emits:
#
#   docs/overview/addons.md              a grouped, linked table
#   docs/assets/diagrams/addons.svg      a brand-coloured category diagram
#
# The manifest is DRIFT-CHECKED against the live config tree: every
# config/{plugins,ui,utility,assistant}/*.nix file (bar default.nix) must be
# referenced by some add-on's "configs" list, and every referenced file must
# exist. Add or remove a plugin without updating lib/addons.json and this script
# exits non-zero — so the Overview always matches the actual architecture.
#
#   python3 lib/gen-addons-docs.py [repo-root]
import json
import os
import sys

ROOT = sys.argv[1] if len(sys.argv) > 1 else "."
DOCS = os.path.join(ROOT, "docs")
DIAG = os.path.join(DOCS, "assets", "diagrams")
MANIFEST = os.path.join(ROOT, "lib", "addons.json")
SCAN_DIRS = ["config/plugins", "config/ui", "config/utility", "config/assistant"]
os.makedirs(DIAG, exist_ok=True)
os.makedirs(os.path.join(DOCS, "overview"), exist_ok=True)

# kartozaColors (shared with gen-keymap-docs.py)
PALETTE = {
    "BLUE": "#569FC6", "ORANGE": "#DF9E2F", "GREY": "#8A8B8B",
    "TEAL": "#06969A", "RED": "#CC0403",
}
CHAR, MUTED, CLOUD, RULE, WHITE = "#383939", "#676869", "#F5F5F2", "#D1D1D1", "#FFFFFF"

data = json.load(open(MANIFEST))
CATS = [c for c in data["categories"]]
ADDONS = data["addons"]
CAT_BY_KEY = {c["key"]: c for c in CATS}


# --------------------------------------------------------------------------
# Validate + drift-check
# --------------------------------------------------------------------------
def fail(msg):
    sys.stderr.write("✗ gen-addons-docs: %s\n" % msg)
    sys.exit(1)


referenced = set()
for a in ADDONS:
    if a["category"] not in CAT_BY_KEY:
        fail("add-on %r has unknown category %r" % (a["name"], a["category"]))
    for cfg in a["configs"]:
        referenced.add(os.path.normpath(cfg))
        if not os.path.exists(os.path.join(ROOT, cfg)):
            fail("add-on %r references missing config file %s" % (a["name"], cfg))

on_disk = set()
for d in SCAN_DIRS:
    base = os.path.join(ROOT, d)
    for dirpath, _, files in os.walk(base):
        for fn in files:
            if fn.endswith(".nix") and fn != "default.nix":
                rel = os.path.normpath(os.path.relpath(os.path.join(dirpath, fn), ROOT))
                on_disk.add(rel)

undocumented = sorted(on_disk - referenced)
if undocumented:
    fail(
        "these config files are not documented in lib/addons.json:\n    "
        + "\n    ".join(undocumented)
        + "\n  Add an entry (or fold them into an existing add-on's 'configs')."
    )
stale = sorted(referenced - on_disk - {os.path.normpath("config/core/session.nix")})
if stale:
    fail(
        "lib/addons.json references files outside the scan set that don't exist:\n    "
        + "\n    ".join(stale)
    )

enabled = [a for a in ADDONS if a.get("enabled", True)]
disabled = [a for a in ADDONS if not a.get("enabled", True)]
print("addons: %d documented (%d on by default, %d optional), %d config files covered"
      % (len(ADDONS), len(enabled), len(disabled), len(on_disk)))


# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------
def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def wrap(t, n):
    words, out, cur = t.split(), [], ""
    for w in words:
        if len(cur) + len(w) + (1 if cur else 0) <= n:
            cur = (cur + " " + w).strip()
        else:
            if cur:
                out.append(cur)
            cur = w
    if cur:
        out.append(cur)
    return out


def addons_in(cat_key):
    return [a for a in ADDONS if a["category"] == cat_key]


# --------------------------------------------------------------------------
# addons.svg — one card per category, add-ons stacked inside, 3 balanced columns
# --------------------------------------------------------------------------
COLS = 3
CW = 372          # card width
COL_GAP = 20
MX = 24           # left/right margin
TOP = 108         # space for title + legend
NAME_H = 17       # name line height
PURP_H = 11       # purpose line height
BLOCK_PAD = 7     # gap between add-on blocks
HEAD_H = 46       # card header height
CARD_PAD = 12
INNER = CW - 2 * CARD_PAD


def block_height(a):
    lines = wrap(a["purpose"], max(10, int(INNER / 5.6)))[:2]
    return NAME_H + len(lines) * PURP_H + BLOCK_PAD


def card_height(cat):
    items = addons_in(cat["key"])
    return HEAD_H + sum(block_height(a) for a in items) + CARD_PAD


# Greedy shortest-column packing to balance the three columns.
col_y = [TOP] * COLS
col_x = [MX + i * (CW + COL_GAP) for i in range(COLS)]
placements = []  # (col, y, cat)
for cat in CATS:
    c = min(range(COLS), key=lambda i: col_y[i])
    placements.append((c, col_y[c], cat))
    col_y[c] += card_height(cat) + COL_GAP

W = MX * 2 + COLS * CW + (COLS - 1) * COL_GAP
H = max(col_y) + 16

o = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H:.0f}" '
     f'viewBox="0 0 {W} {H:.0f}" font-family="Nunito,\'Helvetica Neue\',Arial,sans-serif">']
o.append(f'<rect width="{W}" height="{H:.0f}" fill="{WHITE}"/>')
o.append(f'<text x="{MX}" y="34" fill="{MUTED}" font-size="12" font-weight="700" '
         f'letter-spacing="3">TIMVIM · ADD-ONS &amp; COMPONENTS</text>')
o.append(f'<text x="{MX}" y="62" fill="{CHAR}" font-size="24" font-weight="800">'
         f'Everything in the box, by purpose</text>')
o.append(f'<text x="{MX}" y="84" fill="{MUTED}" font-size="12.5">'
         f'{len(enabled)} add-ons on by default · {len(disabled)} optional · '
         f'grouped into {len(CATS)} families. Full links in the table below.</text>')

for col, y0, cat in placements:
    x = col_x[col]
    items = addons_in(cat["key"])
    ch = card_height(cat)
    color = PALETTE[cat["color"]]
    # card
    o.append(f'<rect x="{x}" y="{y0:.0f}" width="{CW}" height="{ch:.0f}" rx="10" '
             f'fill="{WHITE}" stroke="{RULE}"/>')
    # header bar (rounded top)
    o.append(f'<path d="M{x},{y0+10:.0f} q0,-10 10,-10 h{CW-20} q10,0 10,10 '
             f'v{HEAD_H-10} h-{CW} z" fill="{color}"/>')
    hc = CHAR if cat["color"] == "ORANGE" else WHITE
    o.append(f'<text x="{x+CARD_PAD}" y="{y0+22:.0f}" fill="{hc}" font-size="15" '
             f'font-weight="800">{esc(cat["name"])}</text>')
    o.append(f'<text x="{x+CARD_PAD}" y="{y0+38:.0f}" fill="{hc}" font-size="10.5" '
             f'opacity="0.92">{esc(cat["blurb"])}</text>')
    # add-on blocks
    by = y0 + HEAD_H + 4
    for a in items:
        off = not a.get("enabled", True)
        dot = MUTED if off else color
        nm = a["name"] + ("  ·  off" if off else "")
        nmc = MUTED if off else CHAR
        o.append(f'<circle cx="{x+CARD_PAD+4}" cy="{by+7:.0f}" r="3.5" fill="{dot}"/>')
        o.append(f'<text x="{x+CARD_PAD+14}" y="{by+11:.0f}" fill="{nmc}" '
                 f'font-size="12.5" font-weight="700">{esc(nm)}</text>')
        yy = by + NAME_H
        for line in wrap(a["purpose"], max(10, int(INNER / 5.6)))[:2]:
            o.append(f'<text x="{x+CARD_PAD+14}" y="{yy+2:.0f}" fill="{MUTED}" '
                     f'font-size="10.5">{esc(line)}</text>')
            yy += PURP_H
        by += block_height(a)

o.append(f'<text x="{MX}" y="{H-8:.0f}" fill="{MUTED}" font-size="10.5">'
         f'Auto-generated from lib/addons.json — kept in lock-step with the live '
         f'config. Coloured dots follow each family; grey = off by default.</text>')
o.append("</svg>")
open(os.path.join(DIAG, "addons.svg"), "w").write("\n".join(o))
print("wrote docs/assets/diagrams/addons.svg")


# --------------------------------------------------------------------------
# addons.md — grouped, linked tables
# --------------------------------------------------------------------------
def md_txt(s):
    return s.replace("|", "\\|")


m = []
m.append("# Add-ons & Components\n")
m.append('!!! info "Auto-generated"\n'
         "    This page and its diagram are generated from `lib/addons.json` by\n"
         "    `lib/gen-addons-docs.py`, and drift-checked against the live\n"
         "    `config/` tree. Do not edit by hand — run `nix run .#handbook-addons`.\n")
m.append("timvim bundles **%d add-ons** — %d enabled out of the box and %d shipped "
         "but off by default — on top of the [NVF](https://github.com/notashelf/nvf) "
         "framework. The [Overview](index.md) shows them as a visual map; the full "
         "list is grouped into %d families below.\n"
         % (len(ADDONS), len(enabled), len(disabled), len(CATS)))

for cat in CATS:
    items = addons_in(cat["key"])
    if not items:
        continue
    m.append(f"## {cat['name']}\n")
    m.append(f"*{cat['blurb']}.*\n")
    m.append("| Add-on | Purpose | Default |")
    m.append("|--------|---------|---------|")
    for a in items:
        on = "✅ On" if a.get("enabled", True) else "⚪ Off"
        m.append(f"| [{md_txt(a['name'])}]({a['url']}) | {md_txt(a['purpose'])} | {on} |")
    m.append("")

m.append('!!! tip "See also"\n'
         "    The [Overview](index.md) explains how these fit together, and the\n"
         "    [Developer Guide → Architecture](../developer-guide/architecture.md)\n"
         "    shows how the flake wires them into the editor.\n")
open(os.path.join(DOCS, "overview", "addons.md"), "w").write("\n".join(m))
print("wrote docs/overview/addons.md")
