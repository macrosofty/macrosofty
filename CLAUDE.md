# CLAUDE.md — Macrosofty

## What this project is

Macrosofty is a Linux distribution aimed at **ordinary people who want a computer that respects them**. It's built on **Universal Blue + Fedora atomic desktop** (the same lineage Bazzite, Bluefin, and Aurora come from). The value proposition isn't new engineering — it's **curation, branding, and a friendly face** on top of an already-solved "atomic Linux that doesn't break" foundation.

This repository holds the distro source — Containerfiles, build pipeline, system configs, branding assets, signed-ISO publishing workflows. The marketing site is maintained in a separate repository because the brand/voice/visual implementation is property, not Apache-2.0 code. The voice rules in this `CLAUDE.md` and `VISION.md` are the source of truth for tone — the website renders that voice; it doesn't define it.

## The voice and the metaphor

**Macrosofty never names the competitor.** Instead we use the **door metaphor** consistently:

- Our rival has **windows** — you can look through but you can't walk through. You see your files but you don't really own them.
- Macrosofty is a **door** — you walk through, you're on the other side, the house is yours.
- Primary tagline: *"We open the door — not just a window to peek through."*
- The rival company/OS is referred to obliquely as "the one with the windows," "the door company that only sells windows," or just elided entirely.
- In-product copy, docs, marketing, and code comments should all maintain this. **Never write "Microsoft" or "Windows" in user-facing text.** The joke works because it's never spelled out.

**The name itself is a second layer of joke:** `macro` = big, `softy` = easy. Big and easy. It also parodies the rival's name. **We never explain either joke** — both work because readers spot them unassisted.

### Supporting taglines (use these verbatim or in spirit)

- **"A Linux that doesn't suck."** — headline.
- **"Free for everyone. Forever."** — used as a promise chip and repeating closing line.
- **"Peace, not war."** — our stance toward the rival. We're an alternative, not a protest.
- **"Become a Macrosofty."** — affectionate self-ID for users.
- **"Lekker at a braai · not locked at a boardroom."** — voice reference (South African colloquial).
- **"Explained at a braai, not in a board meeting."** — docs / reply style.
- **"Made with lekker in Mzansi."** — footer attribution.

Drop SA colloquialisms (*lekker*, *howzit*, *bru*, *boet*, *braai*, *tjops*, *Mzansi*) sparingly — once per section at most. They're flavour, not decoration. Never force them into every paragraph.

### Stance (how we argue, how we don't)

- **We make peace, not war.** If someone's current OS works for them — great, enjoy. We're not here to convert, shame, or lecture.
- **We don't bash the rival by name.** The absence IS the joke.
- **We're a love project, not a crusade.** No telemetry to boast about removing, because there was never any to add. No premium tier to brag about refusing, because there was never going to be one.

The overall tone is **dry, friendly, self-aware, never mean**. Think Linux Mint's warmth + Steam Deck's confidence + a knowing wink about the fact that computing shouldn't be this hard. The braai-side braver, not the boardroom presenter.

## Core principles (these constrain every decision)

1. **Atomic first, always.** If a decision compromises the "doesn't break" property, the decision is wrong.
2. **Decisions over choices.** We ship opinions. Users can override, but the defaults are curated on purpose.
3. **No ads, no nags, no telemetry, no accounts required.** Ever. This is a load-bearing promise.
4. **Inherit upstream work ruthlessly.** Universal Blue, Fedora, and Flatpak do the hard lifting. We layer curation, not rewrites.
5. **Four editions, one identity.** Hearty, Chunky, Padkos, Braai all feel like Macrosofty. No edition is visually a different OS.
6. **Conversion-friendly copy.** Landing pages and docs are written for the Windows-tired person who stumbled in from a blog post — not for Linux nerds. Nerds find us on their own.
7. **The system is opinionated. The desktop is yours.** Customisation (wallpaper, colour palette, cursor size, text size, icon pack) is a *first-class, one-click* experience — not a rabbit-hole of config files. We handle the plumbing; users handle the paint. The nerd levers (KDE global themes, Konsave, Kvantum, .desktop files) stay accessible — they're just not required. A user should be able to make everything pink and put their doggy on the wallpaper without ever reading a manual.

## The four editions (full definitions in `VISION.md`) + one tentative

| Edition | Persona | Arch | Upstream base to fork | Status |
|---|---|---|---|---|
| 🍲 **Hearty** | Everyday user, non-technical | x86-64 | `ublue-os/aurora` (KDE) | v1 |
| 🍖 **Chunky** | Power user, knowledge worker, light dev | x86-64 | `aurora-dx` | v1 |
| 🧺 **Padkos** | Older hardware + offline-first day 1 | x86-64 | `ublue-os/aurora` + Firefox/LO RPMs | v1 |
| 🔥 **Braai** | Gamers | x86-64-v3 | `ublue-os/bazzite` | v1 |
| 🐰 **Bokkie** | Pi 5 / Rockchip / ARM SBCs | aarch64 | Fedora Kinoite aarch64 (skip UBlue for ARM — they're x86-only today) | **tentative · post-v1** |

**Bokkie never includes Braai functionality** — Steam / Proton / Wine are x86-native and do not work reliably on ARM translators. If someone asks for ARM gaming, the honest answer is "no, not fixable by us."

## Repository layout

```
macrosofty/
├── README.md                     (public-facing 1-pager)
├── VISION.md                     (product/marketing/editions)
├── CLAUDE.md                     (this file)
├── editions/
│   ├── hearty/Containerfile
│   ├── chunky/Containerfile
│   ├── padkos/Containerfile
│   └── braai/Containerfile
├── system_files/                 (shared configs, systemd units, firstboot)
│   └── shared/
├── branding/                     (logo SVG, wallpapers, plymouth theme, icon set)
├── scripts/                      (build helpers, branding regen, AHT bundler)
├── config/identity.env           (centralised brand identity + pinned versions)
├── .github/workflows/            (per-edition OCI + ISO builds → ghcr.io)
└── docs/
    ├── install.md
    ├── upgrades.md
    └── troubleshooting.md
```

## Tech stack decisions

| Layer | Choice | Why |
|---|---|---|
| Base image | Universal Blue (Fedora atomic) | Only production-ready atomic desktop; inherits years of polish |
| Build | Containerfile + GitHub Actions | Cross-platform, free CI, cached layers |
| Image registry | `ghcr.io/macrosofty/*` | Free, unlimited pulls, standard in this ecosystem |
| ISO generation | `bootc-image-builder` / `jasonn3/build-container-installer` | Official tools, actively maintained |
| ISO hosting | SourceForge | Free, mirrored worldwide, no bandwidth cost |
| Website | Astro 5.x + Tailwind 3.x on Cloudflare Pages | Free tier sufficient, no tracking |
| License | Apache 2.0 | Matches Universal Blue upstream |
| **Desktop environment** | **KDE Plasma** (all editions) | Identity cohesion; Windows-familiar layout lowers newcomer friction |
| Image signing | `cosign` + GitHub OIDC (keyless) | No long-lived keys; matches Universal Blue practice |
| Support channel | GitHub Discussions | Zero infra, searchable, low moderation burden |
| Funding posture | Love project; GitHub Sponsors optional; runs at a loss until it can't | No ads/accounts/telemetry; clear wind-down clause |
| GitHub org | `github.com/macrosofty` | |
| Primary domain | `macrosofty.org` | Canonical; `.com`, `.co.za`, `.org.za` redirect to `.org` |

## What you (Claude) should and shouldn't do in this repo

### Should
- **Keep the door metaphor alive** everywhere. If a piece of copy references "Windows" directly, rewrite it into door language.
- **Inherit, don't reinvent.** When designing something, the first question is "what does Bluefin/Bazzite/Aurora already do, and should we just use that?"
- **Push back on scope creep.** If someone proposes a 5th edition, or a rewrite of the build tool, or custom kernel work — ask whether upstream solves it, ask whether this is the fight worth picking.
- **Default to short, punchy, honest copy** in user-facing text. No corporate voice, no filler. If a sentence doesn't earn its place, delete it.
- **Flag tradeoffs, not just choices.** When making a decision, say what we're giving up.

### Shouldn't
- Don't invent features that upstream Universal Blue doesn't support. If something needs a custom rpm-ostree fork, that's a red flag.
- Don't write corporate-speak or pseudo-marketing prose. If it sounds like an RFP response, it's wrong.
- Don't make the "door vs window" joke explicit in docs by saying "this is a joke about Microsoft." The joke works *because* it's never spelled out.
- Don't treat this as urgent. There's no deadline, no user base yet. Quality over speed.
- Don't commit without explicit instruction.

## Who the audience is (really)

Not "everyone." Not "Linux enthusiasts." Specifically:

1. **The Windows-fatigued person** who's been told by a friend "there's this thing called Linux, it's not scary anymore." They'll give it 15 minutes before they decide. The install-and-first-boot experience is the whole sale.
2. **The relative-supporter** — the technical person in a family who sets up their parents' / partner's / sibling's computer and wants a version that won't need support calls. They choose what goes on non-technical machines.
3. **The hardware recycler** — has an old laptop, doesn't want to throw it away, doesn't want to buy a new one just because the current OS dropped support.
4. **The gamer who's tired of Windows telemetry** — already curious about SteamOS/Bazzite, but wants a friendlier on-ramp.

We are **not** optimising for the Arch user, the NixOS power-user, the minimalist who wants to `./configure && make && make install` their own kernel. They're not our customer. That's fine.

## Roadmap

In rough dependency order:

1. **Fork `ublue-os/image-template`** as the starting skeleton for the build pipeline.
2. **Four edition Containerfiles** under `editions/{hearty,chunky,padkos,braai}/`.
3. **Hearty as canary**: if it boots and installs cleanly in a VM, the other three follow the same shape.
4. **GitHub Actions:** OCI build + cosign keyless sign → `ghcr.io/macrosofty/<edition>:latest` → `bootc-image-builder` ISO → rsync to SourceForge.
5. **Branding pipeline** (Plymouth, GRUB, wallpapers, favicon, hostname, MOTD, Anaconda product, `/etc/*-release`) — centralised in `config/identity.env`, applied per-edition during build.
6. **"Make it yours" app** (Qt/Kirigami) — curated one-click palettes, wallpaper upload, cursor/text-size, icon packs. The unique shipping thing that differentiates Macrosofty from Bluefin/Aurora. Target: v0.3.
7. **Soft launch** — announce in GitHub Discussions first, then a single `r/linux` or `lobste.rs` post. No timelines, no promises.
8. **Later / tentative:** Bokkie (ARM) edition, Afrikaans localisation, second DE variant (GNOME).
