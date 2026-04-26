# Share & Serve — Project Proposal

**Status:** Proposed (roadmap entry #39 in `docs/value-adds-roadmap.md`)
**Target:** v0.4 (after v0.3's "Make It Yours" panel)
**Owner:** unassigned
**Last updated:** 2026-04-26

A first-class panel for hosting personal services from a regular Macrosofty desktop. **Make Jellyfin / Syncthing / Pi-Hole / Vaultwarden / Immich as easy to set up as installing a Flatpak — without the user ever knowing what Docker is.**

---

## Table of contents

1. [Executive summary](#executive-summary)
2. [The problem](#the-problem)
3. [Personas and user stories](#personas-and-user-stories)
4. [Goals and non-goals](#goals-and-non-goals)
5. [UX flow with sketches](#ux-flow-with-sketches)
6. [Architecture](#architecture)
7. [Service catalog (v1)](#service-catalog-v1)
8. [Edge cases and risks](#edge-cases-and-risks)
9. [Implementation phases](#implementation-phases)
10. [Open questions](#open-questions)
11. [Appendix](#appendix)

---

## Executive summary

A KDE Plasma config module ("kcm_macrosofty_share_and_serve") that lets a regular user pick from a curated catalog of self-hosting services and set them up in under a minute, without typing a command or editing a config file.

Behind the scenes, services run as **podman Quadlets** (declarative systemd units around containers). Storage uses bind-mounted user folders with correct permissions. Discovery uses **mDNS** (Avahi) so other devices on the wifi find services without IPs. Optional remote access via **Tailscale** or **Cloudflare Tunnel**. Auto-updates via `podman auto-update`.

The result: **Macrosofty becomes the first desktop OS that's also a friendly personal server.** Hardware-recycler persona's old laptop is now the family's media + photos + passwords machine. Privacy-conscious user runs everything locally instead of trusting a SaaS. Curious noob actually gets to try Pi-Hole.

---

## The problem

Self-hosting today splits into two camps:

- **Dedicated NAS / homelab gear** (TrueNAS Scale, unRAID, Synology DSM, Proxmox). Powerful, polished, but you buy a separate machine, can't really use it as your daily-driver desktop, and the price floor is ~$300–500.
- **Desktop Linux + Docker fluency** (any distro, drop into terminal, write your own compose files). Free, flexible, but assumes you know what a port is, what a volume mount is, what a reverse proxy is.

There's nothing in the middle. **A friendly desktop OS that's *also* a friendly personal server doesn't exist** — and the audience for it is large:

- Hardware-recycler persona has spare hardware capacity but no on-ramp to use it.
- Relative-supporter wants to set up a media server for parents without becoming sysadmin.
- Privacy-conscious refugee wants their photos / passwords / files local but doesn't have time to learn Docker.
- Curious noob heard about Pi-Hole on Reddit, the docs are Greek, they bounce.

Macrosofty's audience overlaps perfectly with all four. We have podman + distrobox already in every edition (Aurora and Bazzite both ship them). The technical foundation is there. The UX layer is missing.

---

## Personas and user stories

### Hardware recycler — "Bertus, 47, Bloemfontein"

Has a 2018 ThinkPad collecting dust since the family upgraded. Wants it to be useful again. Saw a YouTube about Jellyfin, was intrigued, gave up after the third Docker compose example.

> "I have a hard drive of family videos. I want to watch them on the TV. I don't want to learn anything called 'reverse proxy'."

**With Share & Serve:** opens panel → clicks Jellyfin → points at the videos folder → clicks "Set it up" → 60 seconds later he gets a link to copy to his TV's browser. Done. He calls his daughter in Cape Town to show her a video over Tailscale.

### Relative-supporter — "Mei, 34, Auckland"

Sets up her parents' computers. Mom has thousands of photos in a folder she keeps "backing up" to a USB drive that gets lost. Wants Mom's phone to auto-upload photos to her own laptop, like Google Photos but private.

> "Mom doesn't trust the cloud. She'd love something that just works. I have one weekend."

**With Share & Serve:** sets up Immich on Mom's laptop, points at her photos folder, sets up the mobile app pointing at `mom-pc.local:2283`. Phone auto-uploads. Photos stay on the laptop. One weekend, done, including the home wifi setup.

### Privacy-conscious refugee — "Karim, 29, Berlin"

Quit Google Photos and 1Password. Wants Vaultwarden + Immich + Nextcloud running on his desktop so his family of three can use them without anyone seeing the data. Tried Docker, it works, but his partner can't change anything because the recovery instructions are bash scripts.

> "I want my partner to be able to fix things if I'm away. The CLI doesn't scale across the household."

**With Share & Serve:** services are visible and manageable in the panel. His partner can stop, start, restart services or check logs without sudo or terminal. Updates happen automatically. If something breaks, the panel says "Vaultwarden stopped — view logs / restart / roll back".

### Curious noob — "Tomi, 22, Lagos"

Reddit-scrolled into self-hosting. Pi-Hole sounds amazing. Spent an evening trying to follow the docs, gave up at "set up your router's DNS to point at the Pi". Doesn't own a Pi.

> "I just want ads to go away on every device. Why is this 12 steps?"

**With Share & Serve:** runs Pi-Hole on his Hearty laptop, panel says "tell your router to use this address". One step instead of 12.

---

## Goals and non-goals

### Goals

- Make popular self-hosted services trivial to install, manage, and remove.
- Keep the desktop fully usable while services run (services don't take over the system).
- Discoverable on LAN via mDNS — `padkos.local:8096` for Jellyfin, no IP-typing.
- Optional, opt-in remote access via Tailscale or Cloudflare Tunnel.
- Auto-start on boot. Auto-update weekly. Auto-rollback if a service can't restart.
- Plain-English error messages and recovery flows.
- Power-user escape hatch: edit the underlying Quadlet directly if needed.

### Non-goals

- **Become a full NAS.** No RAID setup, no SMART disk monitoring, no software-defined storage. Users with NAS needs use a NAS.
- **Support arbitrary Docker images.** v1 ships a curated catalog. Power users can hand-write Quadlets in advanced mode; the panel UI is curated.
- **Cluster / multi-machine orchestration.** One machine. No Kubernetes-shaped ambition.
- **Enterprise features.** No SSO, no LDAP, no centralised logging. This is for households, not companies.
- **Replace bootc atomic updates.** Services are containerised and update independently of the OS. The OS still updates atomically.

---

## UX flow with sketches

ASCII because we don't have Figma in this repo. Treat as wireframes; visual designer would polish later.

### Main panel — when no services are installed

```
┌─ Share & Serve ─────────────────────────────────────────┐
│                                                         │
│  Make your computer share things with you.              │
│  Pick something to set up — we'll handle the boring    │
│  bits.                                                  │
│                                                         │
│  ┌─── Available ────────────────────────────────────┐  │
│  │                                                  │  │
│  │  📺 Jellyfin                                    │  │
│  │     Stream your movies, music, and photos        │  │
│  │                                                  │  │
│  │  📁 Syncthing                                   │  │
│  │     Keep folders synced across your devices      │  │
│  │                                                  │  │
│  │  🛡️  Pi-Hole                                    │  │
│  │     Block ads on every device on your wifi       │  │
│  │                                                  │  │
│  │  🔐 Vaultwarden                                 │  │
│  │     Run your own password manager                │  │
│  │                                                  │  │
│  │  📷 Immich                                      │  │
│  │     Like Google Photos, but it stays on your PC  │  │
│  │                                                  │  │
│  │  🏠 HomeAssistant                               │  │
│  │     Smart-home dashboard                         │  │
│  │                                                  │  │
│  │  🎧 Audiobookshelf                              │  │
│  │     Stream your audiobooks and podcasts          │  │
│  │                                                  │  │
│  │  ☁️  Nextcloud                                  │  │
│  │     Your own cloud storage, calendar, contacts   │  │
│  │                                                  │  │
│  │  🎵 Navidrome                                   │  │
│  │     Stream your music library                    │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  Want to run something else?                            │
│  [⚙ Advanced: write your own]                           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Main panel — with active services

```
┌─ Share & Serve ─────────────────────────────────────────┐
│                                                         │
│  ┌─── Active ───────────────────────────────────────┐  │
│  │                                                  │  │
│  │  📺 Jellyfin                                    │  │
│  │     padkos.local:8096                            │  │
│  │     Running · 2 hours · auto-updates Sundays    │  │
│  │     [Open]  [Settings]  [Logs]  [Stop]          │  │
│  │                                                  │  │
│  │  🛡️  Pi-Hole                                    │  │
│  │     padkos.local                                 │  │
│  │     Running · 5 days · 4,392 ads blocked today  │  │
│  │     [Open]  [Settings]  [Logs]  [Stop]          │  │
│  │                                                  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌─── Add another ──────────────────────────────────┐  │
│  │  📁 Syncthing  🔐 Vaultwarden  📷 Immich  ...  │  │
│  │  [Browse all available services →]              │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Setup wizard — Jellyfin example, step 1: introduction

```
┌─ Set up Jellyfin ───────────────────────────────────────┐
│                                                         │
│  📺  Jellyfin                                           │
│                                                         │
│  Stream your movies, music, and photos to your TV,      │
│  phone, and other computers — all from your own         │
│  machine. No accounts, no subscription, no telemetry.  │
│                                                         │
│  We'll set up:                                          │
│                                                         │
│   ✓  Jellyfin server, auto-starting on boot            │
│   ✓  Network access from devices on your wifi          │
│   ✓  A friendly link you can share with family         │
│   ✓  Automatic updates                                  │
│                                                         │
│  Time to set up: about 1 minute.                        │
│  Disk space needed: ~250 MB (the server) + your media. │
│                                                         │
│                              [Cancel]  [Set it up →]    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Step 2: Storage chooser

```
┌─ Where's your media? ───────────────────────────────────┐
│                                                         │
│  📁  Pick the folder with your movies, music, and       │
│      photos. We'll show them in Jellyfin.               │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │ /home/elje/Media                    [Browse...]  │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  We don't move or change your files — Jellyfin just     │
│  reads from this folder.                                │
│                                                         │
│  We found:                                              │
│   ✓ 1,240 video files                                   │
│   ✓ 3,200 music files                                   │
│   ✓ 8,500 photos                                        │
│                                                         │
│  Looks good!                                            │
│                                                         │
│                              [Back]  [Next →]           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Step 3: Who can see it?

```
┌─ Who can see your Jellyfin? ────────────────────────────┐
│                                                         │
│  ◉  Just my computers on this wifi                      │
│      Recommended. Works for TVs, phones, laptops on    │
│      the same network. No outside access.              │
│                                                         │
│  ○  My computers anywhere via Tailscale                 │
│      Tailscale lets you reach your services from       │
│      anywhere, securely. Needs a free Tailscale       │
│      account — we'll walk you through it.              │
│      [What's Tailscale? →]                              │
│                                                         │
│  ○  Anyone on the internet                              │
│      ⚠  This makes Jellyfin reachable from anywhere.   │
│      Only do this if you understand what that means.   │
│      [What are the risks? →]                            │
│                                                         │
│                              [Back]  [Set it up →]      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Step 4: Setting up

```
┌─ Setting up Jellyfin... ────────────────────────────────┐
│                                                         │
│  ⏳ Pulling Jellyfin (123 MB)...     [████████] 100%    │
│  ✓  Setting up storage permissions                      │
│  ✓  Starting service                                    │
│  ✓  Opening port 8096                                   │
│  ✓  Broadcasting on your wifi                           │
│                                                         │
│  All done in 47 seconds!                                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Step 5: Done — share-it screen

```
┌─ Jellyfin is running! ──────────────────────────────────┐
│                                                         │
│  🎉                                                      │
│                                                         │
│  Your Jellyfin is at:                                   │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │  http://padkos.local:8096                         │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  [📋 Copy link]  [📱 Send to my phone (QR)]             │
│  [💬 Send to family chat]   [🌐 Open in browser]        │
│                                                         │
│  Tip: Open Jellyfin in your browser first to set up    │
│  your library. Then point your TV's Jellyfin app at    │
│  the link above.                                        │
│                                                         │
│                                            [Done]       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Service-stopped state (something went wrong)

```
┌─ Share & Serve ─────────────────────────────────────────┐
│                                                         │
│  ┌─── Something's wrong ────────────────────────────┐  │
│  │                                                  │  │
│  │  ⚠️  Jellyfin stopped 5 minutes ago              │  │
│  │                                                  │  │
│  │  The auto-update tried to install a new          │  │
│  │  version and the new version won't start.        │  │
│  │                                                  │  │
│  │  [↺ Roll back to last working version]           │  │
│  │  [📋 View logs]    [⚙ Edit settings]            │  │
│  │  [🗑 Remove Jellyfin]                            │  │
│  │                                                  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

This is the design principle in action: every problem has a friendly screen, plain-English description, and a recovery path that doesn't require terminal.

---

## Architecture

### Component diagram

```
       ┌──────────────────────┐
       │  Plasma KCM (QML)    │
       │  Share & Serve panel │
       └──────────┬───────────┘
                  │
                  │  D-Bus
                  ▼
       ┌──────────────────────┐
       │  share-and-serve     │      ┌────────────────────┐
       │  daemon (Python)     │◄────►│  Service catalog   │
       │                      │      │  (JSON / TOML)     │
       │                      │      └────────────────────┘
       └──────────┬───────────┘
                  │
                  ▼
   ┌──────────────────────────────┐
   │  Quadlet template renderer   │
   │  Avahi service file builder  │
   │  firewalld helper            │
   │  Tailscale integration       │
   └──────────────┬───────────────┘
                  │
        ┌─────────┴────────┬────────────────┐
        ▼                  ▼                ▼
 ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
 │  podman      │  │   avahi-     │  │  firewalld   │
 │  Quadlets    │  │  daemon      │  │              │
 │  /etc/...    │  │              │  │              │
 └──────────────┘  └──────────────┘  └──────────────┘
        │
        ▼
 ┌──────────────────────────────┐
 │  systemd                     │
 │   - container@<svc>.service  │
 │   - podman-auto-update.timer │
 └──────────────────────────────┘
```

### Filesystem layout

```
/usr/share/macrosofty/share-and-serve/
├── catalog.json                           # service catalog (curated, ships in image)
├── templates/
│   ├── jellyfin/
│   │   ├── jellyfin.container.tpl        # Quadlet template with placeholders
│   │   ├── avahi.service.tpl              # mDNS service template
│   │   ├── firewall.xml                   # firewalld service definition
│   │   ├── icon.svg                       # service icon
│   │   └── manifest.json                  # display name, description, defaults
│   ├── syncthing/
│   ├── pihole/
│   └── ...

/etc/containers/systemd/
├── jellyfin.container                     # rendered Quadlet (from template)
├── pihole.container
└── ...

/etc/avahi/services/
├── jellyfin.service                       # rendered mDNS broadcast
└── ...

~/.local/share/macrosofty/share-and-serve/
├── state.json                              # which services installed, their config
├── jellyfin/
│   └── config/                             # per-service config volume
└── ...

/usr/bin/macrosofty-share-and-serve         # CLI tool (also used by KCM via D-Bus)
```

### Quadlet template (Jellyfin example)

```ini
# /usr/share/macrosofty/share-and-serve/templates/jellyfin/jellyfin.container.tpl
[Unit]
Description=Jellyfin Media Server (Macrosofty Share & Serve)
After=network-online.target
Wants=network-online.target

[Container]
Image=docker.io/jellyfin/jellyfin:latest
ContainerName=jellyfin
PublishPort={{port}}:8096
Volume={{config_path}}:/config:Z
Volume={{cache_path}}:/cache:Z
Volume={{media_path}}:/media:ro,Z
AutoUpdate=registry
RemapUsers=keep-id
NoNewPrivileges=true
DropCapability=ALL

[Service]
Restart=on-failure
RestartSec=10s
TimeoutStartSec=900

[Install]
WantedBy=default.target
```

Variables (`{{...}}`) substituted by the daemon at install time from the wizard's choices and edition defaults.

### mDNS broadcast (Avahi)

```xml
<!-- /etc/avahi/services/jellyfin.service -->
<?xml version="1.0" standalone='no'?>
<service-group>
  <name replace-wildcards="yes">Jellyfin on %h</name>
  <service>
    <type>_http._tcp</type>
    <port>8096</port>
    <txt-record>path=/web/index.html</txt-record>
  </service>
</service-group>
```

Result: any phone or TV on the wifi sees "Jellyfin on padkos" without IP-typing.

### Firewall integration

```bash
# Add a port via firewalld (used by the daemon, not directly by the user)
firewall-cmd --permanent --add-port=8096/tcp --zone=public
firewall-cmd --reload
```

Per-service firewalld service definitions ship with templates — easier than adding bare ports because the rule has a name and can be cleanly removed.

### Update flow

```
[ podman-auto-update.timer ]   weekly
              ▼
[ podman auto-update ]
              ▼
For each Quadlet container with `AutoUpdate=registry`:
  - Pull latest image
  - Restart if image changed
              ▼
On failure:
  - Mark service as 'unhealthy' in state.json
  - KCM panel shows yellow indicator
  - User notified via Plasma notification
              ▼
User clicks "roll back" in panel:
  - daemon runs `podman tag <prev_id> <image>:latest`
  - restart service
  - if still broken: offer "Reinstall fresh" flow
```

### CLI counterpart

Every action in the GUI must be doable from the CLI for power users and scripting:

```bash
macrosofty-share-and-serve list
macrosofty-share-and-serve install jellyfin --media-path ~/Movies
macrosofty-share-and-serve stop jellyfin
macrosofty-share-and-serve remove jellyfin
macrosofty-share-and-serve logs jellyfin --follow
macrosofty-share-and-serve update jellyfin
```

---

## Service catalog (v1)

Ten services for v1. Each curated, each tested, each with a Quadlet template + setup wizard.

| Service | Image | Purpose | Default port | Storage shape | Wizard complexity |
|---|---|---|---|---|---|
| **Jellyfin** | `docker.io/jellyfin/jellyfin` | Media server | 8096 | RO media, RW config | Low — pick media folder |
| **Syncthing** | `docker.io/syncthing/syncthing` | File sync between devices | 8384 (UI) + 22000 (sync) | RW chosen folder | Low — pick sync folder |
| **Pi-Hole** | `docker.io/pihole/pihole` | DNS-level ad blocking | 80 (UI) + 53 (DNS) | RW config | Medium — DNS conflict warning |
| **Vaultwarden** | `docker.io/vaultwarden/server` | Password manager (Bitwarden-compatible) | 80 | RW data | Low — set admin token |
| **Immich** | `ghcr.io/immich-app/immich-server` | Photos, like Google Photos | 2283 | RW chosen folder | Medium — needs DB container too |
| **HomeAssistant** | `docker.io/homeassistant/home-assistant` | Smart home dashboard | 8123 | RW config | Low |
| **Audiobookshelf** | `ghcr.io/advplyr/audiobookshelf` | Audiobooks + podcasts | 13378 | RO library, RW config | Low — pick library folder |
| **Nextcloud-AIO** | `docker.io/nextcloud/all-in-one` | Cloud storage / calendar / contacts | 443 | RW data | Higher — multi-container, TLS |
| **Navidrome** | `docker.io/deluan/navidrome` | Music streaming (Spotify-shaped self-host) | 4533 | RO library, RW config | Low — pick music folder |
| **Mealie** | `ghcr.io/mealie-recipes/mealie` | Recipe manager | 9000 | RW data | Trivial |

**Selection criteria for v1:**
- Self-hosting community-popular (active development, decent docs, strong community)
- Single primary container (multi-container ones like Nextcloud get the wizard hand-walking through both)
- Useful to the four personas
- No funky requirements (no GPU passthrough, no host-network mode, no privileged containers)

**Future additions** (post-v1, by demand):
- Plex (proprietary, but lots of users want it)
- Emby (alternative to Jellyfin/Plex)
- Calibre-web (ebooks)
- Photoprism (alternative to Immich)
- Bitwarden official (vs. Vaultwarden)
- Frigate (NVR for security cameras)
- WireGuard (VPN endpoint)
- Caddy / NPM (reverse proxy for users running multiple services on port 80)

---

## Edge cases and risks

### Storage

- **User picks a folder that's already a service's data dir** → warn before installing.
- **User picks a folder on a removable drive** → warn that the service will fail when the drive is unplugged. Offer to copy data to internal disk.
- **Folder permissions wrong** → daemon fixes them automatically (sets correct UID/GID + SELinux relabel) with user consent.
- **Disk fills up mid-pull** → daemon checks free space before initiating pull; warns at 80% capacity post-install.

### Network

- **Port already in use** by system service (e.g., Pi-Hole wants port 53, but systemd-resolved owns it on most modern systems) → daemon detects and either offers an alternate port OR walks user through disabling systemd-resolved (for Pi-Hole specifically).
- **mDNS doesn't work on this network** (some routers, public wifi) → fall back to showing IP address.
- **Multiple services compete for port 80** (Pi-Hole, Vaultwarden, Nextcloud) → port-assignment helper. Recommend reverse proxy (#future).
- **User on double-NAT or CGNAT** (common in SA) → Tailscale option shines here.

### Update / lifecycle

- **Auto-update breaks a service** → systemd `Restart=on-failure` retries; if persistent, panel shows "stopped" with rollback option. State file remembers last-known-good image digest.
- **Image registry rate-limit hit** during update → daemon backs off, retries later, doesn't block UI.
- **Service crashes for non-update reason** (corrupt data, OOM) → "Something's wrong" screen + logs link.

### Security

- **Service exposed to internet by user** → setup wizard's "Anyone on the internet" option includes a stark warning + link to risk explanation. Default is LAN-only.
- **Container escape** (theoretical) → all services run rootless where possible. `NoNewPrivileges=true`, `DropCapability=ALL` baseline.
- **Vulnerability in a service** → auto-updates pull patches. If a CVE is critical, panel can show a banner "Jellyfin update available — recommended now".

### Disk hygiene

- **Old container images pile up** → weekly `podman image prune` via systemd timer.
- **User removes a service** → "delete the data folder too?" prompt. Default: keep data (safer). User can opt-in to nuke.

### Cross-edition

- **Padkos audience runs out of RAM** with multiple heavy services → soft warning at 2 services on 4-GB-RAM machines: "Padkos is best with 1–2 services running. Want to stop one before starting another?"
- **Braai (Bazzite) user** runs gaming + Jellyfin → Bazzite already does gamescope niceties; should be fine.

---

## Implementation phases

### Phase 0: Planning (this document, complete)

### Phase 1: Technical foundation (~1 month)

Goal: validate the underlying mechanism with no UI.

- Quadlet templates for **3 services**: Jellyfin, Syncthing, Pi-Hole.
- A `macrosofty-share-and-serve` CLI tool: `install`, `stop`, `start`, `remove`, `logs`, `update`.
- Manual storage / port selection (no auto-detection yet).
- mDNS broadcast working.
- firewalld integration working.
- Manual testing on Hearty + Padkos in QEMU.

**Exit criterion:** From a fresh Hearty install, run `macrosofty-share-and-serve install jellyfin --media-path ~/Movies` and access Jellyfin at `hostname.local:8096` from a phone within the same wifi.

### Phase 2: GUI v1 (~2 months)

Goal: the panel + wizard for the 10-service catalog.

- KCM panel in QML (Plasma 6).
- D-Bus interface from KCM to daemon.
- Service catalog browser.
- Setup wizard with the 5-step flow shown above (intro → storage → access → install → done).
- "Active services" view with start/stop/logs/settings.
- "Something's wrong" recovery flow.
- All 10 catalog services tested.

**Exit criterion:** A non-technical user can install Jellyfin from the panel in under 90 seconds without typing anything more than the storage path.

### Phase 3: Polish (~1 month)

Goal: production-ready.

- Tailscale integration (one-click "share via Tailscale").
- Cloudflare Tunnel integration (one-click "share with the internet, safely").
- "Send to my phone" QR code generator.
- "Send to family chat" deep-link to messaging apps.
- Update notifications via Plasma notification daemon.
- Service-specific tweaks (e.g., Pi-Hole's DNS-conflict resolver).
- Localisation for the wizard text.

**Exit criterion:** Ship as part of v0.4 release.

### Phase 4: Community catalog (~ongoing)

Goal: let trusted community members add services.

- Template-spec format documented.
- PR-driven catalog updates with template review.
- Versioning of templates.
- "Beta" tag for newly-added services.

---

## Open questions

These need answers before Phase 1 starts.

1. **Rootless or rootful Quadlets?** Rootless is more secure (container can't escalate to root), but storage permissions get fiddlier (need user-namespace mapping). Rootful is simpler but each container effectively has root if escaped.
   - *Lean:* rootless by default; advanced mode allows rootful for services that genuinely need it (e.g., Pi-Hole binding to port 53).
2. **mDNS hostname** — depends on `/etc/hostname` being correct. We've fixed that for v0.1 (commit `3d3819e`); confirm it persists through this work.
3. **Update cadence** — weekly auto-update is reasonable; some services advise more frequent checks for security. Make it per-service configurable?
   - *Lean:* weekly default; user can change in service settings.
4. **Backup integration** — when service has data, do we offer to back it up via the future #13 backup wizard? Should the data folder be automatically included in user backups?
   - *Lean:* yes — the daemon registers service data folders with whatever backup is configured (DejaDup or future Macrosofty backup). Default-include with user consent.
5. **Network conflict resolution** — Pi-Hole vs systemd-resolved is the obvious one. How aggressive should our resolver be? Fully automated, or always prompt?
   - *Lean:* prompt with sensible default (e.g., "Pi-Hole needs port 53; we can disable systemd-resolved for you. This is reversible. OK?").
6. **Cross-edition behaviour** — should Padkos limit concurrent services, or just warn? Should Braai's gamescope mode pause services to free RAM?
   - *Lean:* warnings, not limits. User decides.
7. **Naming** — "Share & Serve" works in English. Is there a Mzansi/Afrikaans alt for the SA edition?
   - *Brainstorm:* "Aansit" (switch on), "Deel" (share), "Bedien" (serve). "Share & Serve" stays in English globally for clarity.
8. **Catalog updates** — when the v1 ships and we add 5 more services later, do they reach existing users via OS update or via Discover-shaped "catalog refresh"?
   - *Lean:* both. Catalog metadata in /usr/share is updated via OS update (atomic). Templates can additionally be refreshed via a "check for new services" button.

---

## Appendix

### A. Reference docs

- Podman Quadlet: https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html
- Avahi service file format: https://www.avahi.org/doxygen/html/avahi-services.html
- firewalld services: https://firewalld.org/documentation/man-pages/firewalld.service.html
- Tailscale Linux client: https://tailscale.com/kb/1031/install-linux
- Cloudflare Tunnel: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/

### B. Inspiration / prior art

- **CasaOS** — closest existing equivalent (homelab-flavoured, not desktop-first). Worth studying for catalog UX.
- **TrueCharts / TrueNAS Apps** — service catalog model on a NAS.
- **Yunohost** — self-hosting on Debian; mature but less polished than what we'd target.
- **HomeAssistant Add-Ons** — integrated catalog within HA. Conceptually close to what we want.
- **Synology DSM Package Center** — the gold standard for "make hosting things friendly". Worth deep-diving.

### C. Mzansi flavour notes

- Tailscale integration is especially valuable for SA users dealing with intermittent connectivity, double-NAT (CGNAT is increasingly common), and dynamic IPs. Worth highlighting in marketing.
- Load-shedding awareness (#29 in the value-adds roadmap) intersects: services should know to expect interruptions and recover gracefully. Future iteration could add "graceful shutdown 5 min before scheduled load shedding" via the SA-specific load-shedding API.
- Catalog can include Mzansi-relevant services (e.g., a self-hosted copy of community-favourite SA services if any FOSS equivalents exist).

### D. Out-of-scope but interesting

These are NOT in v1 but worth noting for future consideration:

- **A "deploy to my home server" mode** that lets a Macrosofty laptop control services on a different Macrosofty machine on the same network (federated Share & Serve). Real complexity, real value.
- **Service marketplace with paid options** — allow trusted community-contributed services to be paid-for if they involve real labour. Requires payment infrastructure; against the "love project" ethos for now.
- **Automated reverse proxy** — when 2+ services exist on port 80, auto-configure a Caddy reverse proxy with subdomains. Real value, real fragility.
- **Time-machine for service data** — atomic snapshots of service data folders, browsable in the panel. Pairs with Macrosofty's atomic-update story but for application data.

---

This proposal is open to revision. Edits welcome via PR; please update the "Last updated" date and the version history at the bottom when changing meaningfully.

## Version history

- **2026-04-26 (v0):** initial proposal drafted from conversation between founder and Claude. Roadmap entry #39.
