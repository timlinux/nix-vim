# Building & Testing

Every change to timvim goes through the same handful of Nix commands that CI
runs. Learning what each one verifies lets you catch problems before you push.

## The core commands

| Command | What it does |
| ------- | ------------ |
| `nix build` | Evaluates the config and builds the wrapped Neovim package. |
| `nix run` | Builds (if needed) and launches timvim. |
| `nix flake check` | Runs the quality gates: `format-check`, `deadnix`, `statix`. |
| `nix fmt` | Formats all Nix files with `nixfmt-rfc-style`. |

## `nix build` — does it compile?

```bash
nix build
```

This produces `packages.default` — the `wrappedNeovim` derivation. It proves
that the whole `config/` tree evaluates, that NVF accepts every option you set,
that any flake-input plugins build, and that the runtime-dependency wrapper is
assembled correctly. The result is symlinked to `./result`.

!!! tip "Build early, build often"
    Most mistakes — a typo'd option name, an un-imported file, a missing
    runtime dependency — surface as a `nix build` failure with a precise
    error. Run it after every meaningful edit rather than waiting until the
    end.

## `nix run` — does it actually work?

```bash
nix run
```

Building proves the editor *assembles*; running proves it *behaves*. Launch
timvim and exercise whatever you changed — open the dashboard, trigger the new
plugin, test the keybinding, confirm the which-key entry appears. A change is
not done until it has been run.

## `nix flake check` — the quality gates

```bash
nix flake check
```

This runs the three checks defined in `flake.nix`. They are the same checks CI
enforces on every pull request, so a green run here means a green run in the
pipeline.

### `format-check`

Copies the tree, runs `nixfmt-rfc-style` over every `.nix` file, and diffs the
result against the original. Any formatting drift fails the check. Fix it with
`nix fmt` (below).

### `deadnix`

Runs `deadnix check .` to find dead or unused Nix code — unreferenced
bindings, unused function arguments and the like. Dead code fails the check;
remove it.

### `statix`

Runs `statix check .` to flag Nix style issues and anti-patterns and suggest
idiomatic rewrites. Style violations fail the check.

!!! info "Run everything, or one at a time"
    `nix flake check` runs all three. To iterate on a single gate you can run
    its tool directly inside `nix develop`: `nixfmt <file>`, `deadnix check .`
    or `statix check .`.

## `nix fmt` — format your changes

```bash
nix fmt
```

Formats every Nix file in the tree with `nixfmt-rfc-style`, the project's
canonical formatter (also exposed as the flake `formatter`). Always run this
before committing so `format-check` passes.

## What CI runs

Two workflows guard the build (both use Cachix for caching):

- **`ci.yml`** on every pull request: verifies there are no uncommitted
  changes (`git diff --exit-code`), runs `nix flake check --all-systems`,
  builds the default package, and smoke-tests the dev shell.
- **`build-and-cache.yml`** on push to `main`: re-runs the checks, builds the
  package, and pushes the closure to Cachix so contributors and users get
  fast binary downloads.

!!! warning "Commit your lockfile and formatting"
    CI runs `git diff --exit-code` and fails on any uncommitted change. If you
    updated `flake.lock` or forgot to run `nix fmt`, the diff check will
    catch it. Lockfile updates belong in their own commit/PR.

## A tidy pre-push routine

```bash
nix fmt          # format
nix flake check  # gate: format-check, deadnix, statix
nix build        # compile
nix run          # verify behaviour
```

If all four pass, your change is ready to commit.
