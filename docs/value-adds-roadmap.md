# Macrosofty Value-Adds — Ranked Roadmap

**Last updated:** 2026-04-26
**Status:** Living document. Ranks, statuses, and notes shift as ideas mature, get rejected, or ship. Anyone proposing a new feature should land it here first, ranked, before code is written.

---

## What this document is

This is the **ambitions list** — every meaningful feature, project, or sub-system that's been considered for Macrosofty beyond "ship the four editions and a website." It exists so we don't lose ideas, so we have an honest sense of priorities, and so the next person to look at this project knows what's already been weighed.

It's **not a commitment**. Items here are explicitly speculative until they show up in a release-target milestone. Ranking is current best judgement, not a contract.

## How the ranking works

Five factors, each scored loosely 1–5:

1. **Audience impact** — does it solve a real pain point for the noob persona (Windows-tired, hand-me-down hardware, relative-supporter, etc.)?
2. **Brand fit** — does it embody "open the door, the house is yours"?
3. **Effort-vs-reward** — small win for big effort = bad ratio; big win for medium effort = good ratio.
4. **Differentiation** — does ANY other distro do this well? If not, this is white space.
5. **Buildability** — can a love-project (one or two people, weekends and evenings) actually ship this?

The combined score determines tier. Within a tier, ordering is judgement, not arithmetic. The whole thing is reordered when reality shifts.

## Voice & flavour: Mzansi *and* lekker for everyone

Two design constraints on every feature here:

- **Voice stays Mzansi.** Friendly, dry, knowing. SA colloquialisms (lekker, howzit, bru, braai, tjops, Mzansi) sparingly — once per section at most. The voice is the brand; we don't water it down for international audiences. They get the warmth even if they need to look up "padkos" once.
- **Features stay international by default.** A user in Berlin or Buenos Aires shouldn't hit features that assume SA knowledge. Anything SA-specific (load-shedding awareness, SA banking USB quirks, Afrikaans-first locale) is explicitly **opt-in** or auto-detected by region — never blocking. SA-specific items are clearly marked **[Mzansi]** below.

The combined effect: a person in Cape Town gets the full experience plus their local touches; a person in Cape Cod gets the same warmth without the in-jokes they'd miss.

## Design principle: every setup task is a friendly screen

This is a **cross-cutting principle**, not a feature in itself, but it shapes how every feature here should be designed.

Validated empirically in the founder's homelab work (2026-04 sessions): wrapping complex setup tasks in interactive screens — choose-from-options + one-click — dramatically lowers the friction of doing something for the first time. People who'd never edit a config file will happily click through a wizard.

**The rule:** if a feature in this list requires a config file edit, a CLI command, or knowing what the right service name is, it's not done. Every setup task in Macrosofty gets a friendly screen with sensible defaults, plain-English explanations, and a "skip" or "later" option.

This applies to: the first-boot wizard (#1), the recovery button (#4), Make it yours (#2), backup setup (#13), family mode templates (#15), the share & serve panel (#39), printer setup (#23), KDE Connect onboarding (#24), email setup (#11), and pretty much everything in tiers 1–4.

It does NOT mean we hide power-user options — they stay available in System Settings or via CLI for anyone who wants them. The default *experience* is the friendly screen; the *underlying flexibility* of Linux is preserved.

---

## At a glance

| # | Name | Tier | Effort | Flavour |
|---|---|---|---|---|
| 1 | Friendly first-boot wizard | 1 — Foundational | Medium | International |
| 2 | Make it yours panel | 1 — Foundational | Large | International |
| 3 | Macrosofty Helper app | 1 — Foundational | Medium | International |
| 4 | "Something feels off" recovery button | 1 — Foundational | Small | International |
| 5 | Plain-language errors | 1 — Foundational | Medium-rolling | International |
| 6 | Local AI helper | 2 — High-impact | Large | International |
| 7 | AI-generated wallpapers + themes | 2 — High-impact | Medium | International |
| 8 | Tour mode | 2 — High-impact | Medium | International |
| 9 | Hardware sanity check | 2 — High-impact | Small | International |
| 10 | "Find your stuff" Windows import | 2 — High-impact | Medium | International |
| 11 | Email setup wizard | 3 — Concrete daily-life | Small | International |
| 12 | Document import | 3 — Concrete daily-life | Small | International |
| 13 | Backup made invisible | 3 — Concrete daily-life | Medium | International |
| 14 | Friendly screen-recorder for support | 3 — Concrete daily-life | Small | International |
| 15 | Family mode templates | 3 — Concrete daily-life | Medium | International |
| 16 | Built-in screen sharing for remote help | 3 — Concrete daily-life | Small | International |
| 17 | Privacy dashboard | 3 — Concrete daily-life | Medium | International |
| 18 | "Why did this happen?" explainer | 3 — Concrete daily-life | Medium-rolling | International |
| 19 | Theme marketplace (community packs) | 3 — Concrete daily-life | Medium | International |
| 20 | Mood presets | 3 — Concrete daily-life | Small | International |
| 21 | Adaptive UI (time/battery aware) | 3 — Concrete daily-life | Small | International |
| 22 | Permission requests in plain English | 3 — Concrete daily-life | Medium | International |
| 23 | Printer setup polish | 4 — Polish | Small | International |
| 24 | Phone-to-computer onboarding | 4 — Polish | Small | International |
| 25 | Battery health view | 4 — Polish | Small | International |
| 26 | Account avatar from Gravatar | 4 — Polish | Trivial | International |
| 27 | Guest mode polish | 4 — Polish | Trivial | International |
| 28 | One-tab notifications digest | 4 — Polish | Medium | International |
| 29 | Load-shedding aware | 5 — Mzansi | Small | **[Mzansi]** |
| 30 | SA banking quirks pre-installed | 5 — Mzansi | Small | **[Mzansi]** |
| 31 | Afrikaans/Zulu/Xhosa first-class locale | 5 — Mzansi | Large | **[Mzansi]** |
| 32 | Mzansi app curation | 5 — Mzansi | Small | **[Mzansi]** |
| 33 | Macrosofty-native package format (.macro) | 6 — Stretch | Multi-month | International |
| 34 | Voice-driven help | 6 — Stretch | Multi-month | International |
| 35 | Multi-device profiles (sync) | 6 — Stretch | Multi-month | International |
| 36 | Built-in coding tutorial | 6 — Stretch | Multi-month | International |
| 37 | System health AI (proactive watcher) | 6 — Stretch | Multi-month | International |
| 38 | XFCE edition for sub-2 GB-RAM hardware | 6 — Stretch (parked) | Multi-month | International |
| 39 | **"Share & Serve" panel — host services from your desktop** | 2 — High-impact | Medium-large | International |

Effort key: **Trivial** (afternoon), **Small** (weekend), **Medium** (a couple of weekends to a month), **Large** (months), **Multi-month** (real serious project), **rolling** (continuous gardening).

Status key (used in the detail sections below): **idea / explored / proposed / planned / in-flight / shipped / parked / rejected**.

---

## Tier 1 — Foundational (the must-haves)

These are the things that, if Macrosofty had them, would already justify its existence as separate from Aurora. Each is a v0.2 candidate or ought to be.

### #1: Friendly First-Boot Wizard

**Status:** idea
**Audience:** Windows-tired person, relative-supporter, hardware recycler
**Effort:** Medium (~2–3 weekends)

After install, the user reboots into Macrosofty and sees Aurora's terminal-flavoured "Hello, stargazer, run `ujust --choose`" greeting. That's charming for Linux nerds and bewildering for everyone else.

**What we ship instead:** a Plasma applet (or a kcm) that runs once on first login. Five gentle, optional, skippable steps:

1. **Name your computer** (defaults to a chosen-from-list cute name if user has no preference — pre-populated with vibes-y options like "saffron" or "klein-koos" with international defaults like "robin" or "willow").
2. **Connect to wifi** (skipped if already connected; otherwise wraps NetworkManager's existing dialog with one-line plain-English help).
3. **Set up email** (asks for email address, auto-detects provider for big ones, pre-fills Thunderbird IMAP/OAuth settings).
4. **Install one app** (opens Discover, suggests three commonly-wanted apps with one-line descriptions: a chat app, a creative app, a productivity app).
5. **Optional backup setup** ("plug in a USB drive? want to back up to it?" — wraps DejaDup).

Every step has a "Skip" and a "Why this?" link. None are blocking. After completion, the wizard hides itself and is one click away from re-running.

**Why this matters:** the first 15 minutes after install are when a user decides whether to keep the OS or wipe it. Aurora-like distros assume the user knows where to start. We don't. The wizard tells them what to do without making them feel dumb.

**Implementation notes:** Plasma applet in QML reading a wizard definition from a JSON or YAML file (so steps can be edited without recompiling). State persisted in `~/.config/macrosofty/onboarded`.

**Open questions:**
- Replace Aurora's `ublue-os/motd` entirely or coexist? (Recommend: replace — the terminal motd is a different audience.)
- Does this become the entry point for the "Make it yours" panel too (#2), or a separate flow?

---

### #2: Make It Yours panel

**Status:** mentioned in CLAUDE.md as v0.3 target
**Audience:** all four personas; especially the Windows-tired user wanting "their" computer
**Effort:** Large (months)

A first-class customisation panel. Wallpaper, palette, cursor size, text size, icon pack, sound theme, panel layout — all in one screen, all curated, all one-click. **Fun, not configurable.**

**What we ship:**
- Curated wallpapers (~20 to start, mix of saffron-arch / sage / wine-themed plus international vibes — sunsets, tjokolaad, forests, deserts, ocean — covering moods more than locations).
- Palette presets (saffron, sage, wine, charcoal, blush, ocean, lavender — each a coordinated set of wallpaper + accent + system colour).
- Cursor + text + spacing in one slider ("comfortable", "comfy-er", "I need glasses, comfy-est").
- Icon pack picks (3–5 curated themes, not the Flathub firehose).
- Optional panel layouts (Windows-like default, macOS-like dock, minimal corner).
- Sound theme picker (default, off-but-haptic, retro).
- "Random surprise me" button.

**Why this matters:** "I want my computer to feel mine" is the #1 emotional reason people stay on a new OS. KDE *can* do all of this; it just hides it in 47 settings dialogs. We unhide it.

**Brand fit:** load-bearing. The literal manifestation of "we open the door — the house is yours". This is the feature the website screenshots. The thing reviewers mention.

**Mzansi flavour notes:** include a "Mzansi" mood pack (saffron + sage + a Karoo wallpaper) but also "Cape coast", "Krugersdorp sunset", "Highveld storm" alongside non-SA picks. The Mzansi-tagged ones don't dominate; they coexist. Same for sound themes — a kraal-ambient option, but also rain-on-window, café, fireplace.

**Implementation notes:** custom KCM (KDE Config Module) in Qt/QML. Builds on the existing theme-pack system (this session, `docs/theme-packs.md`). Each "look" in the UI is a theme-pack on disk + system-wide Plasma config edits. Reuses `macrosofty-theme apply <pack>`.

**Dependencies:** stable theme-pack system (have it). Look-and-Feel package authoring (don't have, would need).

**Open questions:**
- AI-generated wallpapers (#7) integrate as another "tab" here or as a separate path?
- Does palette swap require Plasma session restart? (Yes, probably — we'd need to handle gracefully.)

---

### #3: Macrosofty Helper app

**Status:** idea
**Audience:** the Windows-tired user when they get stuck
**Effort:** Medium (1–2 months for a v1 useful version)

KDE's built-in help is essentially a 200-page PDF. When something goes wrong, users currently Google a cryptic error and end up on a forum. The Helper app is a search-first, plain-language interface to our docs + curated FAQ.

**What we ship:**
- Search box. Type a question in plain English ("how do I set up a printer?", "why is my laptop slow?"). Results from our docs first, then community Q&A.
- Curated FAQ for the top 50 noob questions (this is a content task, not just engineering).
- Optional integration with the Local AI Helper (#6) — when local AI is available, the Helper can answer the question in our voice instead of redirecting to docs.
- "Show me how" buttons on settings screens that open Helper to the relevant page.
- Offline-first: docs ship in the image, no internet needed for basic Q&A. Online for community-content.

**Why this matters:** noobs don't know what to search for, and even if they do, Linux forums are unfriendly. The Helper is a friendly first stop.

**Implementation notes:** Tauri or Electron-shaped desktop app *or* a Plasma applet wrapping a webview into a static site. The simpler option is a webview into our docs.macrosofty.org. The smarter option is a tagged search index built at doc-build time.

**Open questions:**
- How much content is "enough" for v1? (Suggested: top 50 questions written by hand, then expand as users tell us what they searched for.)
- Do we want analytics on what's searched? (CLAUDE.md says no telemetry. Could ask explicit consent for "help us improve the Helper" with one-question surveys.)

---

### #4: "Something feels off" recovery button

**Status:** idea
**Audience:** all personas; especially the relative-supporter explaining "yeah, just press this button"
**Effort:** Small (1 weekend)

`bootc rollback` exists but nobody knows about it. Atomic distros' superpower (one reboot back to yesterday) is invisible to non-technical users. We surface it as a single button in the system tray + a kcm panel: "Something feels off → go back to yesterday's version".

**What we ship:**
- A system-tray indicator that shows "last good version" date.
- A dialog explaining the rollback in plain English ("This will restore your computer to how it was on Tuesday, 23 April. Your files won't change — just the software. Takes one reboot. Reversible.")
- Confirmation + reboot.
- After rollback, the indicator changes to "rolled back from <next>" with a link to "what happened?" diagnostic.

**Why this matters:** the atomic-update doesn't-break promise is *the* technical foundation of Macrosofty. Until users can use it, they don't believe it.

**Implementation notes:** wraps existing `bootc` and `rpm-ostree` commands. PolicyKit for elevation. Plasma applet for the indicator.

**Open questions:**
- Show this to all users by default, or only after the first time something actually breaks? (Default: show, with "what is this?" tooltip.)

---

### #5: Plain-language errors

**Status:** idea
**Audience:** every user who's ever Googled "blueman 78 no peer found"
**Effort:** Medium-rolling (continuous content work)

Wrap common system error messages with friendly translations. Instead of a kernel log line, the user sees "Your Bluetooth headphones lost connection. Try turning them off and on again. If that doesn't help, here's a link."

**What we ship:**
- A small library that intercepts notification daemon outputs (or wraps systemd-journald).
- A growing dictionary of error-pattern → friendly-translation mappings.
- For each translation, a "see the technical version" link for the curious + power-users.

**Why this matters:** the moment the OS speaks gibberish at a noob is the moment they stop trusting it. Every translated error is a saved user.

**Implementation notes:** start with the top 20 error messages we observe in real installs (we'll need a way to gather these — perhaps user-opt-in error reports). Grow the dictionary over time. Could be community-contributed via PRs to a YAML file.

**Open questions:**
- How do we collect the "top 20" without telemetry? (Volunteer reports via the Helper app: "tell us about an error you saw".)

---

## Tier 2 — High-impact (the differentiators)

These are the features that, if Macrosofty has them, separate us from Aurora/Bluefin and from commercial OSes.

### #6: Local AI helper

**Status:** idea (related to claude-code-setup considerations)
**Audience:** all personas, especially the privacy-conscious refugee
**Effort:** Large (months)

A built-in AI assistant powered by a local LLM (Ollama-or-similar). Answers "what does this error mean?", "summarise this PDF for me", "translate this to Afrikaans", "help me write an email to my landlord". **Locally. No data leaves the machine. No accounts. No cloud.**

**What we ship:**
- A small (~7B-or-less) quantized LLM bundled in the image, loaded on-demand.
- A panel applet for "ask Macrosofty" with chat interface.
- File-content integration ("summarise this document I have open").
- System integration ("explain this error", "what's this app doing?").
- Honest about limits ("I'm a small model running on your machine; for complex queries you may want a bigger online tool, but I don't share your data").

**Why this matters:** every commercial OS now ships AI that exfiltrates user data. Macrosofty's privacy posture is genuinely defensible because we ship local AI with the same usefulness without the cost. **This is the most defensible single feature we could build.**

**Implementation notes:** Ollama runtime + a chosen model (Llama 3.2 1B / 3B, or Qwen 2.5 1.5B / 3B — small enough to run on Padkos hardware). UI in Qt/QML. Inference happens in the background; UI is async.

**Hardware constraints:** small models (< 4B params) run acceptably on 4GB RAM, but a 7B model + browser is tight on Padkos. Ship the smallest workable model on Padkos; a larger one (or "download an upgrade") on Hearty/Chunky/Braai.

**Mzansi flavour notes:** the model could be fine-tuned on Macrosofty docs + voice, so its responses sound like us. Not generic-AI-assistant. Optional.

**Open questions:**
- How big a model can we ship without bloating the ISO? (3B-quantized model is ~2 GB. Could be a separate Flatpak so users opt in.)
- Default off (privacy) or default on (utility)? (Recommend: default off, with a sales-pitch first-run; user actively chooses.)

---

### #7: AI-generated wallpapers + themes

**Status:** idea
**Audience:** the playful user who'd never normally touch personalisation
**Effort:** Medium (one month)

User types "cosy autumn evening" → Cloudflare Workers AI (existing infra) generates a wallpaper, derives a coordinated palette, optionally suggests a sound theme. User saves it as a "look". Optionally shares.

**What we ship:**
- A "create a look" tab in the Make It Yours panel (#2).
- Text input + generation request hits our Cloudflare Workers AI endpoint.
- Result is automatically integrated as a theme-pack and applied with one button.
- "Save this look" → creates a local theme-pack.
- "Share this look" → exports as a pack file the user can email or upload.

**Why this matters:** customisation that's playful, not technical. Most distros have wallpapers; nobody has *create your own*. **Would be widely shared on social media** ("look what my Linux made me"), which is free marketing.

**Implementation notes:** Cloudflare Workers AI for image generation (we have account per memory). A small server-side function for the prompt processing + image generation. Client-side palette derivation from the generated image (`Vibrant.js`-style algorithm).

**Privacy notes:** prompts go to Cloudflare. Disclosed clearly. Opt-in feature. Not the default.

**Mzansi flavour:** SA-themed pre-prompts ("Cape coast misty morning", "Karoo at sundown", "highveld thunderstorm") shipped as starters but not exclusive.

**Open questions:**
- Cloudflare Workers AI cost per generation — currently free tier; if Macrosofty grows we'd hit limits. Plan: cache generated wallpapers and let users share them.

---

### #8: Tour mode

**Status:** idea
**Audience:** Windows-tired person; especially first install
**Effort:** Medium (1–2 months)

A guided, in-place walkthrough that actually clicks things for you. "Here's how to install an app" — and it opens Discover, hovers the right button, narrates. "Here's how to set up email" — opens KMail, points at the wizard.

**What we ship:**
- A scripted walkthrough engine: highlights UI elements, narrates with bubble overlays.
- 5–10 starter tours covering: install an app, set wallpaper, set up email, use the file manager, take a screenshot, configure printing.
- "Replay this tour" available from the Helper app.
- Replayable, skippable.

**Why this matters:** docs assume reading; tours don't. Watching the OS *do* the thing is for everyone else.

**Implementation notes:** building blocks exist — KWin's window-highlight effect, Plasma's notification bubbles. Need a coordinator that scripts a sequence.

**Open questions:**
- Auto-trigger on first install or only available on demand? (Recommend: gentle suggestion in the first-boot wizard, "want to see how to do common things?")

---

### #9: Hardware sanity check

**Status:** idea
**Audience:** post-install moment for everyone
**Effort:** Small (1 weekend)

Pre-flight test: mic works, camera works, speakers work, printer works, internet works. Run after install before the user discovers issues mid-meeting.

**What we ship:**
- A panel that runs through hardware checks, ~30 seconds.
- Each check has a "looks good" or "couldn't reach this — want to fix?" outcome.
- Failures link to fixes (printer setup, audio drivers, etc.).

**Why this matters:** the worst time to find your microphone doesn't work is the start of a Zoom call. Pre-flight catches it.

**Implementation notes:** wraps existing tooling: `ffmpeg`/Pipewire for audio test, `v4l2-ctl` for camera, `cups` for printer, `ping` for internet.

---

### #10: "Find your stuff" Windows import

**Status:** idea
**Audience:** Windows-tired user with their old machine still around
**Effort:** Medium (1 month)

Plug in your old Windows drive (or USB), this tool finds your photos, documents, music, browser bookmarks, and offers to copy them over.

**What we ship:**
- Detect attached storage devices.
- Heuristic scanning: look for `Documents`, `Desktop`, `Pictures`, `Downloads` folders; common formats; browser profile folders.
- "Found 1,240 documents and 3,000 photos. Copy them to your home folder?" plus per-category preview.
- Bookmark migration (Firefox, Chrome, Edge supported via JSON parsing).

**Why this matters:** the migration story is a huge friction point for the relative-supporter. "How do I get Mom's stuff onto the new laptop?" — currently means manually copying each folder.

**Implementation notes:** a Qt/QML app + KIO file operations. Bookmark migration via parsing Chrome/Firefox/Edge profile dirs.

---

## Tier 3 — Concrete daily-life improvements

Each of these makes a specific recurring task less painful. Lower-priority than tiers 1–2, but together they shape the daily feel of the OS.

### #11: Email setup wizard

**Status:** idea
**Audience:** every fresh installer
**Effort:** Small (1 weekend)

"What's your email address?" → auto-detects provider → walks through IMAP/OAuth in Thunderbird with no jargon. Top providers (Gmail, Outlook, Yahoo, Proton, FastMail) pre-configured.

Could be a step in the first-boot wizard (#1) or available standalone.

### #12: Document import

**Status:** idea
**Audience:** Windows-tired user, fresh install
**Effort:** Small (1 weekend)

Drag a folder of `.docx`/`.pptx`/`.xlsx` → open them in LibreOffice with compatibility-mode warnings shown plain-English ("this doc uses some Microsoft-specific formatting; layout might shift slightly").

### #13: Backup made invisible

**Status:** idea
**Audience:** literally everyone (nobody backs up enough)
**Effort:** Medium (1 month)

Detect external drive plugged in → "Want to back up?" Schedule + rotate + explain ("you're safe through Friday").

Wraps DejaDup or rsync. Nags gently if no backup in N days.

### #14: Friendly screen-recorder for support

**Status:** idea
**Audience:** every user who's tried to write a forum post about a bug
**Effort:** Small (1 weekend)

"I want help with this" button → records 30 sec of screen → posts to GitHub Discussions with system-info auto-attached (consent dialog explains what's included).

Currently the support workflow is "describe your issue in 5 paragraphs". A 30-sec video is faster.

### #15: Family mode templates

**Status:** idea
**Audience:** relative-supporter persona
**Effort:** Medium (1 month)

When creating a new user: "Is this for a child / teen / adult / shared?" → applies sensible defaults. Parental filters, app whitelists, time limits, screen-time tracking for child accounts. Adult template = our normal defaults.

### #16: Built-in screen sharing for remote help

**Status:** idea
**Audience:** relative-supporter
**Effort:** Small (1 weekend)

One-click "let my son help me" — generates a temporary access code, walks through KDE Connect or RustDesk pairing.

### #17: Privacy dashboard

**Status:** idea
**Audience:** privacy-conscious refugee, parent of a child account
**Effort:** Medium (1 month)

Plain-English view of what apps have what permissions, what data is in cloud accounts, what files are shared. "Where's my data?" map.

### #18: "Why did this happen?" explainer

**Status:** idea
**Audience:** anyone hitting an error or unexpected behaviour
**Effort:** Medium-rolling (continuous content)

When an app crashes or a system warning pops up, a "why did this happen?" link that opens a friendly explanation. Companion to #5 (plain-language errors) — #5 reframes the message; #18 explains the underlying cause.

### #19: Theme marketplace (community packs)

**Status:** idea (depends on Make It Yours #2)
**Audience:** users who want more variety than the curated 20
**Effort:** Medium (1 month after #2 ships)

Browse, install, share community theme packs. Built on the theme-pack system. Moderation lite (quality flagging by community).

### #20: Mood presets

**Status:** idea
**Audience:** users with multiple computer contexts (work + family + gaming)
**Effort:** Small (1 weekend)

Cosy / Focus / Family / Work / Gaming presets that swap wallpaper + colours + panel + sound theme + which apps are pinned. One click to switch contexts.

### #21: Adaptive UI (time/battery aware)

**Status:** idea
**Audience:** everyone
**Effort:** Small (1 weekend)

Detect time of day → auto-dim. Detect on battery → reduce animations. Detect tired eyes (long uptime + late hour) → bigger text suggestion.

### #22: Permission requests in plain English

**Status:** idea
**Audience:** all users
**Effort:** Medium (1 month)

"This app wants to: see your files. Why? It stores your work. Allow / Deny / Why?". Wraps Flatpak portal prompts, Polkit prompts, and any future permission UI in plain language.

---

## Tier 4 — Polish (small wins, accumulate over time)

### #23: Printer setup polish

Active scan-and-detect. Walk through driver install. Test page. Currently CUPS gives us most of this; we'd polish UX. **Small.**

### #24: Phone-to-computer onboarding

KDE Connect onboarding wizard. SMS, file transfer, clipboard sync — actually configured at first run, not just "available if you knew about it". **Small.**

### #25: Battery health view

Charge cycles, expected life, "is your battery healthy?" — for the hardware-recycler persona who wants to know if their old laptop's battery is still OK. **Small.**

### #26: Account avatar from Gravatar

At account creation, optionally fetch user's existing avatar from Gravatar. Saves the "no photo" awkwardness. Tiny implementation; nice touch. **Trivial.**

### #27: Guest mode polish

One-click "give my friend an account that disappears in an hour". Currently exists in Linux but is hidden. Polish UX. **Trivial.**

### #28: One-tab notifications digest

Replace Plasma's stream of notifications with a digest panel: "Today: 3 emails, 2 calendar events, 1 update available." Less anxiety than constant pings. Keep urgent notifications instant; bundle the rest. **Medium.**

---

## Tier 5 — Mzansi flavour (SA-specific)

These are the features that lean into the Mzansi part of the brand — explicitly opt-in or auto-detected by region. Do NOT make them required for non-SA users.

### #29: Load-shedding aware **[Mzansi]**

**Status:** idea
**Audience:** every SA user with intermittent grid power
**Effort:** Small (1 weekend)

Plug into Eskom Sepush API → know when load shedding is happening at the user's address. Auto-queue heavy tasks (updates, large downloads, video renders) for online windows. Save aggressively. Warn early ("loadshed in 23 min — saving open documents").

**Why this matters specifically for SA:** every SA user spends time managing power. This automates it.

**Implementation:** existing Eskom Sepush API + Plasma background service.

### #30: SA banking quirks pre-installed **[Mzansi]**

**Status:** idea
**Audience:** SA users with FNB / Standard Bank / Absa / Capitec USB tokens
**Effort:** Small (1 weekend)

Pre-installed support for SA bank USB tokens that sometimes need quirks on Linux. Opt-in helper that detects token model and auto-configures.

**Why this matters specifically for SA:** SA banks still issue USB hardware tokens for high-value transactions. Linux support is uneven; this fixes it for the user without research.

### #31: Afrikaans/Zulu/Xhosa first-class locale **[Mzansi]**

**Status:** idea
**Audience:** SA non-English-first users
**Effort:** Large (multi-month)

Full localisation, not just menu translations. Voice in our brand voice — "lekker" stays "lekker", we don't awkwardly translate idioms. Properly translated by SA speakers, not Google Translate.

**Why this matters specifically for SA:** SA's official languages include 11; major Linux distros translate to a handful poorly. We can ship better.

**Big caveat:** translation is rolling, expensive, and needs native speakers. Probably starts as Afrikaans-only and expands.

### #32: Mzansi app curation **[Mzansi]**

**Status:** idea
**Audience:** SA users on any Macrosofty edition
**Effort:** Small (1 weekend)

Optional region-specific app additions to the firstboot Brewfile: MyMTN, Capitec app via Waydroid, Discovery app, etc. Detected by user setting region to SA at install or in System Settings.

**Why this matters specifically for SA:** the everyday apps SA users want differ from international defaults.

---

## Tier 6 — Stretch goals (when we have momentum)

Ambitious projects that each warrant their own multi-month investment. Not v1.x; possibly v2+.

### #33: Macrosofty-native package format (.macro)

**Status:** idea
**Effort:** Multi-month

A `.macro` file that bundles app + settings + demo data + tutorial. Open it → app installed + configured + tour starts. Removes a class of "app installed but I don't know how to use it" pain.

**Risk:** maintaining a custom package format is real overhead. Probably better as a layer on top of Flatpak rather than a new format.

### #34: Voice-driven help

**Status:** idea
**Effort:** Multi-month

"Macrosofty, how do I print double-sided?" — answered locally via speech-to-text + small-LLM. No internet, no account. Pairs with the Local AI Helper (#6).

### #35: Multi-device profiles (sync)

**Status:** idea
**Effort:** Multi-month

Your wallpaper, themes, dock layout follow you. Sign in on a different Macrosofty machine, your stuff appears. Optionally encrypted-end-to-end via Tailscale or similar.

**Privacy challenge:** "your stuff in the cloud" is exactly what our brand promises against. Either we host it (becoming a service provider) or it's pure peer-to-peer (complex).

### #36: Built-in coding tutorial

**Status:** idea
**Effort:** Multi-month

A Codecademy-clone but installed, working offline, in our voice. Targets curious kids and self-learners.

**Risk:** content is the hard part — would partner with an educational org rather than build from scratch.

### #37: System health AI (proactive watcher)

**Status:** idea
**Effort:** Multi-month

Local model watches your system, notices "your laptop runs hot when you're on Zoom + Chrome", suggests "want to use Firefox for video calls?" — proactive, not reactive. Privacy-preserving (all local, like #6).

**Risk:** proactive AI suggestions can be intrusive. Default off, opt-in, with full kill-switch.

### #39: "Share & Serve" panel — host services from your desktop

**Status:** idea
**Audience:** hardware recycler (their old laptop becomes a server), relative-supporter (set up family media), prosumer (host their own stuff), anyone who's curious about a homelab but never knew where to start
**Effort:** Medium-large (2–4 months for a polished v1)
**Tier:** **2 — High-impact (would be transformative if it works)**

A first-class panel for **running personal services** from a regular Macrosofty desktop. Make Jellyfin / Syncthing / Pi-Hole / Vaultwarden / Immich as easy to set up as installing a Flatpak.

**Conceived 2026-04-26** during a brainstorming pass. Inspired by the founder's homelab work: the "wrapped in a friendly screen" pattern that made Proxmox/Immich/etc. setup actually pleasant. We can do that for personal-server services on a desktop OS — and nobody else does.

**The user experience:**

1. User opens "Share & Serve" panel from System Settings (or first-boot wizard suggests it).
2. Sees a curated grid of pre-configured services with short, plain descriptions:
   - **Jellyfin** — "Stream your movies and music to your TV, phone, and other computers"
   - **Syncthing** — "Keep folders synced between your devices, no cloud account needed"
   - **Pi-Hole** — "Block ads on every device on your wifi"
   - **Vaultwarden** — "Run your own password manager"
   - **Immich** — "Like Google Photos, but it stays on your computer"
   - **HomeAssistant** — "Smart-home dashboard"
   - **Audiobookshelf** — "Stream your audiobooks and podcasts"
   - **Nextcloud (AIO)** — "Your own cloud storage + calendar + contacts"
3. Click any service → a setup wizard:
   - Pick a storage folder ("where are your movies?" — file picker, defaults to `~/Media`)
   - Optionally set a name and password
   - Network setup: "Just my computers on this wifi" (mDNS, opens just LAN ports) or "Anywhere via Tailscale" (one-click Tailscale integration if configured) or "Public on the internet" (warning + Cloudflare Tunnel walkthrough)
   - Click "Set it up" → progress bar, ~30 seconds → done.
4. Service is now running. Panel shows "Jellyfin is running at `http://padkos.local:8096`. [Copy link] [Send to phone] [Stop service]".
5. Auto-starts on boot (systemd-managed). Updates auto via the same atomic-image-update story as the rest of the OS — except containerised services, which can update independently.

**What we ship:**
- A KCM (KDE Config Module) called Share & Serve.
- A curated catalog of ~10 services to start (the list above), each with a tested **podman Quadlet template** — declarative systemd unit + container spec.
- Storage chooser that handles permissions correctly (no "why can't Jellyfin see my files?" frustrations).
- mDNS broadcast (Avahi already on every edition) so other devices on the wifi find services without IP-typing.
- Optional firewall rule helpers (firewalld is already there).
- Optional Tailscale integration for sharing-beyond-the-wifi.
- A "stop" + "remove" + "update" UI per service.
- An "advanced mode" toggle for users who want to edit the Quadlet directly.

**Why this matters — the bigger product position:**

This turns Macrosofty from "a nice desktop Linux" into **"the friendly self-hosting OS"**. Currently the self-hosting space splits into:
- **Servers/NAS** (TrueNAS, unRAID, Synology DSM) — powerful, but you buy a separate machine, can't really use it for browsing/Netflix/work.
- **Desktop Linux** (Ubuntu, Fedora, etc.) — full desktops, but running services means CLI/Docker fluency.

**Macrosofty would be the first to make a regular laptop simultaneously the user's daily-driver desktop AND a friendly-to-set-up personal server.** That's a defensible niche. Hardware-recycler persona doubly benefits: the old laptop becomes a media server *and* still works for the user's basic browsing.

**The "share with peeps on the network" use case is the exact starter scenario:** someone has a folder of holiday videos, wants their family to watch on the TV. Today: install Jellyfin somehow, configure ports, type IP addresses to phones, hope it works. With Share & Serve: open panel, pick Jellyfin, point at folder, click set-up, copy `padkos.local:8096` to the family WhatsApp group.

**Implementation notes:**
- **Foundation:** podman Quadlets (systemd-managed containers via `.container` files in `/etc/containers/systemd/`). Aurora ships podman; Bazzite ships full container tooling. Already there.
- **Storage permissions:** containers need to read user's media folders. Two approaches: bind-mount with `:Z` SELinux relabel (simpler, slight permission warning) or rootless containers in user mode (more secure, more setup). Probably ship rootless-by-default with an "advanced" toggle.
- **Update story:** services are containers, so they update independently of the host atomic image. Run `podman auto-update` weekly via systemd timer; show the user "1 update available" in the panel.
- **Storage cleanup:** when a user removes a service, the panel asks "delete the data folder too?" — important so users don't accidentally lose their movies.

**Target editions:**
- All four KDE editions (and the future ARM Bokkie). Padkos's resource constraints might mean we recommend "stick to one or two services at a time on Padkos" but technically nothing stops it.
- Chunky-Modern is the natural fit (more RAM headroom; user is already a knowledge-worker).
- Hardware-recycler scenario maps mostly to Padkos / Chunky-LJ.

**Risks:**
- **Network configuration variability.** Some routers don't do mDNS well. Some ISPs block the standard ports. Need solid fallbacks (manual IP entry, Tailscale).
- **Container update failures** could leave a service in a bad state. The panel needs to show "this service crashed — see logs / restart / rollback".
- **Security.** Exposing services even on a LAN is more attack surface than a closed desktop. Default everything to LAN-only, require explicit user action to expose to the internet, big warnings around the public-internet option.

**Mzansi flavour notes:** The Tailscale integration is especially valuable for SA users with intermittent connectivity — your media server's accessible from anywhere even if your home IP changes constantly. Could lean into this in marketing.

**Open questions:**
- Curated 10 services or community-contributed catalog? (Recommend: start curated, expand to community-contributed in a later version after we've proven the model.)
- How much do we depend on Tailscale (Macrosofty's not associated with them) vs build our own networking abstractions?
- What's the relationship between Share & Serve and the existing "system update" flow — do they share UI patterns?

---

### #38: XFCE edition for sub-2 GB-RAM hardware

**Status:** parked (no demand evidence yet)
**Audience:** users with genuinely ancient hardware — pre-2010 laptops, 1–2 GB RAM, machines where even a stripped KDE struggles
**Effort:** Multi-month (forks the upstream story — no atomic XFCE base exists)

The 5th edition we deliberately deferred in `docs/iso-size-analysis.md` §5. Different audience from Padkos:

- **Padkos audience:** 4 GB RAM, 2014-era, runs KDE Plasma 6 well (validated in QEMU at 3 GB / 1 CPU on 2026-04-26 — "works like a bomb").
- **This edition's audience:** 1–2 GB RAM, pre-2010 hardware, KDE genuinely doesn't fit.

**Why it's parked, not active:**
- We have no evidence yet that anyone in this hardware tier is asking for Macrosofty. They might be served by Lubuntu / Xubuntu / Antix and not need us.
- Engineering cost is high (no atomic-XFCE upstream means we'd fork Fedora Kinoite directly, port Aurora's curation work for the XFCE world, maintain it ourselves).
- Brand cohesion takes a hit (different DE = different look = "this edition feels like a different OS").

**What would unpark it:**
- Repeated GitHub Discussions threads from users on 1–2 GB RAM machines saying "I'd use Macrosofty if you had a lighter edition".
- A community member volunteering to maintain the XFCE branch.
- A proven atomic-XFCE upstream emerging (currently doesn't exist).

**Possible names if it ever ships:** *Krummeltjie* (Afrikaans, "small piece/crumb"), *Spaarwiel* (spare wheel — the "still gets you home" vibe), *Boudjie*, *Sif* (Afrikaans informal for "lekker"). Just brainstorm; not chosen.

---

## How we update this list

- **Adding a new idea:** open a PR to this doc with the new entry. Default tier = 6 (stretch) until weighed; the maintainer can re-rank in review.
- **Reranking:** any maintainer can move items between tiers with a one-line justification in the commit message. No formal review needed for ranking shifts; the doc is meant to evolve.
- **Status changes:** when an idea moves to "planned" or "in-flight", create a tracking issue and link it from the entry. When something ships, mark it ✓ shipped + the version it shipped in, and leave the entry here for history.
- **Rejecting:** if an idea is dropped, mark it `parked` (might come back) or `rejected` (decided against, with reason). Don't delete — knowing what we *didn't* do is as useful as knowing what we did.
- **Linking to specs:** when a project starts, its detailed spec lives in `docs/projects/<name>.md` and the entry here points there.

---

## What's next from this list

Practical recommendation, given the current state of the project (v0.1 building, four editions, theme packs in place):

- **Land v0.1** (the four editions, branded, tested, public). Currently in progress.
- **v0.2 (1–3 months out):** ship **#1 (First-Boot Wizard)** and **#4 (Recovery button)**. Confirmed in conversation 2026-04-26. Both medium-or-smaller effort, both highest impact-per-effort, both addressable by one developer in available time. The wizard replaces Aurora's CLI-flavoured terminal motd; the recovery button surfaces the atomic-rollback superpower we already have but nobody knows about.
- **v0.3 (3–6 months out):** ship #2 (Make It Yours panel) — the brand-defining marquee feature.
- **v0.4 candidate (6–12 months out):** ship **#39 (Share & Serve panel)** — turns Macrosofty into "the friendly self-hosting desktop OS". Major engineering investment but a real product-positioning differentiator. Hardware-recycler persona scenario — "your old laptop is now your family's Jellyfin server" — is the headline use case.
- **In the background, rolling:** #5 (plain-language errors), #18 (why did this happen?), and the SA-specific Tier 5 items as the founder's energy and language partners allow.
- **Stretch: 1+ year out:** start sketching #6 (Local AI Helper). Mature LLM-quantization tooling and Plasma 6 stability would help here; both are improving fast.

**Validation note 2026-04-26:** Padkos boot-tested in QEMU at 1 CPU / 3 GB RAM and confirmed to work "like a bomb". This means the v0.1 four-edition lineup is structurally fine — the KDE-everywhere call holds and the XFCE-Padkos question is closed for v0.x. Rebrand polish + the v0.2 wizard work are the remaining gaps.

The ranking and the order may shift as we hear from real users. This list is an initial best-guess, not a contract.
