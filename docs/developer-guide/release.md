# Release Process

Releasing timvim is a light-touch process built on Conventional Commits, a
Keep-a-Changelog changelog, and a `docs` workflow that publishes the site and
attaches the handbook PDF to the GitHub Release automatically.

## Version bumps

Version numbers follow [Semantic Versioning](https://semver.org), and the size
of the bump is driven by the [Conventional Commits](https://www.conventionalcommits.org)
in the release:

| Change kind | Commit types | Bump |
| ----------- | ------------ | ---- |
| Bug fixes only | `fix:` | **Patch** (bugfix) |
| New functionality, backwards-compatible | `feat:` | **Minor** |
| Breaking change | any with `!` or a `BREAKING CHANGE:` footer | **Major** |

!!! info "Commit hygiene drives the version"
    Because the bump rule reads the commit types, well-formed Conventional
    Commit messages are what make the version decision unambiguous. Keep
    commits focused — one logical change each — and prefer many small PRs over
    one large one.

## The changelog

timvim maintains `CHANGELOG.md` in
[Keep a Changelog](https://keepachangelog.com) format. On every version bump:

1. Move the accumulated `Unreleased` entries into a new version section headed
   with the version and date.
2. Group entries under the standard headings — *Added*, *Changed*, *Fixed*,
   *Removed*, *Deprecated*, *Security* — matching the Conventional Commit
   types that went in.
3. Start a fresh, empty `Unreleased` section for ongoing work.

!!! tip "The changelog is the human-readable diff"
    A reader should be able to understand what changed between two versions
    from the changelog alone, without reading the git log. Write entries for
    people, not machines.

## Cutting the release

1. Ensure `main` is green: `nix flake check`, `nix build`, and the strict docs
   build (`nix run .#handbook-build`) all pass.
2. Bump the version and finalise the `CHANGELOG.md` section.
3. Merge to `main`.
4. Create a GitHub Release with the tag for the new version and a body
   summarising the highlights (the changelog section is a good source).

Publishing the release is what triggers the PDF attachment and site deploy.

## What the `docs` CI does

The `.github/workflows/docs.yml` workflow ties the documentation into the
release. It triggers on release publish, on pushes to `main` and PRs that
touch docs-related paths, and on manual dispatch.

### PDF on every push and PR

The **pdf** job runs `nix run .#handbook-pdf` on every trigger and uploads the
result as a short-lived artifact (7-day retention) named for the ref — so
reviewers can download and read a rendered copy of a PR's docs before merge.

### PDF attached to releases

When the trigger is a **published release**, the **release-pdf** job downloads
that artifact and attaches it to the release as a **permanent asset** with
`gh release upload … --clobber`. This job is the only one granted
`contents: write`, keeping the rest of the pipeline least-privilege.

!!! info "The handbook PDF is a release deliverable"
    Every published release carries a `timvim-handbook-<tag>.pdf` asset,
    generated from the exact docs at that tag. There is nothing to build or
    attach by hand.

### Site published to GitHub Pages

The **site** job runs `nix run .#handbook-build` (the strict build) and the
**deploy** job publishes `./site` to GitHub Pages. These run on release
publish, pushes to `main` and manual dispatch — but **not** on pull requests
(there is no Pages preview for PRs).

!!! warning "Pages must be set to Deploy from GitHub Actions"
    In the repository settings, GitHub Pages must be configured to **Deploy
    from GitHub Actions**. If it is set to the legacy branch-based deploy, the
    `deploy` job cannot publish and the site will not update.

## After the release

- Confirm the site updated at the published URL.
- Confirm the `timvim-handbook-<tag>.pdf` asset is attached to the release.
- Start the next `Unreleased` changelog section if you have not already.

---

Made with 💗 by [Kartoza](https://kartoza.com) &middot;
[Donate!](https://github.com/sponsors/timlinux) &middot;
[GitHub](https://github.com/timlinux/nix-vim)
