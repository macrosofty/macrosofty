# scripts/

Reusable scripts for Macrosofty image builds and supporting automation. Anything that needs to be called more than once — at build time, in CI, by hand — lives here. One file per concern.

Two flavours, distinguished by where they run:

- **Build-time scripts** run *inside* the image during `podman build` / `buildah bud`. They have full root access to the image rootfs and are mounted into each edition's build via the ctx stage at `/ctx/scripts/`. Each edition's `build.sh` calls them by absolute path: `/ctx/scripts/<name>.sh`.
- **Host-time scripts** run on the user's machine. Some (the logo generators) live alongside the build-time scripts because they emit committed assets; truly host-only operational helpers live under `scripts/local/`.

## Build-time scripts

| Script | Called by | What it does |
|---|---|---|
| `generate-os-release.sh` | each edition's `build.sh` | Writes `/usr/lib/os-release`, the `/etc/os-release` symlink, and `/etc/issue{,.net}` so the running system identifies as `Macrosofty <Edition>` instead of inheriting Aurora's identity. Per-edition pretty name and ANSI accent colour live in a `case` statement inside this script — adding a fifth edition is one row. |

## Host-time scripts

| Script | Run by hand from | What it does |
|---|---|---|
| `generate-logos.sh` | repo root, after editing `branding/logo-master.svg` | Renders the master SVG into `system_files/shared/usr/share/icons/hicolor/<size>x<size>/apps/macrosofty.png` for every standard hicolor size, plus the scalable SVG and a pixmaps fallback. The output tree is committed; each edition's `build.sh` overlays it into the image and refreshes the icon-theme cache. Idempotent — re-run any time the master SVG changes. |
| `generate-logo-options.sh` | repo root, when iterating on the logo design | Generates N logo candidates via Cloudflare Workers AI (Flux schnell). Reads prompts on stdin, one per line, writes `v1.png` … `vN.png` to the given out-dir. The script that produced the iter01-v3 master mark — kept so future logo work (Bokkie, wordmark, post-v1 reskin) is one command. Needs `~/.config/macrosofty/cf-token` with `account_id=` and `token=`. |

## Operational helpers (`scripts/local/`)

| Script | What it does |
|---|---|
| `local/verify-images.sh` | Pull each edition image from `ghcr.io/macrosofty/<edition>:<tag>` and verify its cosign keyless signature in one shot. Defaults to all four editions and `:latest`; accepts edition names + `--tag=...` + `--no-pull` (skip pull, verify already-pulled images). Exit 0 = everything verified; exit 1 = at least one failure. Prints the manifest digest and originating commit for each pass. Use after a release, when troubleshooting GHCR auth, or to confirm a registry artefact really came from our workflow. |

## Org tooling

| Script | What it does |
|---|---|
| `new-project.sh` | Scaffold a new Macrosofty satellite project (apps, helpers, applets, libraries — anything that orbits the OS but isn't part of the ISO build). Renders `templates/*.tmpl` into `/var/mnt/code/<slug>/` with voice-inheriting `CLAUDE.md`, README/ROADMAP/NEXT_SESSION/CONTRIBUTING stubs, Apache-2.0 LICENSE, `.gitignore`, kickoff `SESSION_NOTES`. Initialises git + first commit, then creates a **private** repo at `github.com/macrosofty/<slug>` and pushes. Prefers `gh` if installed and authenticated; otherwise falls back to the GitHub REST API via curl using `$GITHUB_TOKEN` from `~/.config/macrosofty/load-tokens.sh`. Usage: `scripts/new-project.sh <slug> "<Title>" "<one-line description>"`. Flags: `--public` (override default-private), `--no-remote` (skip GitHub repo creation entirely), `--parent <dir>` (default `/var/mnt/code`). |

The `templates/` folder holds the `*.tmpl` files used by `new-project.sh`. Edit those when the house style for satellite projects changes — every new project picks up the change on next scaffold. Existing scaffolded projects are not retroactively updated; that's intentional (each project owns its own copy after generation).

## Conventions

- Bash. `set -euo pipefail` at the top. Idempotent where reasonable — re-running a script should not break the image.
- First arg is the edition name (`hearty`, `chunky`, `padkos`, `braai`, `bokkie`). Reject unknown editions explicitly; never default-write the wrong identity.
- Echo a one-line confirmation on success so the build log makes it clear what happened.
- Avoid pulling network during build steps that are supposed to be offline (the second `RUN` block in each Containerfile uses `--network=none`).

## Adding a new build-time script

1. Drop `scripts/<name>.sh` here. `chmod +x`.
2. Reference it from `editions/*/build.sh` as `/ctx/scripts/<name>.sh "$EDITION"`.
3. Add a row to the table above.

The `COPY scripts /scripts` line in each Containerfile already exposes the whole directory under the ctx mount — no Containerfile edit needed for new scripts.
