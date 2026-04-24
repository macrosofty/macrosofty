# CLAUDE.md — Macrosofty

## What this project is

Macrosofty is a Linux distribution aimed at **ordinary people who want a computer that respects them**. It's built on **Universal Blue + Fedora atomic desktop** (the same lineage Bazzite, Bluefin, and Aurora come from). The value proposition isn't new engineering — it's **curation, branding, and a friendly face** on top of an already-solved "atomic Linux that doesn't break" foundation.

The project is at **pre-scaffold stage** (as of 2026-04-24). No code has been written. This repository currently holds:
- `VISION.md` — the product/marketing/editions document (the "what" and "who for")
- `CLAUDE.md` — this file (the "how we work on it")

Upcoming work (not yet done): fork `ublue-os/image-template`, set up Containerfiles per edition, GitHub Actions builds, a website, branding assets.

## The voice and the metaphor

**Macrosofty never names the competitor.** Instead we use the **door metaphor** consistently:

- Our rival has **windows** — you can look through but you can't walk through. You see your files but you don't really own them.
- Macrosofty is a **door** — you walk through, you're on the other side, the house is yours.
- Our tagline: *"We open the door — not just a window to peek through."*
- The rival company/OS is referred to obliquely as "the one with the windows," "the door company that only sells windows," or just elided entirely.
- In-product copy, docs, marketing, and code comments should all maintain this. **Never write "Microsoft" or "Windows" in user-facing text.** The joke works because it's never spelled out.

The tone is **dry, friendly, self-aware, never mean**. Think Linux Mint's warmth + Steam Deck's confidence + a knowing wink about the fact that computing shouldn't be this hard.

## Core principles (these constrain every decision)

1. **Atomic first, always.** If a decision compromises the "doesn't break" property, the decision is wrong.
2. **Decisions over choices.** We ship opinions. Users can override, but the defaults are curated on purpose.
3. **No ads, no nags, no telemetry, no accounts required.** Ever. This is a load-bearing promise.
4. **Inherit upstream work ruthlessly.** Universal Blue, Fedora, and Flatpak do the hard lifting. We layer curation, not rewrites.
5. **Four editions, one identity.** Hearty, Chunky, Broth, Feast all feel like Macrosofty. No edition is visually a different OS.
6. **Conversion-friendly copy.** Landing pages and docs are written for the Windows-tired person who stumbled in from a blog post — not for Linux nerds. Nerds find us on their own.

## The four editions (full definitions in `VISION.md`)

| Edition | Persona | Upstream base to fork |
|---|---|---|
| **Hearty** | Everyday user, non-technical | `ublue-os/bluefin` (GNOME) or `aurora` (KDE) |
| **Chunky** | Power user, knowledge worker, light dev | `bluefin-dx` or `aurora-dx` |
| **Broth** | Older hardware, 4 GB RAM machines | Minimal base, stripped |
| **Feast** | Gamers | `ublue-os/bazzite` |

## Repository layout (proposed, not yet built)

```
macrosofty/
├── README.md                     (public-facing 1-pager)
├── VISION.md                     (product/marketing/editions)
├── CLAUDE.md                     (this file)
├── editions/
│   ├── hearty/Containerfile
│   ├── chunky/Containerfile
│   ├── broth/Containerfile
│   └── feast/Containerfile
├── system_files/                 (shared configs, systemd units, firstboot)
│   └── shared/
├── branding/                     (logo SVG, wallpapers, plymouth theme, icon set)
├── website/                      (static site — landing page, edition pages, FAQ)
├── .github/workflows/
│   ├── build.yml                 (per-edition OCI + ISO builds → ghcr.io)
│   └── website.yml               (deploy website on push)
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
| ISO generation | `bootc-image-builder` | Official tool, actively maintained |
| **ISO hosting** | **SourceForge** | Free, mirrored worldwide, no bandwidth cost. Honest SF reputation caveat addressed in the FAQ. |
| Website | Astro + Tailwind on Cloudflare Pages | Free tier sufficient, no tracking |
| License | Apache 2.0 | Matches Universal Blue upstream |
| **Desktop environment** | **KDE Plasma** (all editions) | Identity cohesion; Windows-familiar layout lowers newcomer friction |
| **Image signing** | `cosign` + GitHub OIDC (keyless) | No long-lived keys; matches Universal Blue practice |
| **Support channel** | GitHub Discussions | Zero infra, searchable, low moderation burden |
| **Funding posture** | Love project; GitHub Sponsors optional; runs at a loss until it can't | No ads/accounts/telemetry; clear wind-down clause |
| GitHub org | TBD (placeholder: `macrosofty` or `macrosofty-os`) | |

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
- Don't commit without explicit instruction (same as other projects).

## Who the audience is (really)

Not "everyone." Not "Linux enthusiasts." Specifically:

1. **The Windows-fatigued person** who's been told by a friend "there's this thing called Linux, it's not scary anymore." They'll give it 15 minutes before they decide. The install-and-first-boot experience is the whole sale.
2. **The relative-supporter** — the technical person in a family who sets up their parents' / partner's / sibling's computer and wants a version that won't need support calls. They choose what goes on non-technical machines.
3. **The hardware recycler** — has an old laptop, doesn't want to throw it away, doesn't want to buy a new one just because the current OS dropped support.
4. **The gamer who's tired of Windows telemetry** — already curious about SteamOS/Bazzite, but wants a friendlier on-ramp.

We are **not** optimising for the Arch user, the NixOS power-user, the minimalist who wants to `./configure && make && make install` their own kernel. They're not our customer. That's fine.

## Related context

- This project spun out of a homelab session (2026-04-24). The home-lab repo (`/mnt/code/homelab`) is unrelated — that's infrastructure, Proxmox, Immich, Jellyfin, etc. Keep this project separate.
- The user runs Bazzite (VM 105 on pve1) as his daily driver, so he has firsthand experience with the "atomic + curated" model.
- No code has been written for Macrosofty yet. Treat this repo as a brief for the engineer/agent who scaffolds it.

## Next steps (for whoever picks this up)

1. **Name & org** — lock in domain, GitHub org name (`macrosofty` / `macrosofty-os`), trademark sanity check.
2. **Fork `ublue-os/image-template`** as the starting skeleton.
3. **Rename, strip, restructure** per the layout in this doc.
4. **Build Hearty first** (the canary) — minimal `editions/hearty/Containerfile` targeting KDE base. If it boots and installs cleanly, the other three follow.
5. **Wire up GitHub Actions**:
   - Build + push to `ghcr.io/macrosofty/hearty:latest`
   - Sign with cosign keyless (OIDC)
   - Build ISO with `bootc-image-builder`
   - Upload ISO to SourceForge via `sshpass`/`rsync`
6. **Test install in a VM** — confirm boot, firstboot wizard, rollback.
7. **Iterate on branding, firstboot, app curation** (see `editions/app-curation.md`) before opening to outside users.
8. **Copy the boilerplate** (`CODE_OF_CONDUCT.md`, `SECURITY.md`, `CONTRIBUTING.md`, `SIGNING.md`, `ATTRIBUTION.md`) and replace placeholder email/TLD with real contact.
9. **Build the website last** — landing page flow already drafted in `VISION.md`. No point marketing what doesn't yet exist.
10. **Soft launch** — announce in GitHub Discussions first, then a single r/linux or lobste.rs post. Prepare for feedback; don't promise timelines.
