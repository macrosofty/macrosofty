# Edition Pipeline — current shape and where we're going

**Status:** Vision sketch as of 2026-04-26. Captures the direction agreed in conversation, not the current implementation. The current pipeline still uses per-edition `build.sh` scripts; the config-driven model below is targeted for v0.2.

---

## The goal in one line

**Adding or modifying an edition should be a config change, not a code change.** Drop a config file, change a few values, get a new edition.

## Today's pipeline (v0.1 — script-based)

```
editions/<name>/
├── Containerfile            specifies FROM <base-image> + ARG/RUN scaffold
└── build.sh                 imperative shell: identity, packages, theme apply

scripts/
├── generate-os-release.sh   shared identity writer (called by every build.sh)
└── (host-side build helpers)

system_files/shared/
├── usr/bin/macrosofty-theme  the theme-pack apply script
└── usr/share/macrosofty/
    └── themes/default/       the default theme pack
```

Each edition's `Containerfile` differs in just the `FROM` line and the `EDITION` ARG. Each `build.sh` is ~95% identical to the others — install jq, strip plasma-welcome, copy system_files, apply theme — with only the edition-specific bits (Padkos's Firefox+LibreOffice RPMs, future Chunky-LJ's office set) varying.

That repetition is the smell. It's why every change today needs touching multiple build.sh files in lock-step.

## Where we're going (v0.2 — config-driven)

Replace per-edition imperative scripts with declarative configs:

```
editions/<name>/edition.toml      THE config — single source of truth
```

Example `edition.toml`:

```toml
name = "padkos"
display_name = "Padkos"
description = "Old hardware, new places."
ansi_color = "122;136;104"           # sage green; matches generate-os-release.sh
base_image = "ghcr.io/ublue-os/aurora:stable"
theme_pack = "default"

# RPMs to install on top of the base image
install_rpms = [
    "firefox",        # offline-first-boot per docs/app-curation.md §4.4
    "libreoffice",
    "jq",             # needed by macrosofty-theme
]

# Aurora-specific cruft to strip
remove_rpms = [
    "plasma-welcome",
]

# Flatpaks installed at first boot, on top of Aurora's defaults
firstboot_flatpaks = []                # Padkos ships fewer than other editions

# Identity hooks (optional)
hostname_default = "padkos"
```

A single root `Containerfile` reads the config:

```dockerfile
ARG EDITION
ARG BASE_IMAGE
FROM scratch AS ctx
COPY editions/${EDITION} /edition
COPY system_files /system_files
COPY scripts /scripts

FROM ${BASE_IMAGE}
ARG EDITION
ARG MACROSOFTY_VERSION=0.1.0-dev
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /scripts/edition-build.sh "$EDITION" "$MACROSOFTY_VERSION"
RUN bootc container lint
```

A single `scripts/edition-build.sh` (or Python equivalent) reads `edition.toml` and applies it: writes `/etc/os-release`, runs the right `dnf5` calls, drops the firstboot Flatpak Brewfile, applies the theme pack.

Build orchestration becomes:

```bash
scripts/build-edition.sh padkos       # reads padkos/edition.toml, builds
scripts/build-edition.sh chunky-lj    # same, for chunky-lj
```

GitHub Actions matrix becomes a list of edition names, not a list of Containerfiles.

## What this gets us

1. **One source of truth per edition.** The `edition.toml` says what the edition *is*; everything else is generic machinery.
2. **Adding an edition = drop a TOML.** No new Containerfile, no new build.sh. Just `editions/krummeltjie/edition.toml` with the right values, append `krummeltjie` to the matrix list.
3. **Easier review.** A diff that adds a package to Padkos is one line in TOML rather than a `dnf5 install` call buried in a 60-line shell script.
4. **External tooling becomes possible.** A future "Make it yours" UI could read every installed `edition.toml` and present "what's in this edition" without parsing shell.
5. **Symmetric with theme packs.** Both editions and theme packs end up declarative. Same shape, same review experience.

## What this doesn't get us

- **Anything fundamentally new.** The same builds happen, the same images come out. This is a refactor, not a feature. Don't expect smaller ISOs or new abilities — just less drift between editions.
- **Removal of edge cases.** Padkos's RPM-LibreOffice-for-offline-first-boot is special and stays special. The TOML accommodates it via `install_rpms`, but the *reason* it's special is still in the curation doc.

## Open questions for v0.2

- **TOML vs JSON vs YAML.** TOML reads better for human-edited config. JSON is friendlier to scripts. YAML is easy to write but easy to break. Default lean: TOML.
- **Where does theme-pack-per-edition live?** A pack name is in `edition.toml`. But what if Padkos and Chunky-LJ want the same pack with one tweak (e.g., a different ANSI accent)? Either we ship two packs, or `edition.toml` overrides specific pack components inline. Lean: ship more packs; keep override out unless we see the need.
- **Migration shape.** Refactor in one PR or one edition at a time? Lean: convert one edition (probably Hearty, simplest) as a proof, run side-by-side with the imperative ones, convert the rest once we're sure.

## What ships in v0.1 (today)

- `system_files/shared/usr/bin/macrosofty-theme` — the theme-pack apply script.
- `system_files/shared/usr/share/macrosofty/themes/default/` — the default pack with kickoff icon, wallpaper, login background, logo PNG, MOTD, GRUB distributor, Plymouth theme.
- Per-edition `build.sh` updated to install `jq`, strip `plasma-welcome`, and `macrosofty-theme apply default`.
- `docs/theme-packs.md` documenting the pack format.
- This file (`docs/edition-pipeline.md`) capturing the v0.2 direction.

The v0.2 refactor lands when we (a) have evidence the per-edition shell drift is causing real maintenance pain, or (b) need to add a 5th edition (e.g., `chunky-lj`). Whichever comes first.
