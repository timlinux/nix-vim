#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Kartoza (Pty) Ltd <tim@kartoza.com>
# SPDX-License-Identifier: MIT
#
# Generate the handbook's keymap reference + keyboard-layout SVGs from a JSON
# dump of timvim's LIVE keymaps (produced by lib/dump-keymaps.lua running the
# built Neovim headless). The docs are therefore always in lock-step with the
# actual configuration — edit a binding in config/, rebuild the docs, done.
#
#   python3 lib/gen-keymap-docs.py keymaps.json [repo-root]
import json, os, re, sys

JSON = sys.argv[1]
ROOT = sys.argv[2] if len(sys.argv) > 2 else "."
DOCS = os.path.join(ROOT, "docs")
DIAG = os.path.join(DOCS, "assets", "diagrams")
os.makedirs(DIAG, exist_ok=True)

d = json.load(open(JSON))
M = d["modes"]

# kartozaColors
BLUE, ORANGE, GREY, TEAL, RED = "#569FC6", "#DF9E2F", "#8A8B8B", "#06969A", "#CC0403"
CHAR, MUTED, CLOUD, RULE, WHITE, LIT = "#383939", "#676869", "#F5F5F2", "#D1D1D1", "#FFFFFF", "#FAFAF8"

PUA = re.compile("[\ue000-\uf8ff\U000f0000-\U000fffff]")

def clean(desc):
    s = PUA.sub("", desc or "").strip()
    s = re.sub(r"^\s*\[[^\]]+\]\s*", "", s)   # leading [plugin] tag
    s = re.sub(r"\s*\[[^\]]+\]\s*$", "", s)   # trailing [plugin] tag
    return s.strip()

def style_for(desc):
    dl = desc.lower()
    if "copilot" in dl or "claude" in dl:
        return "orange"
    if "flash" in dl or "split" in dl or "resize" in dl or "terminal" in dl:
        return "teal"
    return "blue"

# --------------------------------------------------------------------------
# keymap.md — exhaustive grouped tables
# --------------------------------------------------------------------------
GROUP_NAMES = {
    "a": "Assistant", "b": "Buffers", "c": "Code", "d": "Debug", "f": "Files",
    "g": "Git", "h": "Gitsigns", "i": "Image", "l": "LSP", "m": "Markdown",
    "n": "Navigate", "N": "Notifications", "o": "GitHub", "r": "Refactor",
    "s": "Session", "t": "Toggles", "T": "Test", "x": "Lists", "z": "Spell",
}

def disp_lhs(lhs):
    return "<leader>" + lhs[1:] if lhs.startswith(" ") else lhs

def md_key(lhs):
    return "`" + disp_lhs(lhs).replace("|", "\\|") + "`"

def md_txt(s):
    return s.replace("|", "\\|")

# aggregate normal-ish modes (n, v, x, o) by lhs
agg = {}
for m in ("n", "v", "x", "o"):
    for e in M.get(m, []):
        desc = clean(e["desc"])
        a = agg.setdefault(e["lhs"], {"desc": "", "modes": set()})
        a["modes"].add("v" if m in ("v", "x") else m)
        if desc and not a["desc"]:
            a["desc"] = desc

def modes_str(s):
    order = {"n": 0, "v": 1, "o": 2}
    return ", ".join(sorted(s, key=lambda x: order.get(x, 9)))

def row(lhs, desc, modes):
    return f"| {md_key(lhs)} | {modes_str(modes)} | {md_txt(desc)} |"

leader = {k: v for k, v in agg.items() if k.startswith(" ") and v["desc"]}
direct = {k: v for k, v in agg.items()
          if not k.startswith(" ") and v["desc"]
          and not re.fullmatch(r"<(C|M|A|S|F|C-S)-.*>|<F\d+>", k)}
mods = {k: v for k, v in agg.items()
        if not k.startswith(" ") and v["desc"]
        and re.fullmatch(r"<(C|M|A|S|F|C-S)-.*>|<F\d+>", k)}
insert = {e["lhs"]: clean(e["desc"]) for e in M.get("i", []) if clean(e["desc"])}
term = {e["lhs"]: clean(e["desc"]) for e in M.get("t", []) if clean(e["desc"])}

# group leader by second char
groups = {}
for lhs, v in leader.items():
    g = lhs[1] if len(lhs) > 1 else "?"
    groups.setdefault(g, []).append((lhs, v))

lines = []
lines.append("# Full Keymap\n")
lines.append(
    "!!! info \"Auto-generated\"\n"
    "    This page is generated at build time from timvim's **live keymaps**\n"
    "    (the built Neovim is queried headless). It is always in step with the\n"
    "    configuration — do not edit it by hand.\n"
)
lines.append(
    f"timvim sets **{sum(len(v['modes']) for v in agg.values()) + len(insert)}** "
    "keymaps. The leader is ++space++. Tables below group them the way "
    "which-key does.\n"
)

lines.append("## Leader groups\n")
for g in sorted(groups, key=lambda c: (c.lower(), c.isupper())):
    name = GROUP_NAMES.get(g, f"`{g}` group")
    lines.append(f"### {name} — `<leader>{g}`\n")
    lines.append("| Key | Mode | Action |")
    lines.append("|-----|------|--------|")
    for lhs, v in sorted(groups[g]):
        lines.append(row(lhs, v["desc"], v["modes"]))
    lines.append("")

def simple_table(title, items, keycol="Key"):
    out = [f"## {title}\n", f"| {keycol} | Mode | Action |", "|-----|------|--------|"]
    for lhs, v in sorted(items.items()):
        out.append(row(lhs, v["desc"], v["modes"]))
    out.append("")
    return out

lines += simple_table("Direct keys (normal / visual)", direct)
lines += simple_table("Ctrl, Alt & function keys", mods)

lines.append("## Insert mode\n")
lines.append("| Key | Action |")
lines.append("|-----|--------|")
for lhs, desc in sorted(insert.items()):
    lines.append(f"| `{disp_lhs(lhs)}` | {md_txt(desc)} |")
lines.append("")

if term:
    lines.append("## Terminal mode\n")
    lines.append("| Key | Action |")
    lines.append("|-----|--------|")
    for lhs, desc in sorted(term.items()):
        lines.append(f"| `{disp_lhs(lhs)}` | {md_txt(desc)} |")
    lines.append("")

open(os.path.join(DOCS, "reference", "keymap.md"), "w").write("\n".join(lines))
print("wrote docs/reference/keymap.md  (%d leader, %d direct, %d mod, %d insert)"
      % (len(leader), len(direct), len(mods), len(insert)))

# --------------------------------------------------------------------------
# Keyboard SVGs — static Vim-default base with the LIVE customs overlaid
# --------------------------------------------------------------------------
nmap = {e["lhs"]: clean(e["desc"]) for e in M.get("n", []) if clean(e["desc"])}
imap = {e["lhs"]: clean(e["desc"]) for e in M.get("i", []) if clean(e["desc"])}

def norm_ctrl(v):
    return re.sub(r"<C-([a-z])>", lambda g: "<C-%s>" % g.group(1).upper(), v)

def parse_blink(root):
    # blink-cmp handles its completion keys internally, so they are NOT in the
    # keymap API. Read them from the one config file that declares them so the
    # insert-Ctrl board and the completion page stay accurate.
    p = os.path.join(root, "config", "core", "autocmp.nix")
    labels = {"close": "Close completion", "complete": "Trigger completion",
              "confirm": "Confirm completion", "next": "Completion next",
              "previous": "Completion prev",
              "scrollDocsDown": "Scroll docs down", "scrollDocsUp": "Scroll docs up"}
    out = {}
    if os.path.exists(p):
        t = open(p).read()
        for k, lab in labels.items():
            m = re.search(k + r'\s*=\s*"([^"]+)"', t)
            if m:
                out[norm_ctrl(m.group(1))] = lab
    return out

blink = parse_blink(ROOT)
imap.update(blink)                       # feed blink keys into the insert layers

U, GAP, RH, PAD_X, TOP = 62, 7, 62, 24, 92
ROWS = [
    [("Esc",1.5),("`",1),("1",1),("2",1),("3",1),("4",1),("5",1),("6",1),("7",1),("8",1),("9",1),("0",1),("-",1),("=",1),("Bksp",2)],
    [("Tab",1.5),("q",1),("w",1),("e",1),("r",1),("t",1),("y",1),("u",1),("i",1),("o",1),("p",1),("[",1),("]",1),("\\",1.5)],
    [("Caps",1.8),("a",1),("s",1),("d",1),("f",1),("g",1),("h",1),("j",1),("k",1),("l",1),(";",1),("'",1),("Enter",2.2)],
    [("Shift",2.3),("z",1),("x",1),("c",1),("v",1),("b",1),("n",1),("m",1),(",",1),(".",1),("/",1),("Shift",2.7)],
    [("Ctrl",1.4),("Alt",1.3),("Space",7),("Alt",1.3),("Ctrl",1.4)],
]
SHIFT_CAP = {"1":"!","2":"@","3":"#","4":"$","5":"%","6":"^","7":"&","8":"*","9":"(",
             "0":")","-":"_","=":"+","`":"~","[":"{","]":"}","\\":"|",";":":","'":'"',
             ",":"<",".":">","/":"?"}
DISP = {"Bksp":"⌫","Tab":"⇥","Caps":"Caps","Enter":"⏎","Shift":"⇧","Ctrl":"Ctrl",
        "Alt":"Alt","Space":"Space","Esc":"Esc","`":"`"}
STYLES = {"blue":(BLUE,WHITE,WHITE),"orange":(ORANGE,CHAR,CHAR),"teal":(TEAL,WHITE,WHITE),
          "red":(RED,WHITE,WHITE),"default":(WHITE,CHAR,MUTED),
          "literal":(LIT,"#B7B7B5","#B7B7B5"),"mod":(CLOUD,MUTED,MUTED)}

# Vim-default reference labels (constant — these are Vim, not timvim config).
DEF_PLAIN = {"a":"Append","b":"Word back","c":"Change op","d":"Delete op","e":"Word end",
    "f":"Find >","g":"+goto","h":"Left","i":"Insert","j":"Down","k":"Up","l":"Right",
    "m":"Set mark","n":"Next match","o":"Open below","p":"Paste","q":"Macro","r":"Replace ch",
    "s":"Subst ch","t":"Till >","u":"Undo","v":"Visual","w":"Word fwd","x":"Del char",
    "y":"Yank op","z":"+fold","`":"To mark","0":"Line start","=":"Auto-indent","[":"+prev",
    "]":"+next","\\":"localleader",";":"Repeat find","'":"To mark","," :"Repeat back",
    ".":"Repeat edit","/":"Search"}
DEF_SHIFT = {"a":"Append EOL","b":"WORD back","c":"Change EOL","d":"Delete EOL","e":"WORD end",
    "f":"Find <","g":"End of file","h":"Top screen","i":"Insert BOL","j":"Join","k":"Keyword",
    "l":"Bottom scr","m":"Mid screen","n":"Prev match","o":"Open above","p":"Paste before",
    "q":"Ex mode","r":"Replace","s":"Change ln","t":"Till <","u":"Undo line","v":"Visual line",
    "w":"WORD fwd","x":"Del before","y":"Yank line","z":"+ZZ quit","4":"End of line",
    "5":"Match pair","6":"First col","[":"Para {","]":"Para }","\\":"To column",";":"Cmdline",
    "'":"Register",",":"Indent <",".":"Indent >","/":"Search back","`":"Toggle case"}
DEF_NCTRL = {"a":"Increment","b":"Page up","c":"Cancel","d":"½ down","e":"Scroll dn","f":"Page dn",
    "g":"File info","h":"Left","i":"Jump fwd","j":"Down","k":"Up","l":"Right","m":"Enter",
    "n":"Down","o":"Jump back","p":"Up","q":"V-block","r":"Redo","t":"Tag","u":"½ up",
    "v":"V-block","w":"+window","x":"Decrement","y":"Scroll up","z":"Suspend"}
DEF_ICTRL = {"a":"Prev insert","c":"Normal","d":"Unindent","e":"Char below","h":"Backspace",
    "j":"Newline","k":"Digraph","n":"Compl next","o":"One cmd","p":"Compl prev","r":"Insert reg",
    "t":"Indent","u":"Del to BOL","v":"Insert lit","w":"Del word","x":"+compl","y":"Char above"}

def cap_of(tok, shifted):
    if tok in DISP:
        return DISP[tok]
    if shifted:
        return SHIFT_CAP.get(tok, tok.upper())
    return tok

def board(fname, title, subtitle, base, overlay, shifted=False, active_mod=None,
          specials=None, space_override=None):
    specials = specials or {}
    maxw = max(sum(w for _, w in r) * U + (len(r) - 1) * GAP for r in ROWS)
    W = PAD_X * 2 + maxw
    H = TOP + len(ROWS) * RH + 40
    o = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W:.0f}" height="{H}" viewBox="0 0 {W:.0f} {H}" font-family="Nunito,\'Helvetica Neue\',Arial,sans-serif">']
    o.append(f'<rect width="{W:.0f}" height="{H}" fill="{WHITE}"/>')
    o.append(f'<text x="{PAD_X}" y="34" fill="{MUTED}" font-size="12" font-weight="700" letter-spacing="3">TIMVIM · KEYBOARD MAP</text>')
    o.append(f'<text x="{PAD_X}" y="62" fill="{CHAR}" font-size="23" font-weight="800">{title}</text>')
    o.append(f'<text x="{PAD_X}" y="82" fill="{MUTED}" font-size="12.5">{subtitle}</text>')
    lx = W - PAD_X - 250
    for i, (lbl, st) in enumerate([("Custom", BLUE), ("AI", ORANGE), ("Motion", TEAL), ("Default", WHITE)]):
        x = lx + i * 64
        o.append(f'<rect x="{x:.0f}" y="52" width="11" height="11" rx="2" fill="{st}" stroke="{RULE}"/>')
        o.append(f'<text x="{x+16:.0f}" y="62" fill="{MUTED}" font-size="10.5">{lbl}</text>')
    y = TOP
    for r in ROWS:
        x = PAD_X
        for tok, wu in r:
            kw = wu * U
            func, style = "", "literal"
            if tok in ("Shift","Ctrl","Alt","Caps"):
                style = "blue" if (active_mod and tok == active_mod) else "mod"
            elif tok == "Space":
                if space_override:
                    func, style = space_override
                else:
                    style = "mod"
            elif tok in ("Tab","Enter","Bksp","Esc"):
                if tok in specials:
                    func, style = specials[tok]
                else:
                    style = "blue" if (active_mod and tok == active_mod) else "mod"
            else:
                if tok in base:
                    func, style = base[tok], "default"
                if tok in overlay:
                    func, style = overlay[tok]
            fill, capc, funcc = STYLES[style]
            stroke = RULE if fill in (WHITE, LIT, CLOUD) else fill
            o.append(f'<rect x="{x:.0f}" y="{y}" width="{kw:.0f}" height="{RH-GAP}" rx="7" fill="{fill}" stroke="{stroke}"/>')
            cap = cap_of(tok, shifted)
            o.append(f'<text x="{x+7:.0f}" y="{y+16}" fill="{capc}" font-size="12" font-weight="800" font-family="JetBrains Mono,monospace">{esc(cap)}</text>')
            for li, line in enumerate(wrap(func, max(6, int(kw / 6.2)))):
                o.append(f'<text x="{x+kw/2:.0f}" y="{y+30+li*10}" fill="{funcc}" font-size="8" text-anchor="middle">{esc(line)}</text>')
            x += kw + GAP
        y += RH
    o.append(f'<text x="{PAD_X}" y="{H-14}" fill="{MUTED}" font-size="10.5">Coloured keys are timvim custom bindings (generated from the live config). Grey = Vim default. Space is the leader.</text>')
    o.append("</svg>")
    open(os.path.join(DIAG, fname), "w").write("\n".join(o))
    print("wrote", fname)

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
    return out[:3]

# Build overlays from live keymaps ------------------------------------------
def ov_plain():
    ov = {}
    for c in "abcdefghijklmnopqrstuvwxyz`1234567890-=[]\\;',./":
        if c in nmap:
            ov[c] = (nmap[c], style_for(nmap[c]))
    return ov

def ov_shift():
    ov = {}
    for c in "abcdefghijklmnopqrstuvwxyz":
        u = c.upper()
        if u in nmap:
            ov[c] = (nmap[u], style_for(nmap[u]))
    for tok, sym in SHIFT_CAP.items():
        if sym in nmap:
            ov[tok] = (nmap[sym], style_for(nmap[sym]))
    return ov

def ov_ctrl(src):
    ov = {}
    for c in "abcdefghijklmnopqrstuvwxyz0123456789":
        lhs = "<C-%s>" % c.upper()
        if lhs in src:
            ov[c] = (src[lhs], style_for(src[lhs]))
    return ov

def ov_alt(src):
    ov = {}
    for tok in list("abcdefghijklmnopqrstuvwxyz") + ["[", "]", "\\"]:
        lhs = "<M-%s>" % tok
        if lhs in src:
            ov[tok] = (src[lhs], style_for(src[lhs]))
    return ov

def specials_from(src, keys):
    out = {}
    lookup = {"Esc": "<Esc>", "Tab": "<Tab>", "Enter": "<CR>", "Bksp": "<BS>"}
    for tok in keys:
        lhs = lookup[tok]
        if lhs in src:
            out[tok] = (src[lhs], style_for(src[lhs]))
    return out

LEADER = ("Leader (which-key)", "orange")

board("keyboard-normal-plain.svg", "Normal mode — unmodified keys",
      "The base command layer. Coloured keys are timvim custom bindings.",
      DEF_PLAIN, ov_plain(), space_override=LEADER)
board("keyboard-normal-shift.svg", "Normal mode — Shift",
      "Shifted commands and symbols. Re-bound keys are highlighted.",
      DEF_SHIFT, ov_shift(), shifted=True, active_mod="Shift", space_override=LEADER)
board("keyboard-normal-ctrl.svg", "Normal mode — Ctrl",
      "Ctrl and (for split resize) Alt combinations.",
      DEF_NCTRL, ov_ctrl(nmap), active_mod="Ctrl")
board("keyboard-insert-plain.svg", "Insert mode — typing",
      "Letters insert literally; the working keys are Esc, Tab and Enter.",
      {}, {}, active_mod=None,
      specials=specials_from(imap, ["Tab", "Enter", "Bksp"]) or None)
csp = imap.get("<C-Space>")
board("keyboard-insert-ctrl.svg", "Insert mode — Ctrl",
      "Completion (blink-cmp) and Copilot live on this layer.",
      DEF_ICTRL, ov_ctrl(imap), active_mod="Ctrl",
      space_override=((csp, "blue") if csp else None))
board("keyboard-insert-alt.svg", "Insert mode — Alt",
      "Alt accepts Copilot ghost text piecewise and cycles suggestions.",
      {}, ov_alt(imap), active_mod="Alt")

print("keyboard SVGs regenerated from live keymaps")

# --------------------------------------------------------------------------
# which-key.md + leader-keymap.svg  — group MAP (membership is live; the group
# display name / one-line blurb / family colour are labels).
# --------------------------------------------------------------------------
GROUP_DESC = {
    "a": "Claude + Copilot", "b": "Find & swap buffers", "c": "Format, rename, colour",
    "d": "DAP & breakpoints", "f": "Find, grep, Yazi", "g": "Blame, hunks, diffs",
    "h": "Gitsigns hunks", "i": "Image preview", "l": "Diagnostics & Trouble",
    "m": "Markdown (.md)", "n": "LSP defs & refs", "N": "Notifications",
    "o": "Octo GitHub", "r": "Extract & inline", "s": "Save & restore",
    "t": "UI & feature flags", "T": "Neotest", "x": "Quickfix & symbols", "z": "Spell",
}
FAM = {"a": BLUE, "f": BLUE, "n": BLUE, "l": BLUE,
       "g": TEAL, "h": TEAL, "o": TEAL, "b": TEAL, "s": TEAL,
       "d": ORANGE, "r": ORANGE, "T": ORANGE, "t": ORANGE,
       "c": GREY, "x": GREY, "N": GREY, "m": GREY, "z": GREY, "i": GREY}

present_groups = sorted(groups, key=lambda c: (c.lower(), c.isupper()))

# --- leader-keymap.svg (only groups that actually exist) ---
def gen_leader_svg():
    cards = [(g, GROUP_NAMES.get(g, g), GROUP_DESC.get(g, ""), FAM.get(g, BLUE))
             for g in present_groups]
    cols, cw, ch, gap, mx, top = 4, 194, 62, 12, 24, 84
    rows = (len(cards) + cols - 1) // cols
    W = mx * 2 + cols * cw + (cols - 1) * gap
    H = top + rows * ch + (rows - 1) * gap + 24
    o = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="Nunito,\'Helvetica Neue\',Arial,sans-serif">']
    o.append(f'<rect width="{W}" height="{H}" fill="{WHITE}"/>')
    o.append(f'<text x="{mx}" y="34" fill="{MUTED}" font-size="12" font-weight="700" letter-spacing="3">TIMVIM · LEADER KEY MAP</text>')
    o.append(f'<text x="{mx}" y="62" fill="{CHAR}" font-size="24" font-weight="800">Press&#160; Space&#160; then a group letter</text>')
    lx = W - mx - 300
    for i, (lbl, col) in enumerate([("Find/Lang", BLUE), ("Git/VCS", TEAL), ("Run/Debug", ORANGE), ("Aux/UI", GREY)]):
        x = lx + i * 76
        o.append(f'<rect x="{x}" y="20" width="10" height="10" rx="2" fill="{col}"/>')
        o.append(f'<text x="{x+15}" y="29" fill="{MUTED}" font-size="10">{lbl}</text>')
    for idx, (k, name, desc, col) in enumerate(cards):
        r, c = divmod(idx, cols)
        x = mx + c * (cw + gap); y = top + r * (ch + gap)
        o.append(f'<rect x="{x}" y="{y}" width="{cw}" height="{ch}" rx="8" fill="{WHITE}" stroke="{RULE}"/>')
        bx, bsz = x + 10, 42; by = y + (ch - bsz) / 2
        tc = CHAR if col == ORANGE else WHITE
        o.append(f'<rect x="{bx}" y="{by:.0f}" width="{bsz}" height="{bsz}" rx="6" fill="{col}"/>')
        o.append(f'<text x="{bx+bsz/2:.0f}" y="{by+bsz/2+7:.0f}" fill="{tc}" font-size="22" font-weight="800" text-anchor="middle" font-family="JetBrains Mono,monospace">{esc(k)}</text>')
        tx = bx + bsz + 12
        o.append(f'<text x="{tx:.0f}" y="{y+26}" fill="{CHAR}" font-size="15" font-weight="700">{esc(name)}</text>')
        o.append(f'<text x="{tx:.0f}" y="{y+45}" fill="{MUTED}" font-size="11.5">{esc(desc)}</text>')
    o.append("</svg>")
    open(os.path.join(DIAG, "leader-keymap.svg"), "w").write("\n".join(o))
    print("wrote leader-keymap.svg (%d live groups)" % len(cards))

gen_leader_svg()

# --- which-key.md ---
NONLEADER = [("gp", "Goto Preview"), ("gz", "Surround"), ("gZ", "Surround (line)")]
alllhs = [e["lhs"] for m in ("n", "o", "x", "v") for e in M.get(m, [])]
nonleader_present = [(p, n, sum(1 for l in alllhs if l.startswith(p) and l != p))
                     for p, n in NONLEADER]
nonleader_present = [t for t in nonleader_present if t[2]]

wk = []
wk.append("# Which-Key Menus\n")
wk.append('!!! info "Auto-generated"\n    This page is generated from timvim\'s live keymaps. The group\n    membership and counts come straight from the configuration.\n')
wk.append("Press ++space++ (the leader) and pause: the **which-key** popup lists every\ngroup. Each group gathers related actions under one letter.\n")
wk.append("![The timvim leader key map — every group, colour-coded by family](../assets/diagrams/leader-keymap.svg){ .kz-figure }\n")
wk.append("## Top-level groups\n")
wk.append("| Prefix | Group | Bindings |")
wk.append("|--------|-------|----------|")
for g in present_groups:
    name = GROUP_NAMES.get(g, f"`{g}` group")
    wk.append(f"| `<leader>{g}` | [{name}](keymap.md) | {len(groups[g])} |")
wk.append("")
if nonleader_present:
    wk.append("## Non-leader groups\n")
    wk.append("| Prefix | Group | Bindings |")
    wk.append("|--------|-------|----------|")
    for p, n, c in nonleader_present:
        wk.append(f"| `{p}` | {n} | {c} |")
    wk.append("")
wk.append('!!! note "See also"\n    For every key in a group — with modes and actions — see the\n    [Full Keymap](keymap.md). For the physical-key view, see the\n    [Keyboard Layouts](keyboard.md).\n')
open(os.path.join(DOCS, "reference", "which-key.md"), "w").write("\n".join(wk))
print("wrote docs/reference/which-key.md (%d groups)" % len(present_groups))

# --------------------------------------------------------------------------
# completion.md + completion-keys.svg  — blink menu vs Copilot ghost text
# --------------------------------------------------------------------------
lab2lhs = {v: k for k, v in blink.items()}
blink_order = ["Completion next", "Completion prev", "Confirm completion",
               "Trigger completion", "Close completion", "Scroll docs down", "Scroll docs up"]
blink_rows = [(lab2lhs[l], l) for l in blink_order if l in lab2lhs]

copilot_rows = []
seen = set()
for e in M.get("i", []):
    if "copilot" in (e["desc"] or "").lower():
        lhs = disp_lhs(e["lhs"])
        if lhs not in seen:
            seen.add(lhs)
            act = clean(e["desc"])
            act = act[:1].upper() + act[1:] if act else act
            copilot_rows.append((lhs, act))

def keydisp(lhs):
    return lhs.replace("<C-Space>", "Ctrl+Space")

def gen_completion_svg():
    panels = [("Completion menu", "blink-cmp", BLUE, blink_rows),
              ("Ghost text", "Copilot", TEAL, copilot_rows)]
    pw, gap, mx, top = 396, 24, 24, 84
    rowh = 34
    maxrows = max(len(p[3]) for p in panels)
    W = mx * 2 + 2 * pw + gap
    H = top + 52 + maxrows * rowh + 24
    o = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="Nunito,\'Helvetica Neue\',Arial,sans-serif">']
    o.append(f'<rect width="{W}" height="{H}" fill="{WHITE}"/>')
    o.append(f'<text x="{mx}" y="34" fill="{MUTED}" font-size="12" font-weight="700" letter-spacing="3">TIMVIM · COMPLETION &amp; AI KEYS</text>')
    o.append(f'<text x="{mx}" y="62" fill="{CHAR}" font-size="24" font-weight="800">Two systems, one muscle memory</text>')
    for i, (title, sub, col, rws) in enumerate(panels):
        px = mx + i * (pw + gap); py = top; ph = 52 + maxrows * rowh
        o.append(f'<rect x="{px}" y="{py}" width="{pw}" height="{ph}" rx="10" fill="{WHITE}" stroke="{RULE}"/>')
        o.append(f'<path d="M{px},{py+10} q0,-10 10,-10 h{pw-20} q10,0 10,10 v34 h-{pw} z" fill="{col}"/>')
        hc = CHAR if col == ORANGE else WHITE
        o.append(f'<text x="{px+16}" y="{py+30}" fill="{hc}" font-size="16" font-weight="800">{esc(title)}</text>')
        o.append(f'<text x="{px+pw-16}" y="{py+30}" fill="{hc}" font-size="12" font-weight="700" text-anchor="end" opacity="0.9" font-family="JetBrains Mono,monospace">{esc(sub)}</text>')
        for j, (key, act) in enumerate(rws):
            key = keydisp(key)
            ry = py + 52 + j * rowh
            if j % 2 == 1:
                o.append(f'<rect x="{px+1}" y="{ry}" width="{pw-2}" height="{rowh}" fill="{CLOUD}"/>')
            chipw = 10 + len(key) * 8.5
            o.append(f'<rect x="{px+14}" y="{ry+6}" width="{chipw:.0f}" height="22" rx="5" fill="{CLOUD}" stroke="{RULE}"/>')
            o.append(f'<text x="{px+14+chipw/2:.0f}" y="{ry+21}" fill="{CHAR}" font-size="12" font-weight="700" text-anchor="middle" font-family="JetBrains Mono,monospace">{esc(key)}</text>')
            o.append(f'<text x="{px+28+chipw:.0f}" y="{ry+22}" fill="{CHAR}" font-size="13.5">{esc(act)}</text>')
    o.append("</svg>")
    open(os.path.join(DIAG, "completion-keys.svg"), "w").write("\n".join(o))
    print("wrote completion-keys.svg (%d blink, %d copilot)" % (len(blink_rows), len(copilot_rows)))

gen_completion_svg()

cm = []
cm.append("# Completion Keys\n")
cm.append('!!! info "Auto-generated"\n    Generated from the live configuration — blink-cmp keys from the\n    completion config, Copilot keys from the running editor.\n')
cm.append("timvim has **two** completion systems, kept deliberately apart:\n")
cm.append("- **blink-cmp** — the structured completion *menu* (LSP, snippets, paths).\n"
          "- **Copilot** — inline **ghost text** you accept directly, no menu.\n")
cm.append("![Completion menu keys versus Copilot ghost-text keys](../assets/diagrams/completion-keys.svg){ .kz-figure }\n")
cm.append("## Completion menu — blink-cmp\n")
cm.append("| Key | Action |")
cm.append("|-----|--------|")
for lhs, lab in blink_rows:
    cm.append(f"| `{keydisp(lhs)}` | {lab} |")
cm.append("")
cm.append("## Ghost text — Copilot\n")
cm.append("| Key | Action |")
cm.append("|-----|--------|")
for lhs, act in sorted(copilot_rows):
    cm.append(f"| `{lhs}` | {md_txt(act)} |")
cm.append("")
cm.append('!!! tip "How to tell them apart"\n    A **popup list** you scroll is blink-cmp. **Faint grey text** inline after\n    the cursor is Copilot ghost text.\n')
open(os.path.join(DOCS, "reference", "completion.md"), "w").write("\n".join(cm))
print("wrote docs/reference/completion.md")
