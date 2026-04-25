# App Curation per Edition

**Living document.** Updated as opinions evolve and real usage reveals what's missing or excessive.

## Principles

1. **Flatpak first** for user-facing apps. Layered RPMs only when Flatpak isn't viable (e.g., things that need host integration — Syncthing as a service, system-level tooling).
2. **Remove what's not needed** from the upstream base. Shipping cruft is worse than missing something.
3. **Every app earns its place.** If we couldn't write one sentence defending why it's in the default set, it goes.
4. **Never assume a user wants an account-based app.** Microsoft 365 Teams, Google Drive client, anything requiring a specific identity — not default. Firefox is the exception; users expect a browser.
5. **No duplicates.** If Hearty ships OnlyOffice, it doesn't also ship LibreOffice. Pick one.

## Flatpak remote

- **Flathub (filtered)** — unfiltered Flathub is too noisy for non-technical users. Fedora's filtered Flathub remote is enabled by default. Users can switch to unfiltered in Settings.
- No snaps. No AUR bridges. No `pip install` system-wide.

---

## 🍲 Hearty — Home edition

**Base:** Bluefin (KDE variant when available, else Bluefin-DX + KDE swap)

### Keep from upstream
- Firefox (Flatpak)
- KDE core apps: Dolphin (files), Okular (PDF), Gwenview (images), Spectacle (screenshots), Ark (archives), KCalc, KSystemLog
- NetworkManager, Bluetooth stack, printing (CUPS + drivers)
- Standard codecs (via Fedora's multimedia group)

### Add
- **OnlyOffice Desktop Editors** (Flatpak) — best-in-class MS Office compatibility, no account required
- **VLC** (Flatpak) — plays everything
- **Signal Desktop** (Flatpak) — secure messaging, increasingly mainstream
- **Zoom** (Flatpak) — unavoidable for most users, unfortunately
- **Discord** (Flatpak) — common user request
- **Spotify** (Flatpak) — common user request; users still need an account but it's their choice
- **Bitwarden** (Flatpak) — password manager, works offline-first
- **Thunderbird** (Flatpak) — email/calendar client for the MS Outlook refugees
- **Joplin** (Flatpak) — notes app, no account required

### Remove from upstream
- Any Bluefin-DX developer tooling (VS Code, toolbox UI, etc.) — those live in Chunky
- Tutorials/onboarding screens specific to Bluefin's identity — replaced with ours
- Any apps requiring a first-launch account creation

### Welcome app prompts
After firstboot, offer (checkbox, all off):
- Slack, Teams (web wrapper), Telegram, GIMP, Kdenlive, Darktable, Audacity, OBS Studio

---

## 🍖 Chunky — Productivity edition

**Base:** Bluefin-DX (with KDE) — inherits Hearty's set plus developer tooling.

### Keep everything from Hearty

Plus:

### Add (productivity tooling)
- **LibreOffice** (Flatpak) — full suite, complements OnlyOffice for when you need complex macros
- **GIMP** (Flatpak) — image editing
- **Inkscape** (Flatpak) — vector graphics
- **Darktable** (Flatpak) — RAW photo processing (aimed at DSLR owners)
- **Kdenlive** (Flatpak) — light video editing
- **OBS Studio** (Flatpak) — screen recording, streaming
- **Audacity** (Flatpak) — audio editing
- **Krita** (Flatpak) — digital painting

### Add (developer tooling — layered RPMs where sensible)
- **VS Code** (Flatpak, or RPM for devs who need direct container/host access)
- **Distrobox** (layered RPM) — run Arch/Debian/Ubuntu containers for apps
- **Toolbox** (layered RPM) — Fedora's official dev containers
- **podman-compose** (layered RPM) — ships with Bluefin-DX already
- **git**, **gh** (GitHub CLI), **curl**, **jq**, **htop**, **ripgrep**, **fd**, **bat**, **eza** — all via rpm-ostree, if not already in upstream

### Remove
- Nothing from Hearty — Chunky is a superset.
- Any Bluefin-DX apps that assume a specific workflow we don't want to impose (e.g., certain default Dock pinnings).

### Welcome app prompts
Add to Hearty's list:
- Docker Desktop alternative (Podman Desktop), Postman, DBeaver, specific language SDKs

---

## 🧺 Padkos — Light edition

**Base:** Minimal Fedora atomic (not Bluefin). KDE Plasma with lightweight theme defaults.

Target spec: **4 GB RAM, 32-bit-OK iGPUs of the 2015+ era, single-user, non-gaming.**

### Keep
- KDE Plasma (minimal) — Dolphin, Gwenview, Spectacle, Ark, KCalc. **No** Kdenlive, Krita, heavy apps.
- Firefox (Flatpak)
- Thunderbird (Flatpak)
- VLC (Flatpak)
- NetworkManager, Bluetooth, printing

### Add
- **OnlyOffice Mobile** or **WPS Office** (Flatpak) — lighter than full OnlyOffice Desktop; if disk/RAM very constrained, push users to web office suites instead
- **Signal Desktop** (Flatpak) — low resource, widely useful
- Not much else. Padkos is defined by what we *don't* include.

### Explicitly remove
- OnlyOffice Desktop Editors (too heavy; use web version or WPS if user insists)
- Spotify, Discord, Zoom (Flatpaks are heavy; web versions recommended via Firefox shortcuts)
- Developer tools (users who need them should use Chunky on better hardware)
- Multimedia editing (GIMP/Kdenlive/Darktable/OBS — all absent)
- Animations / compositing effects in KDE are turned off by default for speed
- Any app > 500 MB installed footprint

### Welcome app prompts
Short list, aimed at "what do you actually need?":
- Web shortcuts (Gmail, Google Docs, Outlook Web) as pinned Firefox apps
- OnlyOffice Desktop if user really wants it (with a warning about resources)

### Padkos philosophy

Padkos isn't "Hearty stripped." It's "what does this old laptop actually need?" Assume the user is using it for: browsing, email, basic docs, video. Make those fast. Everything else is optional.

---

## 🔥 Braai — Gaming edition

**Base:** Bazzite (KDE variant). **We inherit nearly everything from Bazzite unchanged.**

### Keep everything Bazzite ships
- Steam
- Proton (with auto-update)
- Proton-GE (via ProtonUp-Qt)
- Lutris
- Heroic Games Launcher
- Bottles
- Gamescope
- MangoHud + Goverlay
- Bazzite's gaming-tuned kernel
- Input Remapper, controller support, Steam Input
- DXVK, VKD3D
- 32-bit libraries for legacy games
- NVIDIA driver integration where applicable

### Add (Macrosofty-specific additions)
- **Discord** (Flatpak) — gamers communicate on it, don't pretend otherwise
- **OBS Studio** (Flatpak) — streaming and clipping
- **Moonlight** (Flatpak) — streaming games from a separate host (NVIDIA Shield-style)
- Hearty's core set (Firefox, OnlyOffice Desktop, VLC, Thunderbird, Signal) — Braai users deserve a functional OS too

### Remove from Bazzite upstream
- Bazzite-specific branding (obviously)
- Any Bazzite welcome app — replaced with Macrosofty's

### Welcome app prompts
Focus on gaming extras:
- Gamemode configuration
- Controller first-run pairing
- "Set up Steam sync / Heroic / Epic login" deep links
- Optional: Steam Deck gaming mode simulator (for handheld users)

---

## Cross-edition additions (firstboot optional picker)

These live in the "want these?" step of firstboot, **off by default**, organized by category:

### Communication
Slack, Microsoft Teams (web wrapper), Element (Matrix), Telegram, Skype Web

### Creative
GIMP, Inkscape, Krita, Darktable, Kdenlive, OBS Studio, Audacity

### Gaming extras (in non-Braai editions)
Steam, Lutris — with a warning that Braai is better-tuned

### Productivity+
LibreOffice (if Chunky isn't chosen), Thunderbird, Joplin, Obsidian (Flatpak)

### Privacy / security tools
Bitwarden, KeePassXC, Proton VPN, Tor Browser

---

## Curation change process

To add, remove, or swap an app in a default edition:

1. Open a GitHub Discussion in "Ideas" with:
   - What app
   - Which edition(s)
   - Why (one paragraph, specific about the user need)
   - What it replaces, if anything
   - Flatpak or RPM, and why
2. Maintainer decision within ~2 weeks.
3. If accepted, PR updates this doc + the relevant `Containerfile`.

**No silent changes.** The default app set is part of the product identity; changes are communicated in release notes.
