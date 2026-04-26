# Theme Packs

**Status:** v0.1 — single default pack. Format may evolve as we learn.

A **theme pack** is a directory containing the visual-identity assets for a Macrosofty edition: kickoff icon, wallpaper, login background, MOTD, GRUB distributor, Plymouth boot splash, SDDM theme bits, KDE Look-and-Feel package contents. One pack covers the entire visual experience; the `macrosofty-theme` script applies it in one go.

Packs are the foundation for the upcoming "Make it yours" UI (per CLAUDE.md, v0.3) — switching pack at runtime is one `macrosofty-theme apply <pack>` call.

## Pack layout

```
/usr/share/macrosofty/themes/<pack-name>/
├── pack.json                  metadata + which file is which component
├── icons/
│   ├── start-here-kde.svg     kickoff (application launcher) icon — REQUIRED if "kickoffIcon" in pack.json
│   ├── start-here.svg         legacy fallback name
│   └── start-here-symbolic.svg monochrome fallback (16×16 stroked)
├── wallpaper-1920x1080.png    desktop wallpaper, baseline 1920×1080
├── login-bg.png               SDDM/login background (often the same as wallpaper)
├── logo-256.png               raster logo at 256×256, used by Plymouth and other places needing a real PNG
├── motd                       /etc/motd content
├── plymouth/
│   ├── macrosofty.plymouth    theme metadata
│   ├── macrosofty.script      Plymouth animation script
│   └── logo.png               logo image referenced by the script
└── lookandfeel/               (optional) KDE Look-and-Feel package contents
    ├── metadata.json
    └── contents/
```

## `pack.json` schema

```json
{
  "name": "default",
  "displayName": "Macrosofty Default",
  "description": "The saffron-arch theme.",
  "version": "0.1.0",
  "author": "Macrosofty",
  "license": "Apache-2.0",
  "components": {
    "kickoffIcon":     "icons/start-here-kde.svg",
    "wallpaper":       "wallpaper-1920x1080.png",
    "loginBackground": "login-bg.png",
    "logo":            "logo-256.png",
    "motd":            "motd",
    "grubDistributor": "Macrosofty",
    "plymouthTheme":   "plymouth/",
    "sddmBackground":  "login-bg.png",
    "lookAndFeel":     "lookandfeel/"
  }
}
```

Every component is **optional**. A pack can be partial — only the components present in `pack.json` get applied. This means a future pack could just swap the wallpaper without touching anything else.

## How `macrosofty-theme apply` works

```bash
sudo macrosofty-theme apply default      # apply the default pack
macrosofty-theme list                     # list installed packs
macrosofty-theme current                  # show currently applied pack
```

Apply walks the components in `pack.json`:

| Component | Destination | Notes |
|---|---|---|
| `kickoffIcon` | `/usr/share/icons/hicolor/scalable/places/start-here{-kde,-symbolic,}.svg` | Plus `gtk-update-icon-cache` |
| `wallpaper` | `/usr/share/wallpapers/Macrosofty/contents/images/1920x1080.png` | Plus generated `metadata.json` |
| `motd` | `/etc/motd` | Single-file copy |
| `grubDistributor` | `/etc/default/grub.d/99-macrosofty.cfg` | Sets `GRUB_DISTRIBUTOR="..."`; takes effect on next `grub2-mkconfig` |
| `sddmBackground` | `/usr/share/sddm/themes/breeze/Background.png` (overlay) | Plus `/etc/sddm.conf.d/00-macrosofty.conf` selecting `Current=breeze` |
| `plymouthTheme` | `/usr/share/plymouth/themes/macrosofty/` | Plus `plymouth-set-default-theme macrosofty`. Initramfs regen happens at the next normal `dracut` run (or at install-time, for a fresh install). |
| `lookAndFeel` | `/usr/share/plasma/look-and-feel/com.macrosofty.desktop/` | Available to users; setting it as default per-user requires a separate Plasma config write (not yet wired). |

State (the currently-applied pack name) lives in `/var/lib/macrosofty/theme-current`.

## How packs get into the image

At image-build time, each edition's `build.sh` does:

```bash
dnf5 install -y jq
cp -r /ctx/system_files/shared/. /
macrosofty-theme apply default
```

That copies the pack into `/usr/share/macrosofty/themes/default/`, copies the apply script to `/usr/bin/macrosofty-theme`, and runs the apply at build time so the assets are pre-placed when the user first boots.

After install, the user can re-apply a different pack with `sudo macrosofty-theme apply <pack-name>`.

## Authoring a new pack

1. Create `system_files/shared/usr/share/macrosofty/themes/<name>/`.
2. Drop the assets you want to ship — only the ones you need; everything is optional. Pre-rasterise PNGs from SVGs locally (we have `magick` on dev boxes) so the build container doesn't need conversion tools.
3. Write a `pack.json` with `components.*` pointing to the files you shipped.
4. To make the pack available in editions, just commit it under `system_files/shared/...` — every edition's build pipeline copies the whole `system_files/shared` tree, so all packs ship in all images.
5. To make a pack the *default* applied at build time, change the `macrosofty-theme apply <name>` line in the relevant `build.sh`.

## What's missing in v0.1

- **Per-user wallpaper / look-and-feel application.** Currently we drop the assets and set system-wide defaults where possible (SDDM, GRUB, Plymouth). The KDE desktop wallpaper for a *new user account* doesn't auto-set yet — the user will need to pick "Macrosofty" in Settings → Wallpapers. Wiring this needs a `/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc` template, which is fragile to hand-author. Targeted for a later iteration.
- **Theme-pack discovery.** No GUI yet to browse packs. `macrosofty-theme list` is the CLI. The "Make it yours" panel (v0.3) will be the GUI.
- **Pack signing / validation.** Nothing checks that a pack's `pack.json` matches its files, or that a third-party pack hasn't tampered with anything. v0.2+ if community packs become a thing.
