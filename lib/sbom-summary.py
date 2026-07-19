#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Kartoza (Pty) Ltd <tim@kartoza.com>
# SPDX-License-Identifier: MIT
#
# Summarise a CycloneDX SBOM (from sbomnix) as a Markdown block suitable for a
# PR comment or release note. Prints to stdout.
#
#   python3 lib/sbom-summary.py sbom/timvim.cdx.json
import json, sys
from collections import Counter

path = sys.argv[1]
doc = json.load(open(path))
comps = doc.get("components", [])

def lic_of(c):
    for l in c.get("licenses", []) or []:
        if "expression" in l:
            return l["expression"]
        lo = l.get("license", {})
        return lo.get("id") or lo.get("name") or "unknown"
    return "unknown"

lics = Counter(lic_of(c) for c in comps)
tool = ""
meta = doc.get("metadata", {})
comp = meta.get("component", {})
if comp:
    tool = f"{comp.get('name','')} {comp.get('version','')}".strip()

print("### 📦 Software Bill of Materials")
print()
subject = f" for **{tool}**" if tool else ""
print(f"**{len(comps)}** components{subject} (runtime closure).")
print()
print("| Licence | Components |")
print("|---------|-----------:|")
for lic, n in lics.most_common(15):
    print(f"| {lic} | {n} |")
if len(lics) > 15:
    other = sum(n for _, n in lics.most_common()[15:])
    print(f"| _… {len(lics) - 15} more_ | {other} |")
print()
print("_Full CycloneDX + SPDX SBOMs are attached as build artefacts._")
