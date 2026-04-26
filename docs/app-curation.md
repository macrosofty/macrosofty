# App Curation per Edition

**Status:** Source of truth as of **2026-04-26**. Audit-driven (Aurora/Aurora-DX/Bazzite upstreams inspected). Supersedes the pre-scaffold draft of this file. Update on every curation change.

---

## How to read this doc

Each edition section has the same shape so changes are easy to diff:

1. **Promise** — what VISION.md tells the user this edition does.
2. **Base image** — which upstream Containerfile we extend.
3. **Inherited (free)** — what arrives in the image without us doing anything. Drawn from the upstream audit (§3).
4. **Layered RPMs** — what our `editions/<edition>/build.sh` adds via `dnf5 install`.
5. **Stripped RPMs** — what our `build.sh` removes via `dnf5 remove`.
6. **Firstboot Flatpaks** — what gets pulled the first time the user boots, via Universal Blue's `system-flatpaks` mechanism. Lazy-loaded; weight only on first launch.
7. **Rationale** — why each non-obvious choice.

---

## 1. Principles

1. **Atomic first.** No decision compromises the doesn't-break property.
2. **Inherit ruthlessly.** Aurora and Bazzite already do most of the work. We add only what the gap analysis identifies.
3. **Flatpak first** for user-facing apps. Layered RPMs only when (a) we need offline-first-boot (Padkos's and Chunky-LJ's promise) or (b) host integration is required.
4. **Every app earns its place.** If we can't write one sentence defending why it ships in defaults, it doesn't.
5. **No account-required apps as default.** Firefox is the exception; users expect a browser.
6. **No duplicates.** One office suite per edition, one media player per edition.
7. **The system is opinionated. The desktop is yours.** Curation defaults are decided; users can install or remove anything via Discover/Bazaar.

---

## 2. Edition shape

We ship **four brands** (Hearty, Chunky, Padkos, Braai) but build **five images**, because Chunky has two hardware variants:

| Brand | Build | Base image | Hardware target |
|---|---|---|---|
| 🍲 Hearty | `hearty` | `ghcr.io/ublue-os/aurora:stable` | Modern x86-64, normie user |
| 🍖 Chunky (Modern) | `chunky` | `ghcr.io/ublue-os/aurora-dx:stable` | Modern x86-64, knowledge worker / light dev |
| 🍖 Chunky (Long Journey) | `chunky-lj` | `ghcr.io/ublue-os/aurora:stable` | 4–8 GB RAM, 2014-era hardware that's still capable |
| 🧺 Padkos | `padkos` | `ghcr.io/ublue-os/aurora:stable` | 4 GB RAM, basic-task user, possibly offline-at-firstboot |
| 🔥 Braai | `braai` | `ghcr.io/ublue-os/bazzite:stable` | x86-64-v3, gamer |

**Download UX:** the website shows four cards. Chunky's card has an inline picker:

> Choose your hardware:  ●︎ Modern (8 GB+ RAM)   ◯ Long Journey (4–8 GB RAM)

Both Chunky variants identify as "Macrosofty Chunky" in `os-release` and `neofetch` — same wallpaper, same panels, same firstboot. The variant difference shows up in `bootc status` (different image stream) and in a small parenthetical in `neofetch` (`Macrosofty Chunky (Long Journey)`) so support knows which one we're looking at.

**Bokkie (ARM)** is post-v1 per VISION.md and not covered here. When it lands, it forks Fedora Kinoite directly (UBlue is x86-only).

---

## 3. Upstream audit — what we inherit for free

Audited against `ublue-os/aurora`, `ublue-os/aurora` (DX flavour), and `ublue-os/bazzite` on 2026-04-26.

### 3.1 Aurora base (`ghcr.io/ublue-os/aurora:stable`)

Built from `quay.io/fedora-ostree-desktops/kinoite` + ~75 layered RPMs + 20 firstboot Flatpaks.

**Layered RPMs (selection — full list at `ublue-os/aurora` `build_files/base/01-packages.sh`):**

- **Tools:** `tmux`, `vim`, `zsh`, `fish`, `htop`, `nvtop`, `fastfetch`, `glow`, `gum`, `ptyxis` (Distrobox-aware terminal), `distrobox`, `gcc`, `just`, `kate`, `ksshaskpass`, `ksystemlog`
- **Networking:** `tailscale`, `samba-winbind`, `samba-winbind-clients`, `samba-winbind-modules`, `iwd`, `davfs2`, `traceroute`, `tcpdump`
- **Multimedia codecs:** `ffmpeg`, `ffmpeg-libs`, `libfdk-aac`, `libheif`, `libva-utils`, `libcamera-gstreamer`, `pipewire-libs-extra`, `intel-vaapi-driver` — all from negativo17 with priority 90 (= unencumbered codecs, Netflix/Widevine-ready)
- **Power management:** `powertop`, `powerstat`, `lm_sensors`
- **Identity / auth:** `krb5-workstation`, `oddjob-mkhomedir`, `pam-u2f`, `pam_yubico`, `pamu2fcfg`, `yubikey-manager`, `adcli`
- **Internationalisation:** full `fcitx5` stack (Chinese, Korean, Vietnamese, Thai, Japanese, plus `kcm-fcitx5` KDE module), Noto fonts (Balinese, Javanese, Sundanese, CJK), Tesseract OCR with 16 language packs
- **Hardware:** `solaar-udev` (Logitech Unifying), `libratbag-ratbagd` (gaming-mouse config), `input-remapper`, `openrgb-udev-rules`, `libcamera-tools`, `evtest`, `igt-gpu-tools`
- **Mobile/iPhone:** `libimobiledevice-utils`, `ifuse`
- **Backup:** `borgbackup`, `restic`, `rclone`
- **Printing:** `foo2zjs`, `uld` (Samsung/Brother drivers)
- **Niche:** `Sunshine` (game streaming server, from `lizardbyte/beta` COPR), `kAirpods` (AirPods support, from `ledif/kairpods` COPR), `plasma-wallpapers-dynamic` (animated KDE wallpapers)
- **Filesystem/admin:** `squashfs-tools`, `symlinks`, `lshw`, `setools-console`, `gvfs`, `gvfs-fuse`
- **GRUB extras:** `grub2-tools-extra`

**Firstboot Flatpaks** (`get-aurora-dev/common` → `system_files/shared/usr/share/ublue-os/homebrew/system-flatpaks.Brewfile`):

```
com.github.tchx84.Flatseal
io.github.DenysMb.Kontainer
io.github.flattool.Warehouse
io.github.kolunmi.Bazaar
io.missioncenter.MissionCenter
org.deskflow.deskflow
org.fedoraproject.MediaWriter
org.fkoehler.KTailctl
org.gnome.DejaDup
org.gtk.Gtk3theme.Breeze
org.kde.gwenview
org.kde.haruna
org.kde.kcalc
org.kde.kclock
org.kde.kontact
org.kde.kweather
org.kde.okular
org.kde.skanpage
org.mozilla.Thunderbird
org.mozilla.firefox
```

**Stripped from Kinoite by Aurora:** `akonadi-server`, `akonadi-server-mysql` (KDE PIM stack — Kontact returns as Flatpak instead), `firefox`, `firefox-langpacks` (replaced by Firefox Flatpak), `fedora-third-party`, `fedora-chromium-config`, `firewall-config` (replaced by `plasma-firewall`), `plasma-welcome-fedora`, `plasma-discover-rpm-ostree`, `plasma-discover-kns`, `kcharselect`, `khelpcenter`, `krfb`, `krfb-libs`, `podman-docker`, `ffmpegthumbnailer`, `default-fonts-cjk-sans`, `google-noto-sans-cjk-vf-fonts`.

**Pinned versions:** `qt6-*`, `plasma-desktop` (versionlocked to prevent SDDM/KWin breakage on KDE major upgrades).

**Repo overrides:** `mesa-*`, `intel-vpl-gpu-rt`, `libheif`, `libva-*`, `intel-mediasdk`, `intel-gmmlib` all swapped to negativo17's unencumbered builds.

### 3.2 Aurora-DX (`ghcr.io/ublue-os/aurora-dx:stable`)

Aurora base + everything in `ublue-os/aurora` `build_files/dx/00-dx.sh`.

**Adds:**

- **Cockpit suite:** `cockpit-bridge`, `cockpit-machines`, `cockpit-networkmanager`, `cockpit-ostree`, `cockpit-podman`, `cockpit-selinux`, `cockpit-storaged`, `cockpit-system`
- **Virtualisation:** `libvirt`, `libvirt-nss`, `qemu`, `qemu-char-spice`, `qemu-device-display-virtio-gpu`, `qemu-device-display-virtio-vga`, `qemu-device-usb-redirect`, `qemu-img`, `qemu-system-x86-core`, `qemu-user-binfmt`, `qemu-user-static`, `lxc`, `incus`, `incus-agent`, `edk2-ovmf`, `virt-manager`, `virt-v2v`, `virt-viewer`
- **Containers:** `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, `docker-compose-plugin`, `docker-model-plugin`, `podman-compose`, `podman-machine`, `podman-tui`, `podman-bootc` (COPR `gmaglione/podman-bootc`), `kcli` (COPR `karmab/kcli`)
- **Dev:** `code` (VS Code from Microsoft repo), `flatpak-builder`, `android-tools`, `p7zip`, `p7zip-plugins`, `ydotool`, `trace-cmd`, `sysprof`, `udica`
- **Profiling/perf:** `bcc`, `bpftop`, `bpftrace`, `iotop`, `nicstat`, `numactl`, `osbuild-selinux`
- **AMD GPU compute (non-NVIDIA only):** `rocm-hip`, `rocm-opencl`, `rocm-smi`
- **VM workarounds:** `ublue-os-libvirt-workarounds`

**DX-specific firstboot Flatpaks:**
```
io.podman_desktop.PodmanDesktop
io.github.getnf.embellish
me.iepure.devtoolbox
```

### 3.3 Bazzite KDE base (`ghcr.io/ublue-os/bazzite:stable`)

Built from a Bazzite-specific Fedora-atomic base — broader scope than Aurora, gaming-focused.

**Layered RPMs (selection):**

- **Gaming:** `steam`, `gamescope.x86_64`, `gamescope-libs.x86_64`, `gamescope-libs.i686`, `gamescope-shaders`, `lutris`, `umu-launcher`, `vkBasalt.x86_64`, `vkBasalt.i686`, `mangohud.x86_64`, `mangohud.i686`, `libobs_vkcapture.{x86_64,i686}`, `libobs_glcapture.{x86_64,i686}`, `openxr`, `winetricks`
- **Audio (Valve-patched):** `pipewire`, `wireplumber`, `bluez` swapped to Valve's patched versions for low-latency
- **Display (Valve-patched):** `xorg-x11-server-Xwayland`, `NetworkManager` swapped
- **Mesa (terra-mesa):** swapped from terra-mesa for better gaming drivers
- **Hardware tuning:** `jupiter-fan-control`, `jupiter-hw-support`, `framework-system`, `ryzenadj`, `ddcutil`, `ds-inhibit`, `iio-sensor-proxy`, `fw-ectool`, `fw-fanctrl`, `iptsd` (Surface), `libwacom-surface`
- **Containers/admin:** `cockpit-networkmanager`, `cockpit-podman`, `cockpit-selinux`, `cockpit-system`, `cockpit-files`, `cockpit-storaged`, `waydroid`, `cage`, `wlr-randr`, `bazzite-portal`
- **AMD GPU compute:** `rocm-hip`, `rocm-opencl`, `rocm-clinfo`
- **Audio production:** `ladspa-caps-plugins`, `ladspa-noise-suppression-for-voice`, `pipewire-module-filter-chain-sofa`
- **Filesystems:** `bees` (btrfs dedupe), `snapper`, `btrfs-assistant`, `compsize`
- **KDE extras:** `kdeplasma-addons`, `kdeconnectd`, `krdp`, `krdc`, `rom-properties-kf6`, `steamdeck-kde-presets-desktop`, `kio-extras`, `krunner-bazaar`
- **Tools:** `btop`, `duf`, `fish`, `glow`, `gum`, `vim`, `xdotool`, `wmctrl`, `vulkan-tools`, `topgrade`, `webapp-manager`, `xwiimote-ng`
- **Fonts:** `nerd-fonts`, `fira-code-fonts`, `lato-fonts`, `twitter-twemoji-fonts`, `google-noto-sans-cjk-fonts`

**KDE firstboot Flatpaks** (`bazzite/installer/kde_flatpaks/flatpaks`):
```
org.mozilla.firefox
org.kde.gwenview
org.kde.okular
org.kde.kcalc
org.kde.haruna
org.kde.filelight
io.github.DenysMb.Kontainer
com.github.tchx84.Flatseal
com.github.Matoking.protontricks
io.github.flattool.Warehouse
com.vysp3r.ProtonPlus
com.obsproject.Studio.Plugin.OBSVkCapture
com.obsproject.Studio.Plugin.Gstreamer
com.obsproject.Studio.Plugin.GStreamerVaapi
org.freedesktop.Platform.VulkanLayer.MangoHud
org.freedesktop.Platform.VulkanLayer.vkBasalt
org.freedesktop.Platform.VulkanLayer.OBSVkCapture
```

**Stripped by Bazzite:** `firefox`, `firefox-langpacks` (replaced with Flatpak), `htop` (replaced with `btop`), `toolbox`, `gamemode`, `mesa-va-drivers`, `plasma-drkonqi`, `plasma-welcome`, `plasma-welcome-fedora`, `plasma-discover-kns`, `kcharselect`, `kde-partitionmanager`, `plasma-discover` (replaced with Bazaar), `pipewire-config-raop`, `ublue-os-update-services`.

---

## 4. Per-edition plans

### 4.1 🍲 Hearty

**Promise (VISION.md):** *"Browser, email, photos, video calls, Netflix, printing, messaging."*

**Base:** `ghcr.io/ublue-os/aurora:stable`

**Inherited:** Browser ✓ (Firefox Flatpak), email ✓ (Thunderbird Flatpak), photos ✓ (Gwenview Flatpak), Netflix ✓ (codecs in via negativo17), printing ✓ (`foo2zjs` + `uld` + CUPS).

**Gaps to close:**
- **Video calls** — no Zoom-equivalent ships in Aurora.
- **Messaging** — no Signal/Element/etc. ships in Aurora.

**Layered RPMs (build.sh):** none. *(Drop the redundant `tmux` line in the current scaffold — already in Aurora.)*

**Stripped RPMs:** none.

**Firstboot Flatpaks (Macrosofty additions):**
```
us.zoom.Zoom
org.signal.Signal
im.riot.Riot
```

**Rationale:**
- `us.zoom.Zoom` — proprietary, but it's *the* video-call app non-technical users need. Skipping it would force every grandparent to figure out Flathub on day one.
- `org.signal.Signal` — secure messaging, mainstream enough to ship by default.
- `im.riot.Riot` (Element) — FOSS messaging on Matrix. Federated, so the user isn't locked into one provider; bridges to IRC/Slack/Discord exist for the rare case the recipient is on something else.
- **Skipped on purpose:** Microsoft Teams (it's the rival's product), Skype (deprecated), Discord (gamer-coded — lives in Braai), WhatsApp (no Linux client worth shipping).

---

### 4.2 🍖 Chunky (Modern)

**Promise (VISION.md):** *"Everything Hearty has, plus a full office suite, PDF editing that actually edits, better file management, developer tools if you want them, and a little more muscle behind the scenes."*

**Base:** `ghcr.io/ublue-os/aurora-dx:stable`

**Inherited:** Everything Hearty inherits, **plus** Cockpit, virt-manager, KVM/QEMU, Docker + Compose, VS Code, podman-bootc, kcli, ROCm, bcc/bpftrace/iotop, android-tools, flatpak-builder. Dev-tools promise ✓.

**Gaps to close:**
- **Office suite** — not in Aurora-DX.
- **PDF editing that actually edits** — Okular is in (Flatpak), but it's view-with-annotations, not real editing.
- **Image/vector work** *(implicit in "knowledge worker")* — not shipped.

**Layered RPMs (build.sh):** none. *(Drop the redundant `tmux` line in the current scaffold — already in Aurora.)*

**Stripped RPMs:** none. Chunky-Modern is a superset of Hearty.

**Firstboot Flatpaks (Macrosofty additions, on top of Aurora's 20 + Aurora-DX's 3):**
```
# All of Hearty's additions:
us.zoom.Zoom
org.signal.Signal
im.riot.Riot
# Plus:
org.libreoffice.LibreOffice
com.github.xournalpp.xournalpp
org.gimp.GIMP
org.inkscape.Inkscape
```

**Rationale:**
- `org.libreoffice.LibreOffice` — full suite. ~700 MB on disk only after first launch (Flatpak lazy load); zero RAM cost when closed.
- `com.github.xournalpp.xournalpp` — actually edits PDFs (annotation, drawing, form-filling). Lighter than alternatives.
- `org.gimp.GIMP`, `org.inkscape.Inkscape` — knowledge-worker creative basics. Both lazy-loaded.

---

### 4.3 🍖 Chunky (Long Journey)

**Promise:** Same user-facing promise as Chunky-Modern — same identity in `os-release` — but runs on 4–8 GB RAM, 2014-era hardware.

**Base:** `ghcr.io/ublue-os/aurora:stable` *(deliberately not aurora-dx — Cockpit + virt-manager + Docker + KVM + bcc + bpftrace + ROCm is wasted weight on old hardware)*

**Inherited:** Same as Hearty (Aurora's full set), but *not* the DX layer.

**Gaps to close:** Same as Chunky-Modern's user-visible promise (office, PDF editing, creative basics).

**Layered RPMs (build.sh) — offline-first-boot set:**
- `firefox` (RPM, **not Flatpak**) — Aurora ships Firefox as a Flatpak that fires at firstboot; an offline rescued laptop wouldn't get a browser. The killer case is **captive-portal wifi** (coffee shop / hotel) — without a browser open at firstboot, the user can't authenticate the network *to get* internet *to download* the Firefox Flatpak. RPM breaks that catch-22. Secondary value: opening local files and any local help/welcome HTML.
- `libreoffice` (RPM, **not Flatpak**) — pure offline-creation tool. Type a letter, save, print. Zero internet needed for the entire user flow. ~700 MB image weight; worth it for the promise.

**Thunderbird stays as Flatpak (deliberately).** Email setup requires internet anyway (IMAP/SMTP account wizard talks to remote servers). Whether Thunderbird arrives via RPM at install or via Flatpak 30 seconds after wifi connects is functionally identical. No offline-first-boot value — would just be cargo-culting the Firefox/LibreOffice pattern.

**Stripped RPMs:** none. Don't pre-emptively strip — the LJ user is buying Chunky's promise, just on slower hardware. Krita/Kdenlive *can* run on 4–8 GB if the user opens them.

**Firstboot Flatpaks:** identical to Chunky-Modern. Aurora's existing Firefox Flatpak will install on top of our RPM once internet arrives — slight redundancy (last-launched wins in the menu); both work, no functional break.

**Identity:** `os-release` reports `Macrosofty Chunky`. `neofetch` includes `(Long Journey)` parenthetical. `bootc status` shows `ghcr.io/macrosofty/chunky-lj:latest`.

**Rationale:** keeps the Chunky brand promise honest while sidestepping the dev-tooling weight. The downside: a Chunky-LJ user who later wants Docker/virt-manager/Cockpit can `bootc switch` to the Modern stream — that's the atomic upgrade path, no reinstall.

---

### 4.4 🧺 Padkos

**Promise (VISION.md):** *"Browser, email, documents, video. Quiet, light, dignified."*

**Base:** `ghcr.io/ublue-os/aurora:stable`

**Inherited:** Browser ✓, email ✓ (Thunderbird Flatpak), video ✓ (Haruna Flatpak + ffmpeg codecs).

**Gaps to close:**
- **Documents** — no office suite in Aurora; the existing `build.sh` comment "we keep LibreOffice" was misleading (it was never inherited).
- **Old-hardware tuning** — Aurora's full set is heavier than Padkos's audience needs.
- **Offline first-boot** — old laptops get rescued by their grandkids, often without immediate internet. Padkos has to be usable the moment Anaconda finishes.

**Layered RPMs (build.sh) — offline-first-boot set:**
- `firefox` (RPM, **not Flatpak**) — for offline first-boot. *Already in current `build.sh`.* Killer case is captive-portal wifi authentication; secondary is opening local files / local help HTML.
- `libreoffice` (RPM, **not Flatpak**) — **NEW.** Aurora ships no office suite by default and the planned Flatpak only installs with internet. Padkos bakes it into the image so a rescued laptop can write a document on day one without internet. Trade: ~700 MB image weight per install. Worth it for the promise.

**Thunderbird stays as Flatpak (deliberately, same logic as Chunky-LJ).** Fresh-install email requires internet to talk to IMAP/SMTP. Shipping the RPM would not change the user experience versus the Flatpak that arrives with the first internet connection.

**Stripped RPMs (already in current `build.sh`, keep as-is):**
- KDE PIM stack: `akonadi*`, `kmail*`, `kontact*`, `korganizer*`, `kaddressbook*`, `kalendar*`, `kdepim*` — Akonadi runs a per-user MariaDB-equivalent in the background; on a 4 GB box it's the single biggest "why is this slow" culprit. Webmail covers most users; Thunderbird Flatpak is one click away.
- Heavy creative: `krita`, `kdenlive`, `digikam` — Flathub has current builds, install in Discover for the rare user who wants them.

**Firstboot Flatpaks (Macrosofty additions):**
- *(none — Padkos deliberately ships fewer Flatpaks than other editions to keep first-boot RAM/IO pressure down. If a user wants Zoom or Signal, they can install via Discover.)*

**Rationale:**
- "Documents" was the load-bearing word in Padkos's promise; LibreOffice as RPM (alongside Firefox already there) completes the Padkos offline-first-boot kit. The same pattern is mirrored on Chunky-LJ — both editions share this offline promise; everything else (Hearty, Chunky-Modern, Braai) assumes internet.
- Stripping is conservative on purpose — only well-known heavy apps with self-contained Flathub equivalents. Removing too much risks breaking the desktop; the doesn't-break property is non-negotiable.
- Update the misleading comment in `build.sh` from "we keep LibreOffice" to reflect the new RPM-install reality.

---

### 4.5 🔥 Braai

**Promise (VISION.md):** *"Steam, Proton, Lutris, Heroic, Bottles — pre-configured and kept current. Controllers plug in and work."*

**Base:** `ghcr.io/ublue-os/bazzite:stable`

**Inherited:** Steam ✓, Proton ✓ (via ProtonPlus Flatpak from Bazzite), Lutris ✓, gamescope ✓, MangoHud ✓, controllers ✓ (jupiter-hw-support, evtest, openxr), Valve-patched audio/display ✓.

**Gaps to close:**
- **Heroic Games Launcher** — not in Bazzite.
- **Bottles** — not in Bazzite.

**Layered RPMs (build.sh):** none.

**Stripped RPMs:** none. Bazzite already strips what we'd want stripped.

**Firstboot Flatpaks (Macrosofty additions, on top of Bazzite's 17):**
```
com.heroicgameslauncher.hgl
com.usebottles.bottles
```

**Rationale:**
- Both fill specific gaps the VISION promised. Both are Flathub-canonical and inherit cleanly from Bazzite's existing gaming stack (DXVK, Proton, controllers all already in place).
- We deliberately do NOT add Hearty's video-call/messaging set to Braai. Gamers run Discord; Discord lives in Welcome-app prompts (out-of-the-box Flathub install), not defaults. If the user wants Zoom, they install it.

---

## 5. How firstboot Flatpaks are delivered

Universal Blue's mechanism: `system_files/shared/usr/share/ublue-os/homebrew/system-flatpaks-macrosofty.Brewfile` per edition. The `ublue-os-just install-system-flatpaks` service runs at first boot, reads every `system-flatpaks*.Brewfile` it finds, and installs them.

Aurora's existing list is co-loaded automatically (we inherit it from upstream). Our additions live in a separate file so we don't conflict with Aurora upgrades.

**File layout:**
```
editions/<edition>/
└── system-flatpaks-macrosofty.Brewfile    # this edition's additions
```

The `build.sh` for each edition copies its `Brewfile` to `/usr/share/ublue-os/homebrew/system-flatpaks-macrosofty.Brewfile` inside the image. Universal Blue's firstboot service handles the rest.

---

## 6. Decisions locked (2026-04-26)

1. **Five builds, four brands.** Chunky has Modern + Long Journey variants behind one download card.
2. **Hearty firstboot adds: Zoom + Signal + Element. No Teams, Skype, WhatsApp, or Discord.** Discord lives in the welcome-app prompts when those land.
3. **Offline-first-boot is an explicit promise on Padkos and Chunky-LJ — and only those.** Both editions install **Firefox + LibreOffice as RPMs** in the image so a rescued laptop boots a usable OS without ever touching wifi. Thunderbird intentionally stays as Flatpak — fresh-install email requires internet anyway, so RPM-vs-Flatpak makes no functional difference. Hearty, Chunky-Modern, and Braai assume internet at firstboot (their personas almost always have it).
4. **LibreOffice delivery:** RPM on Padkos and Chunky-LJ (offline promise). Flatpak on Chunky-Modern. Not shipped on Hearty or Braai.
5. **No `tmux` in our `build.sh`s.** Aurora already includes it; the line is dead weight. Same audit for any other "I assumed it was missing" packages.
6. **Drop the `containers-storage:` ISO workaround.** GHCR packages flipped public 2026-04-26; jasonn3 fetches over the registry directly.

---

## 7. Open questions to revisit

- **Should Hearty also ship offline-first-boot RPMs (Firefox + LibreOffice)?** Currently no — modern-hardware buyer almost always has wifi, and we save ~950 MB image weight. Revisit if "I installed Hearty offline and nothing worked" appears in GitHub Discussions.
- **Welcome-app picker UI.** VISION mentions a firstboot picker for optional apps (Slack, Telegram, GIMP-on-Hearty, etc.). Not in v0.1 scope; covered when "Make it yours" app lands (v0.3 target per CLAUDE.md).
- **Image weight verification.** Padkos and Chunky-LJ each gain ~700 MB from LibreOffice RPM (Firefox is already in Padkos; Chunky-LJ adds ~250 MB for Firefox RPM too). Verify on the next build that:
  - Padkos stays under its current ~4.6 GB ISO budget (~700 MB of LibreOffice is net new).
  - Chunky-LJ lands somewhere around 5.5 GB — comfortably under Chunky-Modern's 6.2 GB.
  - If either blows out the 8 GB free-runner-disk budget, reconsider whether to ship LibreOffice as Flatpak on the affected edition and accept the offline-first-boot regression *for that edition only*.
- **Firefox RPM-vs-Flatpak menu redundancy.** On Padkos and Chunky-LJ, Aurora's firstboot Flatpak service will install Firefox-Flatpak on top of our RPM once internet arrives. Both copies work; the launcher shows one icon (last-installed wins). Mild UX wart, no functional break. Could fix by overriding Aurora's Brewfile to skip Firefox on these editions — added complexity, not clearly worth it. Revisit if users report confusion.
- **Chunky-LJ stripping.** Currently planned to strip nothing. If first-real-user testing shows even Chunky-LJ users on a 4 GB box struggle with Akonadi + creative-app installs, we'd revisit and selectively strip — but match Padkos's strip set, not invent new ones.
- **Bokkie (post-v1).** When ARM lands, redo this audit against Fedora Kinoite aarch64 directly. Don't assume any of this carries over.

---

## 8. Curation change process

To add, remove, or swap an app in a default edition:

1. Open a GitHub Discussion in **Ideas** with:
   - The app
   - Which edition(s)
   - One paragraph: why (specific user need)
   - What it replaces, if anything
   - Flatpak or RPM, and why
2. Maintainer decision within ~2 weeks.
3. If accepted, PR updates this doc + the relevant `build.sh` and `system-flatpaks-macrosofty.Brewfile`.

**No silent changes.** The default app set is part of the product identity; changes are communicated in release notes.
