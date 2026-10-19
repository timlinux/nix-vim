#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Kartoza (Pty) Ltd <tim@kartoza.com>
# SPDX-License-Identifier: MIT
"""timvim typing-latency benchmark driver.

Runs lib/bench-typing.lua headless against the *built* editor for one or
more scenarios, and records the resulting latency stats into a local
SQLite database alongside the commit they were measured against.

Usage (normally via `nix run .#bench-typing`, which sets NVIM_BIN):
    python3 lib/bench_record.py [--scenario code prose] [--trigger manual]
                                 [--strict] [--db PATH]

Note on commit attribution: when run from a pre-commit hook, the commit
being created does not exist yet, so `git rev-parse HEAD` resolves to the
*parent* commit. The working tree at hook time is what will become that
new commit's content, but the row is attributed one commit behind it.
Rows record `dirty` and `trigger_src` so this is always visible rather
than silently misleading. Run `nix run .#bench-typing` manually right
after a commit if you want a row attributed to that exact hash.
"""

import argparse
import json
import os
import shutil
import socket
import sqlite3
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

def _repo_root():
    # NOT Path(__file__).parent.parent: `nix run` copies this file into the
    # store as a single flat file (${./lib/bench_record.py}), with no
    # sibling lib/ directory to walk up from. The repo is wherever the user
    # is standing when they invoke `timvim bench-typing` / `nix run`, same
    # assumption every other `nix run .#foo` app in this flake already makes.
    try:
        out = subprocess.check_output(
            ["git", "rev-parse", "--show-toplevel"], cwd=Path.cwd(), text=True
        )
        return Path(out.strip())
    except (subprocess.CalledProcessError, FileNotFoundError):
        return Path.cwd()


REPO_ROOT = _repo_root()
BENCH_TMP = REPO_ROOT / ".bench-tmp"
DEFAULT_DB = REPO_ROOT / "benchmarks" / "typing-bench.sqlite"
# Same store-flattening issue as REPO_ROOT: BENCH_LUA_SCRIPT is set by the
# nix app wrapper to ${./lib/bench-typing.lua}'s real store path. Falling
# back to the repo-relative path keeps `python3 lib/bench_record.py` working
# for local iteration outside nix.
BENCH_SCRIPT = Path(os.environ.get("BENCH_LUA_SCRIPT", REPO_ROOT / "lib" / "bench-typing.lua"))

# scenario name -> file extension used inside .bench-tmp/
SCENARIOS = {
    "code": "lua",
    "prose": "md",
}

# A p95 regression larger than this (vs. the immediately preceding row for
# the same scenario) trips --strict.
REGRESSION_THRESHOLD = 0.20

SCHEMA = """
CREATE TABLE IF NOT EXISTS typing_benchmarks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    recorded_at TEXT NOT NULL,
    commit_hash TEXT NOT NULL,
    commit_short TEXT NOT NULL,
    branch TEXT,
    dirty INTEGER NOT NULL,
    trigger_src TEXT NOT NULL,
    scenario TEXT NOT NULL,
    filetype TEXT NOT NULL,
    keystrokes INTEGER NOT NULL,
    lsp_attached INTEGER NOT NULL,
    total_ms REAL NOT NULL,
    mean_ms REAL NOT NULL,
    median_ms REAL NOT NULL,
    p95_ms REAL NOT NULL,
    p99_ms REAL NOT NULL,
    max_ms REAL NOT NULL,
    stdev_ms REAL NOT NULL,
    nvim_version TEXT,
    host TEXT,
    latencies_json TEXT NOT NULL
);
"""


def git(*args):
    return subprocess.check_output(["git", *args], cwd=REPO_ROOT, text=True).strip()


def git_context():
    dirty = bool(git("status", "--porcelain"))
    return {
        "commit_hash": git("rev-parse", "HEAD"),
        "commit_short": git("rev-parse", "--short", "HEAD"),
        "branch": git("rev-parse", "--abbrev-ref", "HEAD"),
        "dirty": dirty,
    }


def run_scenario(nvim_bin, scenario, ext):
    BENCH_TMP.mkdir(parents=True, exist_ok=True)
    target = BENCH_TMP / f"bench-{scenario}.{ext}"
    target.unlink(missing_ok=True)  # fresh buffer state every run

    with tempfile.TemporaryDirectory(prefix="timvim-bench-") as home:
        home_path = Path(home)
        xdg_config = home_path / ".config"
        xdg_cache = home_path / ".cache"
        xdg_data = home_path / ".local" / "share"
        xdg_state = home_path / ".local" / "state"
        for d in (xdg_config, xdg_cache, xdg_data, xdg_state):
            d.mkdir(parents=True, exist_ok=True)

        report_path = home_path / "report.json"
        env = {
            **os.environ,
            "HOME": str(home_path),
            "XDG_CONFIG_HOME": str(xdg_config),
            "XDG_CACHE_HOME": str(xdg_cache),
            "XDG_DATA_HOME": str(xdg_data),
            "XDG_STATE_HOME": str(xdg_state),
            "BENCH_SCENARIO": scenario,
            "BENCH_FILE": str(target),
            "BENCH_REPORT": str(report_path),
        }

        result = subprocess.run(
            [nvim_bin, "--headless", "-c", f"luafile {BENCH_SCRIPT}", "+qa"],
            cwd=REPO_ROOT,
            env=env,
            capture_output=True,
            text=True,
            timeout=60,
        )

        target.unlink(missing_ok=True)

        if not report_path.exists():
            sys.stderr.write(
                f"✗ scenario '{scenario}' produced no report\n"
                f"--- stdout ---\n{result.stdout}\n--- stderr ---\n{result.stderr}\n"
            )
            sys.exit(1)

        return json.loads(report_path.read_text())


def previous_row(conn, scenario):
    cur = conn.execute(
        "SELECT median_ms, p95_ms FROM typing_benchmarks "
        "WHERE scenario = ? ORDER BY id DESC LIMIT 1",
        (scenario,),
    )
    return cur.fetchone()


def insert_row(conn, ctx, trigger_src, report):
    conn.execute(
        """
        INSERT INTO typing_benchmarks (
            recorded_at, commit_hash, commit_short, branch, dirty, trigger_src,
            scenario, filetype, keystrokes, lsp_attached,
            total_ms, mean_ms, median_ms, p95_ms, p99_ms, max_ms, stdev_ms,
            nvim_version, host, latencies_json
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            datetime.now(timezone.utc).isoformat(),
            ctx["commit_hash"],
            ctx["commit_short"],
            ctx["branch"],
            int(ctx["dirty"]),
            trigger_src,
            report["scenario"],
            report["filetype"],
            report["keystrokes"],
            int(report["lsp_attached"]),
            report["total_ms"],
            report["mean_ms"],
            report["median_ms"],
            report["p95_ms"],
            report["p99_ms"],
            report["max_ms"],
            report["stdev_ms"],
            report["nvim_version"],
            socket.gethostname(),
            json.dumps(report["latencies_ms"]),
        ),
    )
    conn.commit()


def pct_change(old, new):
    if old == 0:
        return 0.0
    return (new - old) / old


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--scenario", nargs="+", choices=SCENARIOS.keys(), default=list(SCENARIOS.keys()))
    parser.add_argument("--trigger", default="manual", choices=["manual", "pre-commit", "ci"])
    parser.add_argument("--db", type=Path, default=DEFAULT_DB)
    parser.add_argument(
        "--strict",
        action="store_true",
        help=f"exit non-zero if p95 regresses more than {int(REGRESSION_THRESHOLD * 100)}%% vs. the previous run",
    )
    args = parser.parse_args()

    nvim_bin = os.environ.get("NVIM_BIN") or shutil.which("nvim")
    if not nvim_bin:
        sys.stderr.write("✗ no nvim binary found (set NVIM_BIN, or run via `nix run .#bench-typing`)\n")
        sys.exit(1)
    if "NVIM_BIN" not in os.environ:
        sys.stderr.write(
            "⚠ NVIM_BIN not set — falling back to system nvim on PATH.\n"
            "  Results will not reflect the packaged timvim config unless run via\n"
            "  `nix run .#bench-typing`.\n"
        )

    args.db.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(args.db)
    conn.execute(SCHEMA)

    ctx = git_context()
    regressed = False

    print(f"→ commit {ctx['commit_short']} ({ctx['branch']}, {'dirty' if ctx['dirty'] else 'clean'})")

    for scenario in args.scenario:
        ext = SCENARIOS[scenario]
        prev = previous_row(conn, scenario)
        report = run_scenario(nvim_bin, scenario, ext)
        insert_row(conn, ctx, args.trigger, report)

        line = (
            f"  {scenario:<6} {report['keystrokes']} keys  "
            f"mean={report['mean_ms']:.2f}ms  median={report['median_ms']:.2f}ms  "
            f"p95={report['p95_ms']:.2f}ms  p99={report['p99_ms']:.2f}ms  max={report['max_ms']:.2f}ms"
        )
        if not report["lsp_attached"]:
            line += "  [no LSP attached]"
        print(line)

        if prev:
            prev_median, prev_p95 = prev
            d_median = pct_change(prev_median, report["median_ms"])
            d_p95 = pct_change(prev_p95, report["p95_ms"])
            arrow = "↑" if d_p95 > 0 else "↓"
            print(
                f"           vs previous: median {d_median:+.1%}, p95 {d_p95:+.1%} {arrow}"
            )
            if d_p95 > REGRESSION_THRESHOLD:
                regressed = True
                print(f"           ⚠ p95 regressed more than {REGRESSION_THRESHOLD:.0%}")

    conn.close()

    if regressed and args.strict:
        print("✗ typing-latency regression exceeds --strict threshold")
        sys.exit(1)


if __name__ == "__main__":
    main()
