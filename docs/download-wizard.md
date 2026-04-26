# Download Wizard — decision tree

**Status:** v0.1 design sketch. Lives in this repo so adding/renaming an edition keeps the wizard in sync. Implementation lives in the website repo (`macrosofty/macrosofty-website`, private).

---

## Why a wizard

The four-card download page is fine for someone who already knows what they want. The intended Macrosofty audience often *doesn't* — they're Windows-fatigued, told by a friend "try Linux," and they have 15 minutes before they bounce. Asking them to rank-order Hearty / Chunky / Padkos / Braai when they don't know what KDE means is a real friction point.

The wizard turns four cards into a guided "answer three questions and we'll point you at the right one" flow. They can still pick manually if they want. The wizard is the easier path, not the only path.

---

## The flow (v0.1)

Three questions, plus a fourth that sets the format. Hardware, use, then connection.

### Q1 — How old is the computer you're putting this on?

| Answer | Implication |
|---|---|
| **Modern (last ~5 years)** | Any edition fits; hardware isn't the bottleneck → continue to Q2 |
| **Older (5–10 years)** | Steer toward Chunky-LJ (capable, lighter) or Padkos → continue to Q2 |
| **Quite old (10+ years, 4 GB RAM or less)** | **Recommend: Padkos.** Skip to Q4 (format). |
| **Not sure** | Treat as Modern — most people checking probably have something newer than they think |

### Q2 — What will you mainly do on it?

| Answer | Implication |
|---|---|
| **Browse, email, watch things, video calls** | **Recommend: Hearty.** (Padkos if Q1 was "quite old.") Skip to Q4. |
| **Real work — documents, spreadsheets, photos, light dev** | If Q1 = Modern: **Recommend: Chunky (Modern).** If Q1 = Older: **Recommend: Chunky (Long Journey).** Skip to Q4. |
| **Gaming — Steam, controllers, AAA titles** | If Q1 = Modern: **Recommend: Braai.** If Q1 = Older or Quite old: warn that gaming on older hardware will be limited; recommend trying Hearty first or Padkos. |
| **A bit of everything** | If Q1 = Modern: **Recommend: Chunky (Modern).** If Q1 = Older: **Recommend: Chunky (Long Journey).** If Q1 = Quite old: **Recommend: Padkos.** |

### Q3 — Skipped if Q1+Q2 already determined the answer

For most paths, Q1+Q2 narrows it to one edition. Q3 only fires if there's still ambiguity (e.g., Modern hardware + "a bit of everything" + user could go either way Hearty or Chunky).

### Q4 — How's your internet?

| Answer | Recommended format |
|---|---|
| **Fast and unlimited** | **Full ISO** (~5 GB; install offline) |
| **Slow or metered** | **Netinstall** (~150 MB to download; 5 GB pulled during install over wifi) |
| **None at install time** (offline laptop) | **Full ISO required.** Netinstall won't work without a connection at install. |

If Q1 = "Quite old" and Q4 = "Slow or metered": gentle nudge that Padkos's offline-first-boot promise (Firefox + LibreOffice ready without wifi) only applies to the Full ISO. Some old laptops without wifi credentials at firstboot will need the Full anyway.

---

## Outputs

After the wizard runs, the user sees:

> **We recommend: Macrosofty Padkos**
>
> *For older laptops that need to do the basics quickly and quietly.*
>
> [📥 Download Full ISO (4.6 GB)]   [⚡ Download Netinstall (~150 MB)]
>
> *Not what you wanted? Pick manually.* [link to the four-card page]

The recommended edition's card stays prominent; the format buttons make the netinstall vs full choice explicit. "Not what you wanted?" gives a non-judgmental escape hatch.

---

## Edge cases / fallbacks

- **User refuses to answer / closes wizard:** falls back to the four-card manual page.
- **No JavaScript:** wizard degrades to a static FAQ-style page (questions and answers visible, no dynamic switching). The four-card page is also reachable.
- **Privacy:** no data collection. The wizard runs entirely in the browser. Answers are not sent anywhere; recommendation logic is client-side. Page-view analytics stays at whatever the website already does (currently none).
- **Telemetry / tracking:** none. Per VISION.md and the broader "no telemetry, no accounts" promise, the wizard sends nothing — not even "user picked Padkos." If we want to know what the popular pick is in v0.2, that's a survey, not silent tracking.

---

## Decision-tree as data

For implementation, the wizard logic should live as a single JSON/TOML structure that both the website repo can render and this repo can validate. Sketch (not yet implemented):

```toml
[wizard]
version = "0.1"

[[wizard.questions]]
id = "hardware"
prompt = "How old is the computer you're putting this on?"
[[wizard.questions.options]]
label = "Modern (last ~5 years)"
value = "modern"
[[wizard.questions.options]]
label = "Older (5–10 years)"
value = "older"
[[wizard.questions.options]]
label = "Quite old (10+ years, 4 GB RAM or less)"
value = "quite_old"
implies_edition = "padkos"
implies_skip_to = "format"

[[wizard.recommendations]]
when = { hardware = "modern", use = "browse" }
edition = "hearty"

[[wizard.recommendations]]
when = { hardware = "modern", use = "work" }
edition = "chunky"

[[wizard.recommendations]]
when = { hardware = "older", use = "work" }
edition = "chunky-lj"

# ... etc
```

Both repos read the same file. Adding a 5th edition is one new question option + one new recommendation row, and both sides update together.

This is design-level for now — not landed. The first website implementation can hardcode the tree; we factor it out into shared data once we have a second consumer (e.g., Bazaar's "edition info" UI in v0.3).

---

## What's deferred

- **Localisation.** v0.1 is English-only. Afrikaans / SA-flavoured copy comes when the website is bilingual (post-v1 per CLAUDE.md).
- **Edition comparison page.** A "side-by-side compare" view for users who want detail before picking. Different shape from the wizard; useful for the analytical user, but not the audience the wizard targets. Future work.
- **"What's in this edition?" expandable details.** The wizard recommendation result could expand to show "Padkos comes with Firefox, LibreOffice, Thunderbird, ..." — useful but adds complexity. v0.2 if asked for.
