# Macrosofty Netinstall ISOs

**Status:** v0.1 of the netinstall. Functional but minimally branded — uses stock Fedora Anaconda theming with our payload wired in. Macrosofty boot-menu and Anaconda theme are v0.2 work.

## What this directory produces

For each of the four editions (Hearty, Chunky, Padkos, Braai), CI produces a `macrosofty-<edition>-netinstall-amd64.iso` of approximately 700 MB. The ISO pulls the actual OS (~3.7 GiB) from `ghcr.io/macrosofty/<edition>:latest` at install time over the user's wifi.

## How it's built

```
[Fedora 43 netinstall ISO]                  ← stock Fedora boot.iso (~700 MB)
              +
[editions/netinstall/kickstart.in]          ← our kickstart, edition substituted
              ↓
[mkksiso embeds the kickstart into the ISO] ← lorax tool, runs in CI
              ↓
[macrosofty-<edition>-netinstall.iso]
```

`mkksiso` injects the kickstart so that when the ISO boots, Anaconda finds it automatically and uses it as the install plan. Anaconda screens not pre-answered by the kickstart (network setup, partitioning, user creation, root password) get presented graphically to the user.

## How it installs

End-to-end user flow:

1. Download the netinstall ISO (~700 MB) from the website.
2. Boot it (USB stick or VM).
3. Connect to wifi via Anaconda's network screen.
4. Pick disk and partitioning.
5. Create a user account.
6. Anaconda runs `bootc install to-disk` against the chosen edition's OCI image — this is the slow step (~3.7 GiB pull from GHCR).
7. Reboot into the freshly installed Macrosofty.

Total bytes downloaded ≈ same as the full ISO. The win is **lower commitment** — the user pays 700 MB to find out if the boot experience works for them, only spending the remaining 3.7 GiB once they've committed to install.

## Why one ISO per edition (and not a single picker ISO)

A single ISO with an in-installer "pick your edition" screen would require either a custom Anaconda spoke or a custom pre-Anaconda menu, both of which are real engineering effort. For v0.1 we keep it simple: the website's download wizard already picks an edition, so the user downloads the right netinstall ISO directly. One picker, two places it lives — the website wizard for guidance, the ISO for the install itself.

If we ship Bokkie or other variants later, this scales linearly: one more ISO target, one more kickstart, no UI work.

## What's stock Fedora vs Macrosofty

For now: **the boot menu, Anaconda look-and-feel, and progress screens are stock Fedora 43.** Only the payload (the OS that lands on disk after install) is Macrosofty. Once installed, the user gets full Macrosofty branding via the theme pack (`/usr/share/macrosofty/themes/default/`, applied at image-build time per `docs/theme-packs.md`). The installer itself looking like Fedora for ~10 minutes is the v0.1 trade-off.

v0.2 plan: replace the boot menu logo + add a custom Anaconda product brand (a single PNG drop) so the install experience also feels like Macrosofty.

## Why `--no-signature-verification`

Our OCI images are cosign-signed (keyless via GitHub OIDC), but Anaconda's bootc payload doesn't yet read those signatures cleanly. Running with verification disabled for now; the integrity story is "you trust GHCR + the registry transport over TLS." Wiring up signature verification end-to-end is v0.2 hardening work alongside the netinstall polish.

## Caveats

- **Network required at install time.** No wifi = the netinstall doesn't work. For offline installs, use the full ISO (which carries the OS on disk).
- **Padkos's offline-first-boot promise applies only to the full ISO.** The netinstall flavour assumes wifi at install, so an offline rescued laptop should use the Full Padkos ISO.
- **One ISO doesn't fit all hardware.** The Fedora netinstall base supports x86_64 only at v0.1. ARM (Bokkie) and other arches are upstream-blocked.
