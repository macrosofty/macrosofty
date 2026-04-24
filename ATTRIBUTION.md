# Attribution

Macrosofty exists because other people did the hard work first. This is the full list of upstream projects we stand on, with gratitude.

## Direct foundations

### Fedora Project
- **What:** The base operating system, atomic desktop variants, and the package ecosystem.
- **License:** Various (MIT, Apache 2.0, GPL, LGPL, etc. — see individual packages)
- **Home:** https://fedoraproject.org
- **Trademark note:** We describe Macrosofty as "built on Fedora Atomic Desktops" — a descriptive use permitted by Fedora's Trademark Guidelines. We do not use Fedora's logo or claim endorsement.

### Universal Blue
- **What:** The image-build system and atomic desktop remixes that Macrosofty forks from.
- **License:** Apache 2.0
- **Home:** https://universal-blue.org
- **Trademark note:** We describe Macrosofty as "a Universal Blue project" where appropriate. We don't use their logo on our product or website without permission.

### Project Bluefin
- **What:** The base for Macrosofty Hearty and Chunky (via Bluefin-DX). GNOME-focused upstream, but we remix to KDE.
- **License:** Apache 2.0
- **Home:** https://projectbluefin.io
- **Gratitude:** The Bluefin team's polish work on desktop ergonomics is the reason Hearty feels good out of the box.

### Bazzite
- **What:** The base for Macrosofty Feast. Gaming-tuned atomic Fedora.
- **License:** Apache 2.0
- **Home:** https://bazzite.gg
- **Gratitude:** The Bazzite team has spent years solving every "why doesn't Proton work with my controller" edge case. Feast is, frankly, their hard work with our branding on top.

### KDE Plasma
- **What:** The desktop environment we ship on all editions.
- **License:** Various (primarily LGPL)
- **Home:** https://kde.org

### Flatpak & Flathub
- **What:** The primary app distribution mechanism for Macrosofty.
- **License:** LGPL (Flatpak), mixed (Flathub apps)
- **Home:** https://flatpak.org, https://flathub.org

### rpm-ostree / bootc
- **What:** The atomic update mechanism that makes Macrosofty's "won't break" promise real.
- **License:** LGPL-2.1+ / Apache 2.0
- **Home:** https://coreos.github.io/rpm-ostree/, https://bootc-dev.github.io/bootc/

### Sigstore / cosign
- **What:** The keyless signing that secures Macrosofty's supply chain.
- **License:** Apache 2.0
- **Home:** https://www.sigstore.dev

## Gaming stack (Feast edition)

All of the following are bundled via Bazzite's upstream work:

- **Steam & Proton** — Valve. https://partner.steamgames.com/doc/steamdeck/loggingin
- **Proton-GE** — Glorious Eggroll. https://github.com/GloriousEggroll/proton-ge-custom
- **Lutris** — https://lutris.net
- **Heroic Games Launcher** — https://heroicgameslauncher.com
- **Bottles** — https://usebottles.com
- **Gamescope** — Valve. https://github.com/ValveSoftware/gamescope
- **MangoHud** — https://github.com/flightlessmango/MangoHud

## Tooling

- **Astro** (website) — https://astro.build, MIT
- **Tailwind CSS** (website) — https://tailwindcss.com, MIT
- **GitHub Actions** (CI/CD) — GitHub
- **Cloudflare Pages** (website hosting) — Cloudflare
- **SourceForge** (ISO hosting) — Slashdot Media

## License

Macrosofty's own code (Containerfiles, build scripts, website, docs) is licensed under **Apache 2.0**. Upstream components retain their own licenses.

## How to credit us

You don't have to. Apache 2.0 requires preserving the license and attribution notices — that's all. But if you want to: "Macrosofty is a Universal Blue remix" works.

## If we've missed you

Open an issue or PR. We aim to credit every project whose work shows up in Macrosofty.
