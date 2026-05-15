# Anaconda branding — installer chrome (vs target system)

Anaconda branding lives in two distinct places:

| Surface | Where it ships from | What you see |
|---|---|---|
| **Target system** (post-install) | OCI image — `system_files/shared/usr/share/anaconda/` | Fully Macrosofty: header, splash, sidebar, product.d config. Already wired in the OCI; arrives with a normal `bootc install`. |
| **Netinstall installer chrome** (the ISO you boot to install) | The boot ISO's `images/install.img` squashfs | Stock Fedora until we explicitly inject Macrosofty assets into `install.img`. |

The split exists because the netinstall ISO is built by injecting our kickstart into Fedora's stock `Fedora-Server-netinst-*.iso` (via `mkksiso`). `mkksiso` only embeds the kickstart — it never touches the installer rootfs. So the installer environment that runs Anaconda is upstream Fedora, with upstream `fedora-logos` baked in.

## Source of truth: `system_files/shared/usr/share/anaconda/`

We deliberately do **not** maintain a duplicate copy of the assets here. The canonical pixmaps + product.d config live alongside the OCI build inputs. `scripts/rebrand-netinstall-iso.sh` reads from there and overlays them into `install.img` during the netinstall build.

What gets overlaid:

- `usr/share/anaconda/pixmaps/anaconda_header.png` (800×88 Tjopper banner)
- `usr/share/anaconda/pixmaps/anaconda_splash.png` (1920×1080)
- `usr/share/anaconda/pixmaps/sidebar-bg.png` (1920×1080)
- `usr/share/anaconda/pixmaps/sidebar-logo.png` (150×69 Macrosofty doorway — replaces the upstream "fedora" wordmark in the sidebar)
- `usr/share/anaconda/product.d/macrosofty.conf` (Anaconda product config)
- `etc/os-release` and `usr/lib/os-release` (regenerated from `config/identity.env`)
- `/.buildstamp` (the **actual** source of the "MACROSOFTY 43 INSTALLATION" title — `pyanaconda/core/product.py` reads `[Main] Product` + `Version` from this file, not os-release)

## Why a separate rebrand step at all

Three options were considered:

1. **Custom Lorax templates.** Most "official" path, but heavy: lorax templates expect a full Fedora rebuild pipeline. We're shipping atomic; we don't run lorax to build the installer rootfs ourselves.
2. **A `macrosofty-logos` RPM that replaces `fedora-logos` inside install.img.** Cleanest long-term but requires building and maintaining an RPM. Future work.
3. **Surgical squashfs overlay (this approach).** Extract `install.img`, swap the assets, repack. Cheap, no upstream-package fight, and the same canonical files we already maintain for the target system. Trade-off: ~5 min of CI time per edition for the unsquashfs/mksquashfs round-trip.

We picked (3) for now. (2) is the right v0.3 cleanup once the rebrand surface stabilises.
