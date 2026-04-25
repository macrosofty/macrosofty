# Session Notes — 2026-04-25

## Summary

Macrosofty went from "scaffolded code, no CI green, no images, work-email leaks" to **a verified, signed, branded Linux distro with three downloadable bootable ISOs and a Padkos VM install confirmed working on x86-64 QEMU**. 18 commits on `main`, four edition images on GHCR, brand identity wired top-to-bottom, public/private repo split clean, history scrubbed to a single project email.

## Changes Made

### Build pipeline
- Fixed overnight CI failure: `ublue-os/remove-unwanted-software@main` → `@v9` (that repo's default branch is `master`, not `main` — every prior run died at "Set up job" before any work).
- Fixed Containerfile bind-mount path mismatch (`/ctx/ctx/edition/build.sh` doubled path → exit 127). All four Containerfiles now COPY into root-level paths matching Aurora's canonical pattern.
- Completed Padkos Containerfile body — Aurora-stripped: removes Akonadi/PIM, Krita, Kdenlive, digiKam.
- Re-added `padkos` to the GHA matrix.
- Result: **all four editions building, signing, pushing to GHCR. cosign keyless verification confirmed live for Padkos.**

### Identity layer
- New `scripts/generate-os-release.sh` writes `/usr/lib/os-release`, `/etc/os-release` symlink, `/etc/issue`. Per-edition pretty name + ANSI colour in a single case statement.
- Initially used `ID=macrosofty` for purity — broke `bootc-image-builder`'s osbuild distro lookup (`could not find def file for distro macrosofty-0.1.0-dev`). Pivoted to `ID=fedora` + `VERSION_ID=43` on the build-tool channel; kept Macrosofty in `NAME`, `PRETTY_NAME`, `VARIANT`, `VARIANT_ID`, `LOGO`, ANSI accent, all URLs.
- Late tweak: included edition in `NAME` (e.g. `NAME="Macrosofty Padkos"`) so installer/boot-menu reads "Macrosofty Padkos 43" instead of just "Macrosofty 43". Added `/etc/system-release` for the same reason.

### Logo
- Hand-crafted `branding/logo-master.svg` — single-path saffron door-arch silhouette with rounded leg-ends. Distilled from a Cloudflare Workers AI Flux generation (iter01-v3). Raw AI ref preserved at `branding/logo-master-raw.png`; iteration history in `branding/iterations/`.
- New `scripts/generate-logos.sh` (host-time) renders 11 hicolor sizes (16-512), scalable SVG, pixmaps fallback into `system_files/shared/usr/share/...`. Idempotent, re-runnable on master change.
- New `scripts/generate-logo-options.sh` captures the Cloudflare Workers AI Flux prompt loop. Reads prompts on stdin, writes one PNG per prompt. Future logo work is one command.
- Each edition's `build.sh` runs `gtk-update-icon-cache` after the shared overlay copy so the new icon is visible without rebuild tricks.
- v0.1 ships the saffron master in all four editions. Per-edition colour variants documented in the script header as v0.2 work.

### Editions renamed
- **Broth → Padkos** ("Old hardware, new places. / Not getting left behind.") — 24 files updated via `git mv` + sed, emoji 🥣→🧺.
- **Feast → Braai** — same pattern, emoji 🍷→🔥. Pairs with the existing "lekker at a braai" tagline; signals gathering, not competitive grind.
- Done now (rather than after v0.1) because we had zero published images and zero users — rename was free.

### Public / private repo split
- Created **private** `macrosofty/macrosofty-website` repo. Copied `website/` source + history-fresh init. All future website work lives there.
- Removed `website/` from the public distro repo.
- Brand visuals (Gemini-generated `logo-rich.png` and `illustration-doorway.png`) placed in the private website repo's `public/brand/`.
- Wired into Hero (right-side mark = `logo-rich.png`), Backstory (`illustration-doorway.png` as section opener with -2deg rotation), and BaseLayout (OG image + Twitter card meta).
- Updated launcher `/mnt/code/scripts/server-macrosofty.sh` to point at the new website repo location.

### Email scrub + history rewrite
- Found work email (`elje.vandeventer@oks.co.za`) had leaked into the private website repo's first commit. Force-pushed an amend to use `eljevd@gmail.com`.
- Public distro repo: `git filter-branch` rewrote all 9 prior commits' author/committer emails to `eljevd@gmail.com`. Force-pushed `main`. GitHub now correctly attributes commits to `eljevd`.
- Memory updated with a hard rule: never use the work address anywhere; pass `-c user.email=eljevd@gmail.com -c user.name=Elje` explicitly on every commit going forward.

### GitHub repo polish
- 11 topics applied to the public repo via API (linux, fedora, kde, plasma, atomic, immutable, ublue, universal-blue, bootc, distro, macrosofty).
- README rewritten to invite, not just inventory files. Editions table corrected from stale Bluefin claim to Aurora-based.
- Hearty package on GHCR was 403'ing pushes due to an orphaned-permissions glitch (created in a context not linked to the repo). Deleted via UI; fresh push linked it correctly.

### ISO build pipeline
- Created `.github/workflows/iso.yml` — first version used `quay.io/centos-bootc/bootc-image-builder` directly. Auto-triggers on `workflow_run: build.yml succeeded`; also dispatchable.
- Three iterations to green for Aurora-based editions: redundant rootless `podman login` failure → fixed; `ID=macrosofty/VERSION_ID=0.1.0-dev` distro-def lookup failure → fixed via the identity-layer pivot.
- **Result on commit `deadf14`**: Hearty (4.6 GB), Chunky (6.2 GB), Padkos (4.6 GB) ISOs built and uploaded as GHA artefacts at run `24935840904`. **First downloadable Macrosofty.**
- Braai failed at terra-mesa GPG key path (Bazzite ships a `terra-mesa.repo` with `gpgkey=file:///...` that doesn't exist; bootc-image-builder reads every `.repo` during depsolve regardless of `enabled=`).
- Switched the workflow wholesale to `jasonn3/build-container-installer@v1.4.0` — the same lorax+osbuild wrapper Bazzite/Aurora/Bluefin use. Accepts a `repos:` whitelist that bypasses the broken terra-mesa repo file.
- Added private-GHCR auth via `image_src: containers-storage:...` after pre-pulling — bypasses skopeo's registry auth path entirely.
- Braai ISO build via the new pipeline running at session end.

### Operational helpers
- `scripts/local/verify-images.sh` — pulls each edition + verifies cosign keyless signature in one shot. Defaults to all four editions and `:latest`; accepts edition-name args, `--tag=...`, `--no-pull`.

### Padkos VM validation (real-world)
- User booted Padkos in QEMU on plain x86_64. Anaconda installer ran, OS installed, KDE Plasma loaded. Confirms the "x86-64 baseline (not v3)" decision and validates the entire pipeline end-to-end.
- Identified over-stripping: removed LibreOffice was wrong for the audience. Padkos v0.1.1 (commit `11d15b8`) restores LibreOffice and pre-installs Firefox as RPM (more robust than depending on Aurora's firstboot Flatpak install).

### Padkos ISO downloaded for testing
- `/home/elje/macrosofty-iso/macrosofty-padkos-20260425.iso` (4.6 GB).

## Files Changed

### Distro repo (`/var/mnt/code/macrosofty/`)
- `editions/{hearty,chunky,padkos,braai}/Containerfile` and `build.sh` — paths fixed, identity step added, gtk-update-icon-cache wired, Padkos strip refined
- `scripts/generate-os-release.sh`, `scripts/generate-logos.sh`, `scripts/generate-logo-options.sh`, `scripts/local/verify-images.sh`, `scripts/README.md` (new)
- `branding/logo-master.svg`, `branding/logo-master-raw.png`, `branding/iterations/iter01-v[2,3].png`, `branding/iterations/iter02-v[1,3,4].png` (new)
- `system_files/shared/usr/share/icons/hicolor/{...}x{...}/apps/macrosofty.png` (11 sizes), `scalable/apps/macrosofty.svg`, `pixmaps/macrosofty.png`, `macrosofty/logo.svg` (new — generated)
- `.github/workflows/iso.yml` (new), `.github/workflows/build.yml` (matrix re-add, action pin)
- `CLAUDE.md`, `VISION.md`, `README.md` (rewritten / Aurora-arch demote / Bluefin → Aurora correction)
- `website/` directory removed wholesale (moved to private repo)

### Website repo (`/var/mnt/code/macrosofty-website/`)
- Initial extraction with all 27 source files
- `public/brand/logo-rich.png`, `public/brand/illustration-doorway.png` (new)
- `src/components/Hero.astro`, `src/components/Backstory.astro`, `src/layouts/BaseLayout.astro` (brand visuals wired)

### Out-of-repo
- `/mnt/code/scripts/server-macrosofty.sh` — updated to point at new website repo path

## Technical Decisions

- **`ID=fedora` + `VERSION_ID=43` in os-release** despite being a Macrosofty derivative. Reason: bootc-image-builder/osbuild + jasonn3 both look up `<ID>-<VERSION_ID>` against a known distro-def list to drive the manifest build. Aurora and Bazzite get away with their own `ID=` because their distros are upstream in osbuild; Macrosofty isn't yet. Identity shines through every user-visible field (NAME, PRETTY_NAME, VARIANT, LOGO, URLs). v0.2 work: submit a `macrosofty` distro def upstream or ship our own via `--datadir`.
- **`jasonn3/build-container-installer@v1.4.0` over `bootc-image-builder` direct** for ISOs. Required because bootc-image-builder eagerly validates every `.repo` file in the source image's depsolve, including disabled ones with broken `gpgkey=` paths (terra-mesa is the canary here). jasonn3 accepts a `repos:` whitelist; this is the canonical UBlue ISO pipeline.
- **`image_src: containers-storage:...`** to feed jasonn3 a pre-pulled local copy. Bypasses skopeo's registry-auth path while our packages remain private.
- **Public distro / private brand repo split.** Distro is Apache 2.0 in the open; brand visuals, marketing voice implementation, and the Astro source are property and live under `macrosofty/macrosofty-website` (private). Decision driven by founder's "the website is property" framing.
- **Force-pushed history rewrite** on the public repo to consolidate to a single project email (`eljevd@gmail.com`). Acceptable because: zero stars, zero forks, single maintainer, and the rewrite was explicitly requested. Memory carries the rule going forward.
- **Padkos un-strip of LibreOffice** after VM testing. The "Flathub is one click away" rationale assumed the user has internet and knows about Discover — the exact assumptions Padkos is supposed to break for the old-laptop audience.
- **Firefox as RPM in Padkos**, diverging from Aurora's Flatpak default. Reason: needs to be present at first boot even without internet for the "internet computer" promise to hold.

## Known Issues / Follow-up

- **GHCR packages still private.** Org-level "Allow public packages" toggle is UI-only at https://github.com/organizations/macrosofty/settings/packages → flip Public, then per-package flip each of the four. Required before non-authenticated users can `podman pull` or download ISOs without a PAT.
- **Braai ISO** — running on the new jasonn3 pipeline at session end (run `24938408252`); result not seen before wrap.
- **Anaconda installer chrome is still Fedora's default art**, not Macrosofty-branded. Customisable via Lorax templates passed to jasonn3 via `additional_templates:`. v0.1.x.
- **Aurora's firstboot Flatpak service** may not have fired correctly on Padkos VM install — investigate. Symptom was "no browser" before our Firefox-RPM workaround.
- **Cosign verify-blob for ISOs** — `iso.yml` doesn't currently sign the produced ISOs. Worth adding a cosign step that signs the artefact and lets users verify provenance with `scripts/local/verify-iso.sh` (parallel to `verify-images.sh`).
- **Per-edition logo colour variants** — generator script header documents the path. v0.2.
- **Plymouth / SDDM / GRUB themes** — unblocked now that we have a logo. Half-day each.
- **`macrosofty.org` registration** + Cloudflare Pages connect for the private website repo. Devops Claude project handling via Cloudflare API when given the go.
- **CLAUDE.md "Current state" section is stale** (says "no remote yet, no push") — memory holds the truth, but a cleanup pass on CLAUDE.md is overdue.
