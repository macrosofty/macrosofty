# scripts/

Reusable scripts for Macrosofty image builds and supporting automation. Anything that needs to be called more than once — at build time, in CI, by hand — lives here. One file per concern.

Two flavours, distinguished by where they run:

- **Build-time scripts** run *inside* the image during `podman build` / `buildah bud`. They have full root access to the image rootfs and are mounted into each edition's build via the ctx stage at `/ctx/scripts/`. Each edition's `build.sh` calls them by absolute path: `/ctx/scripts/<name>.sh`.
- **Host-time scripts** (under `scripts/local/`) run on the user's machine — pulling images, smoke-testing, verifying signatures. None exist yet; convention placeholder.

## Build-time scripts

| Script | Called by | What it does |
|---|---|---|
| `generate-os-release.sh` | each edition's `build.sh` | Writes `/usr/lib/os-release`, the `/etc/os-release` symlink, and `/etc/issue{,.net}` so the running system identifies as `Macrosofty <Edition>` instead of inheriting Aurora's identity. Per-edition pretty name and ANSI accent colour live in a `case` statement inside this script — adding a fifth edition is one row. |

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
