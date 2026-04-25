# Macrosofty — Vision & Brief

*For the engineer (or agent) scaffolding this project.*

## The elevator pitch

**Macrosofty is a Linux that doesn't suck.**

No ads. No accounts. No nonsense. Just a computer that respects you.

**Our line:** *"We open the door — not just a window to peek through."*

## Why we exist

Personal computing has got worse every year for about a decade on the dominant desktop OS. Ads in the start menu, forced updates that reboot you mid-work, telemetry that watches what you do, "upgrades" that remove features you rely on, subscriptions for things that used to be one-time purchases, and a slow erosion of the idea that your computer belongs to you.

Linux has been the escape route for a long time, but the price of entry has been:
- Picking a distro out of 300 of them
- Understanding atomic vs mutable vs rolling vs stable
- Configuring drivers, codecs, apps
- Dealing with things breaking when you update
- Explaining "sudo" to your mom

**Macrosofty removes the cost of that escape.** It's curated, opinionated, and built so the "didn't break" property is architectural, not hopeful.

## The door, not the window

Throughout the product, the site, and every piece of copy — **we never name the competitor.** We use the door metaphor instead:

> A window lets you look through, but you can't walk through it. You can see your files, but the system is locked from the other side. You're a guest in your own computer.
>
> A door opens. You walk through. The house is yours.

The rival is referred to obliquely:
- "The one with the windows"
- "The door company that only sells windows"
- "A certain operating system that shall remain unnamed"
- Or simply not mentioned — the absence is the joke

This is a **load-bearing design decision**. Never spell out the joke. It's funny because everyone gets it without us saying so. Writing "this is a joke about Microsoft" in a FAQ or README immediately kills it.

## Who Macrosofty is for

We're not trying to convert the Arch crowd. They're fine. We're here for:

1. **The Windows-tired person** — "My computer has ads now. There must be a better way."
2. **The relative-supporter** — the one person in the family who sets up everyone else's machine
3. **The hardware recycler** — "I have a perfectly good 2017 laptop and the current OS won't support it anymore"
4. **The gamer who's tired of telemetry** — already curious about SteamOS, wants a friendly on-ramp

The "figuring out which Linux to pick" step is the biggest conversion barrier. Macrosofty answers that by being the recommendation.

## The four editions

We ship four editions, all built from the same pipeline, sharing identity and branding. Food names because — well, Macrosofty. The names do the memorable branding; the corporate parody lives in the descriptions (playing on the old Basic/Pro/Essentials/Ultimate naming pattern without naming the source).

### 🍲 Macrosofty Hearty
**For the person who just wants it to work.**

The everyday edition. Browser, email, photos, video calls, Netflix, printing, messaging. All there on first boot. No terminal. No jargon. If this is going on your mom's laptop, this is the one.

*Inside, a tag the door company would have called "Basic" and charged you for.*

### 🍖 Macrosofty Chunky
**For the person who does real work on it.**

Everything Hearty has, plus a full office suite, PDF editing that actually edits, better file management, developer tools if you want them, and a little more muscle behind the scenes. Runs well on anything made in the last 8 years.

*The one the door company would have called "Pro" and hidden behind a paywall.*

### 🥣 Macrosofty Broth
**For reviving an older machine.**

Boots fast on 4 GB of RAM. Does browsing, documents, email, video. Gets out of the way. Perfect for a second PC, an old Thinkpad, a family member who just needs "the internet computer."

*The edition the door company would have called "Essentials" and quietly retired after two years.*

### 🍷 Macrosofty Feast
**For players.**

Steam, Proton, Lutris, Heroic, Bottles — pre-configured and kept current. Controllers plug in and work. Games from Steam, Epic, GOG, Battle.net, and classic discs run. Low-latency kernel. No driver archaeology.

Built on Bazzite's work — we owe them a beer.

*The "Ultimate" edition. Slapped with a gamer skin by the door company, sold as a premium tier. Here, it's just the fourth download button.*

### 🐰 Macrosofty Bokkie — **tentative, post-v1**
**For ARM machines: Pi 5, Rockchip SBCs, ARM laptops.**

Fedora Kinoite already runs beautifully on aarch64 hardware. Bokkie would be a minimal Hearty/Broth-equivalent edition for people giving their old Pi 5 or Rockchip board a second life.

**Not shipping in v1.** Three honest reasons:
1. Our Universal Blue inheritance path (Bluefin / Aurora / Bazzite) is x86-64 only today. A Bokkie would have to fork Fedora Kinoite directly — more of our own plumbing, less inherited.
2. We want the four x86 editions stable first.
3. Bokkie will **never** include Feast. Steam, Proton, and Wine are x86 at heart; ARM translators (box64, FEX) aren't the polished, it-just-works experience we promise.

If there's demand in GitHub Discussions after v1 launches, Bokkie moves up the list. Until then: "still coming."

## The promises

1. **Updates don't break.** Every update swaps a full image. If anything goes wrong, one reboot rolls you back. This is the same trick the Steam Deck uses.
2. **No ads. No nags. No telemetry. No accounts.** Not a policy we might change — a design choice. There is nothing to sell.
3. **You can always go back.** Rollback is one reboot. You never get stranded in a half-working state.
4. **We inherit, we don't reinvent.** Macrosofty sits on Universal Blue and Fedora atomic desktop. Every fix upstream ships, we ship. Forever.
5. **The recipe is public.** You can read it, fork it, audit it, build your own version with different opinions. Nothing is hidden.
6. **We'll tell you honestly when something won't work.** No marketing-speak. No "compatible" weasel words. If your Windows-only CAD package isn't going to run, we say so.
7. **Make it yours, in one click.** The system is opinionated — atomic, curated, locked-down where it matters. The *desktop* is yours. Colour palette, wallpaper, cursor size, text size, icon pack — one click, no terminal, no config files. A gran who wants a pink desktop with her dog on the wallpaper can have both, in the first five minutes, without asking anyone. We handle the plumbing; you handle the paint.

We don't reinvent the wheel — **we make it easy to customise what Linux already does**. KDE Plasma is already enormously flexible. We ship a friendly "Make it yours" front door on top of it, curate a small gallery of presets, and leave the power-user levers (global themes, Konsave profiles, Kvantum, .desktop files) accessible for anyone who wants to dig deeper.

## Voice and tone

- **Conversational, dry, warm.** Like a competent friend explaining the thing at a braai — *not* a vendor explaining it at a conference.
- **South African flavour, sparingly.** The founder is South African; one *lekker*, one *howzit*, one *boet* per page is flavour. Every sentence would be cosplay.
- **Never corporate, never preachy.** No "empower your digital journey" nonsense.
- **Honest when we don't know.** "Experimental" means experimental. "Not supported" means not supported.
- **No smug Linux evangelism.** We're here to get people off the thing they don't like, not lecture them about free software for 45 minutes.
- **The joke is in the name, the tagline, and the absence.** Don't over-explain it.
- **Peace, not war.** We're not here to attack the rival — we're an alternative for people who want one. No shame, no lecture, no conversion pressure. If someone's current OS works for them, great.

### The supporting slogans (use these verbatim or in spirit)

- **"A Linux that doesn't suck."** — the headline.
- **"Free for everyone. Forever."** — the promise, repeated often.
- **"We open the door — not just a window to peek through."** — the metaphor.
- **"Peace, not war."** — the stance.
- **"Become a Macrosofty."** — affectionate self-ID for users.
- **"Macro means big. Softy means easy. Big and easy."** — the name unpacked (only in FAQ; never elsewhere).
- **"Explained at a braai, not in a board meeting."** — the voice.
- **"Made with lekker in Mzansi."** — the attribution.

## Landing page — conversion-friendly flow

The website should guide a visitor through: **what is this → is it for me → pick my edition → download → install.** Lots of pages fail by making visitors scroll through philosophy before letting them self-identify.

**Proposed structure:**

### Hero
- One-line pitch: "A Linux that doesn't suck."
- Subhead: "No ads. No accounts. No nonsense. Just a computer that respects you."
- Tagline: "We open the door — not just a window to peek through."
- Visual: clean screenshot, big friendly download button, three smaller edition buttons below.

### "Is Macrosofty for you?"
A self-select decision path. Each entry ends with an implicit "if that's you, this is yours."

> **"I just want my computer to work."**
> → You want **Macrosofty Hearty**. The most common starting point. Browser, email, Netflix, printing, photos, video calls — all there, all working.

> **"I work on this thing all day."**
> → You want **Macrosofty Chunky**. Everything Hearty has, plus office tooling, PDF editing, developer tools, better file management.

> **"I'm trying to revive an older laptop."**
> → You want **Macrosofty Broth**. Runs on 4 GB of RAM. Boots in seconds. Gives old hardware a second life.

> **"I want to play games."**
> → You want **Macrosofty Feast**. Steam, Proton, controllers, your Steam Deck's best tricks. Plug in, install, play.

> **"I want them all but have one computer."**
> → Pick the one closest to your main use. You can always install apps from another edition later.

### FAQ — preempt the top objections

> **"Will my stuff work?"**
> Webpages — yes. Netflix/Spotify/YouTube/Zoom/Teams/Discord/Slack — yes. Office files — yes (OnlyOffice and LibreOffice open them; the web versions of the big office suites work too). Windows-only games — check ProtonDB, most work. Windows-only professional software like AutoCAD or certain plug-in-heavy DAWs — probably not without effort, and we'll say so.

> **"Will it be hard to install?"**
> Download the ISO, write it to a USB stick, plug it in, click through. About 15 minutes. We have a video.

> **"What if I don't like it?"**
> It's free. Uninstall, put your old OS back. No drama.

> **"Will it break?"**
> No. Updates swap the whole system image. If anything fails, one reboot puts you back on the previous version. This is architectural, not aspirational.

> **"Will you sell my data?"**
> No. There's nothing to sell. No telemetry, no accounts, no phone-home. The source is public — check.

> **"Who makes this?"**
> A small team that got tired of the door company only selling windows, and tired of telling their relatives "just use Linux" without giving them a Linux that wouldn't confuse them.

### Download section

Four big buttons, labelled clearly, with a short description under each. A fallback link to GitHub for nerds.

### Footer

- Small text: *"© Macrosofty. No windows were harmed in the making of this operating system. The door is always open."*
- Links: GitHub, source, security policy, contact.
- Deliberately no newsletter signup, no social-media pixel, no cookie banner.

## What we are not

- Not a gaming-first distro (Bazzite is, and we point people there — our Feast edition is lightly rebranded downstream of Bazzite's work).
- Not a tinkerer's distro (Arch, NixOS, Gentoo cover that).
- Not "a better Ubuntu" or "a better Mint." We stand on their shoulders; we aren't competing with them directly. Our competitor is the door company.
- Not a community-driven free-for-all. Opinions are baked in on purpose. Users can override; we don't take PRs that dilute the identity.

## What "done" looks like for v1

- Four ISOs, all booting and installing cleanly on a typical VM and a typical 5-year-old laptop.
- Branding consistent across install, boot, desktop, about pages.
- A simple website with the flow above, pointing at the downloads.
- A firstboot wizard that onboards in under 3 minutes without requiring an account.
- A rollback that works. (Test it by deliberately breaking an update.)
- Docs for install, upgrade, rollback, and "I'm stuck" — in plain English.

## Tech choices (decided)

| Layer | Choice | Why |
|---|---|---|
| Base | Universal Blue (Fedora atomic desktop) | Only production-ready atomic desktop lineage |
| Build | Containerfile per edition, GitHub Actions | Free CI, cached layers, cross-platform |
| Image registry | `ghcr.io/macrosofty/<edition>` | Free, unlimited pulls, standard in this ecosystem |
| ISO builder | `bootc-image-builder` | Official tool for OCI → ISO, actively maintained |
| **ISO hosting** | **SourceForge** | **Free, mirrored worldwide, no bandwidth cost to us. Honest caveat: SF had adware scandals ~2013–2016 and Linux community memory is long; we address this in the FAQ by linking direct-download URLs that skip SF's UI where possible.** |
| Website | Static (**Astro 5.x + Tailwind 3.x via `@astrojs/tailwind`**) on Cloudflare Pages | Free tier, zero JS shipped to browser, self-hosted fonts (no external CDN calls, no tracking). Tailwind 4 + `@tailwindcss/vite` migration is a future job — low priority |
| License | Apache 2.0 | Matches Universal Blue upstream |
| Upstream donors | Aurora (Hearty), Aurora-DX (Chunky), Aurora stripped (Broth), Bazzite (Feast) | Inherit, don't reinvent |
| Desktop environment | **KDE Plasma** (all editions) | Cohesion across editions; Bazzite's strong KDE work gives us a known-good gaming base; KDE's Windows-like layout lowers the learning curve for newcomers |
| Image signing | `cosign` with GitHub Actions **OIDC keyless signing** | No long-lived secrets, no key management burden, transparency via Sigstore's public log |
| Support channel | **GitHub Discussions** | Zero infra, searchable, tied to code, free; no Discord/Matrix moderation burden for a love project |
| Funding | GitHub Sponsors (optional, not required) | No ads, no accounts, no data. Donations cover domain + any overflow. Project runs at a loss as long as it can; wind-down policy documented below. |
| Release cadence | Weekly image builds on `main`; versioned release follows Fedora major (`macrosofty-42`, `macrosofty-43`) | Users auto-upgrade via rpm-ostree; big Fedora bumps lag upstream by ~1 month for stability |

## Operational decisions

These are the decisions that turn "a brief" into "a project someone can actually run."

### Support model — GitHub Discussions

One place, one URL, one moderation queue. No Discord, no Matrix, no forum, no subreddit (at least until there's enough volume to justify one). Categories:
- **Help** — "my install is stuck / this doesn't work / how do I do X"
- **Show & tell** — user screenshots, "I put Macrosofty on grandma's laptop"
- **Ideas** — feature requests, parked until actionable
- **Announcements** — release notes, important changes (maintainer-only)

No SLA. Answers are best-effort. Clear expectation in the README: *"This is a love project. We answer when we can."*

### Funding & sustainability — love-project posture, clearly

- **Runs at a loss until it can't.** The founder pays for domain and any overflow out of pocket.
- **GitHub Sponsors** is enabled for people who want to contribute. No OpenCollective (adds admin burden). No Ko-fi. No Patreon.
- **We will NEVER take money in exchange for including, removing, or featuring any software.** This is a promise.
- **Wind-down clause** (in public docs): "If the maintainer can no longer afford or sustain this project, we will announce a 6-month wind-down in Announcements. Images stay available via SourceForge archive. Rollback continues to work to the last version shipped. No user is left stranded overnight."
- No ads on the website, ever. No affiliate links, ever. If we have a "Buy a sticker" merch thing one day, that's allowed. That's the only commerce we'll ever touch.

### Signing keys — cosign + GitHub OIDC, no secrets

- Images are signed at build time in GitHub Actions using Sigstore's keyless flow (the same approach Universal Blue uses).
- Public verification info is published in `SIGNING.md`.
- No human holds a signing key. No key rotation required. No "oh no, the maintainer's laptop got stolen" scenario.
- Supply-chain: dependencies reviewed on upstream version bumps, automated via Dependabot / Renovate.

### Fedora version bumps — lag by one month, be explicit

- Every 6 months Fedora cuts a major version. We track it, but we **don't immediately follow**.
- 4–6 weeks after a Fedora release, once the dust settles on the upstream side (Bluefin/Bazzite usually bump first), we cut `macrosofty-N+1`.
- Users auto-migrate via rpm-ostree rebase on a schedule we control — we hold users back until we've tested.
- Clear "known issues" doc per Fedora bump, in `docs/upgrades.md`.

### Anti-cheat honesty — up front, in the FAQ, not buried

Feast users need to know that **kernel-level anti-cheat (Vanguard, BattlEye-EAC, most competitive-shooter anti-cheat) does not work on Linux**, and that's not something we can fix. Games it blocks include (at time of writing):

- Valorant (hard block, kernel-level)
- Fortnite (multiplayer blocked; SP/offline modes fine)
- Apex Legends (post-2024 EAC change — blocked)
- Call of Duty (MW series, Warzone — blocked)
- Destiny 2 (blocked)
- Escape from Tarkov (blocked)
- PUBG (blocked)

The FAQ phrases it honestly:

> **"Can I play Valorant / Fortnite / CoD on Feast?"**
> No — not because of anything we're doing, but because those games require a Windows kernel driver for their anti-cheat and don't support Linux. Nothing any Linux distribution can do about this. Check [areweanticheatyet.com](https://areweanticheatyet.com) for current status. Most non-kernel-anti-cheat games work great.

### Trademark / attribution to upstream

- We say "Built on Fedora Atomic Desktops" and "Based on Universal Blue" — these are descriptive uses allowed under Fedora's Trademark Guidelines.
- We do **not** use Fedora's logo, Bluefin's logo, or Bazzite's logo on our site or in our product.
- `ATTRIBUTION.md` lists every upstream project with license + link.
- We link generously to upstreams — these are the people who make our project possible.

### Accessibility — inherit + don't regress

Not the hill to be a hero on for v1, but also not negotiable:

- We inherit all accessibility work from KDE Plasma + Fedora + upstreams.
- **We will not ship customisations that break a11y** (e.g., custom themes with insufficient contrast, cursor themes that are too small, animations without reduced-motion respect).
- Accessibility regressions are treated as critical bugs.
- If a user reports an a11y issue, we escalate it to the relevant upstream and track it in our issues until resolved.

### Localisation — English first, add languages later

- v1 ships with English only, including all Macrosofty-specific copy (firstboot wizard, welcome app, About screens).
- We don't block languages KDE/Fedora support out of the box — those still work.
- **Afrikaans translation is the first one we'll add** when there's bandwidth (founder bias, and South African market is underserved in friendly Linux distros).

### Hardware compatibility — "if Fedora 42+ supports it, we do"

- We don't maintain a hardware compat DB. The Fedora one is the source of truth.
- Community-contributed "known to work / known to fail" list in GitHub Discussions, not in the main repo (low maintenance).
- Minimum spec we publish: 4 GB RAM (Broth), 8 GB RAM (Hearty/Chunky/Feast), x86-64 CPU for Hearty/Chunky/Broth (anything from ~2010+), x86-64-v3 for Feast (Bazzite's gaming kernel needs it — roughly 2013+), 30 GB disk, UEFI boot. We test against a couple of reference machines.
- **Architecture:** v1 is x86-64 only. aarch64 (Pi 5, Rockchip SBCs, Apple Silicon via Asahi) comes later as the tentative **Bokkie** edition — forked directly from Fedora Kinoite aarch64, not from Universal Blue (they don't publish ARM images). Bokkie will never include Feast — Steam / Proton / Wine are x86-native and ARM translators (box64, FEX-emu) aren't good enough to earn our "just works" promise.

### Firstboot wizard — under 3 minutes, no account

Flow:

1. **Welcome** — one-line greeting, tagline, Next.
2. **Language & keyboard** — detect from install-time setting, allow override.
3. **Network check** — confirm online; skip-able.
4. **User account** — local only. Username, password, that's it. No Microsoft-account-style nag. No "sign in to the cloud." No telemetry opt-in box (because there's no telemetry).
5. **App picker (optional)** — "Want these? They're pre-curated by us." A short list of Flatpaks grouped by category (communication, creative, gaming extras). Each checkbox off by default — user picks what they want. Skip entirely is fine.
6. **Done.** One-sentence "The door is open. Have fun." and a link to the welcome app for anything else.

The welcome app lives in the system tray after setup — optional re-run of picker, cheat-sheet of keyboard shortcuts, link to docs.

### ISO hosting on SourceForge — how we do it

1. Create the `macrosofty` SourceForge project. Use the "File Release System."
2. Each edition gets its own folder: `/Hearty/`, `/Chunky/`, `/Broth/`, `/Feast/`.
3. GitHub Actions uploads new ISOs via `sshpass`/`rsync` on successful build.
4. **Direct-download URLs** are published on our website, using SF's `/files/.../download` pattern which bypasses most of their sponsored-ad UI.
5. We mirror ISOs to GitHub Releases only for the **very latest** (GH Release asset size is 2 GB, some editions fit, Feast probably won't). SF is the primary.
6. SHA256 sums and `cosign` signatures hosted alongside every ISO.
7. **Honest caveat on the website:** "We host on SourceForge because it's free and mirrored worldwide. SF had reputation issues in the mid-2010s; the links below go directly to the file and skip the sponsored interstitials where possible. Verify the SHA256 sum on download."

## Open questions left for later

(Things we don't need to decide right now, parked.)

1. **Domain name.** Availability confirmed on 2026-04-24: `.org`, `.com`, `.io`, `.net`, `.dev`, `.co.za` — all available for registration. Recommendation: `macrosofty.org` as primary (matches love-project posture); `.com` as optional defensive grab.
2. ~~**GitHub org name.**~~ **Claimed 2026-04-24: `github.com/macrosofty`.** Main repo: `github.com/macrosofty/macrosofty`.
3. **Trademark sanity check.** Done on 2026-04-24: no registered "Macrosofty" mark; only hits are a dormant Twitter handle from 2010 and satirical references. Microsoft parody risk exists but is low for a non-commercial love project.
4. **Feast naming second-guess.** Does "Feast" clearly signal "gaming" to an outsider? Low-priority; we can A/B with taglines on the download page.
5. **Bokkie (ARM) commitment.** Post-v1 stretch. Fedora Kinoite aarch64 is the base (UBlue doesn't ship ARM). Gauge interest via GitHub Discussions after launch.
6. **Second DE variant (GNOME).** Not for v1. Maybe later if there's user demand.
7. **"Make it yours" app implementation.** Qt/Kirigami app wrapping KDE theming + curated preset gallery. Core differentiator — not in v0.1, target v0.3.

## Project history

- **2026-04-24 (first day):** VISION + CLAUDE brief written. Renamed from "Microslop" after discovering `microslop.com` was a live "Microsoft AI Slop Tracker" (brand collision). Name reference: `macro` (big) + `softy` (easy) = "big and easy" — plus an obvious Microsoft parody that we never spell out. Website scaffolded in Astro 5 + Tailwind. Apache 2.0 LICENSE. Local git repo, no remote yet. ARM edition ("Bokkie") researched and confirmed tentative-post-v1.

## Hand-off

This document and `CLAUDE.md` are the full brief. They should be enough for a competent Linux engineer (or an agent) to go from "nothing" to "scaffolded repo with a hearty ISO you can install in a VM" in a weekend.

If something's unclear, the right instinct is to check what **Bluefin** or **Bazzite** does for the same question — that's usually the answer.

---

*The door is always open.*
