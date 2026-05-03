# Session Notes - 2026-05-04

## Summary

Designed and shipped **Tjopper**, the AppHelperThingy mascot — a friendly
cream blob standing in the Macrosofty archway, waving hello. Iterated
the canonical SVG from v1 through v13, built a seven-expression set
(idle, wave, thumbs, hmm, oops, sleep, heart), wrote `MASCOT.md` as the
usage guide, and committed three pushes to `github.com/macrosofty/apphelperthingy`.
All work was cross-repo from `macrosofty/` → `AppHelperThingy/`; the
macrosofty repo itself only gets these session notes.

## Changes Made

### AppHelperThingy — mascot design and asset pipeline
- **Locked v13 as canonical Tjopper.** Same archway path as the parent
  Macrosofty mark for sibling-brand cohesion. Cream body, peach cheeks,
  warm-amber arch, scale 1.30 with feet anchored at (200, 320) so head
  punches through the arch top and hand reaches past the right side.
- **Six-expression set**: idle, wave, thumbs, hmm, oops, sleep. Each
  variant changes only the face and hand — body and arch are constants
  to keep the silhouette consistent at all sizes.
- **Seventh expression added on user request**: heart. Cherry-red
  (#C41E3A) heart held in the raised hand, squinted love-eyes, big
  content smile. For about/credits screens, "made with lekker" footers,
  thank-you toasts, and easter-egg moments.
- **MASCOT.md written** as the source-of-truth usage guide: the cast
  table (when-to-use / don't-use), the Clippy-rule (Tjopper never pops
  up unbidden), voice samples for paired copy, file reference.
- **NEXT_SESSION.md updated** with a priority integration to-do list
  for the next AppHelperThingy session: favicon link, `.desktop` Icon=
  pointing at hicolor sizes, then SPA touchpoints (home view header,
  install-completed toast, long-running indicator, error modal, empty
  states).

### macrosofty — none beyond these session notes
No code or asset changes in this repo. Cross-repo work; the macrosofty
identity stayed untouched.

## Files Changed

**AppHelperThingy** (committed and pushed to origin/main, three commits):
- `branding/logo-master.svg` — canonical Tjopper SVG (~1.5 KB)
- `branding/icons/icon-{16,22,32,48,64,128,256,512}.png` — freedesktop sizes
- `branding/expressions/tjopper-{idle,wave,thumbs,hmm,oops,sleep,heart}.svg`
- `branding/expressions/png/tjopper-<expr>-{32,48,64,128,256}.png` — 35 PNGs total
- `branding/MASCOT.md` — usage guide
- `static/icon.svg` — copy of logo-master, for SPA / window icon
- `NEXT_SESSION.md` — added priority integration section

**Commits**: `d03dcc3` (mascot + 6 expressions), `ceec7ba` (heart added),
`19b5a81` (heart bigger + deeper red).

## Technical Decisions

- **Name = Tjopper.** SA-flavour diminutive of "chop." Affectionate;
  ties to the Braai edition voice without overlapping. Internal design
  polestar is "what Clippy would have been if he were a love project,"
  but the rival's name is never written in user-facing copy.
- **Mascot baseline silhouette.** Tried adding a distinctive feature
  (antenna / tuft / single ear) for 16px legibility — user rejected all
  three. Solved instead by **scaling Tjopper to 1.30× anchored at the
  feet** so his head punches through the arch top and the hand reaches
  past the right side. Asymmetric overlap = unmistakable silhouette.
- **Drawing-order discipline.** Arch is drawn first, then Tjopper on
  top via `<g transform="rotate(2.5 200 320) translate(200 320) scale(1.30) translate(-200 -320)">`.
  All expression variants share that exact transform string. Anything
  that should NOT scale/rotate with him (e.g. the sleep `<text>"z"`)
  goes OUTSIDE the group.
- **Six expressions is the sweet spot.** Diminishing returns past that
  — Tux is 1, Clippy was ~6 and only two are remembered. Three
  follow-ups (`shrug`, `scanning`, `bye`) noted in NEXT_SESSION.md but
  flagged "don't pre-build, only on demand."
- **Voice rule re-affirmed**: never name the rival in code, comments,
  filenames, or copy. The Clippy comparison stays an internal-only
  design polestar.

## Known Issues / Follow-up

- **Macrosofty identity** could optionally adopt a Tjopper variant for
  the parent OS (e.g. on the welcome screen of a fresh install) — not
  scoped this session, left as a future open question.
- **Three follow-up expressions** — `shrug` / `scanning` / `bye` —
  noted but not built. Add only when a concrete screen requires them.
- **Cross-repo memory.** This session's design decisions are now on
  disk in `/var/mnt/code/AppHelperThingy/branding/MASCOT.md`. If we
  spin up a new satellite project that needs a similar mascot, the
  scaffolder doesn't currently know about MASCOT.md as a template.
  Could be a future scaffolder enhancement.
- **AppHelperThingy integration** of Tjopper (favicon, .desktop, SPA
  touchpoints) is the next session's priority list — done in a fresh
  Claude session inside `/var/mnt/code/AppHelperThingy/` so its
  CLAUDE.md (different non-negotiables) loads correctly.
