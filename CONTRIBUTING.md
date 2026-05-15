# Contributing to Macrosofty

Macrosofty is a love project with strong opinions. Contributions are welcome, and so is disagreement with our choices — but please read this first so we're all calibrated.

## The one-minute version

- **Bug report or "this doesn't work":** open an issue with clear reproduction steps.
- **"Have you thought about X":** open a GitHub Discussion in Ideas, not an issue.
- **Fix a bug or improve something:** PR welcome, no need to ask first.
- **Add a new app to an edition's defaults or remove one:** open a Discussion first — defaults are curated on purpose and shifts need buy-in.
- **New edition, new DE, new architecture:** please open a Discussion; we're likely to say no for v1, and we want to explain why.

## Scope — what gets accepted

**Yes, gladly:**
- Bug fixes
- Documentation improvements
- Boot / install / firstboot UX polish
- Accessibility improvements
- Translations (Afrikaans is first on the roadmap)
- Website fixes and copy improvements
- Upstream version bumps with verified testing
- Security fixes (though see `SECURITY.md` for coordinated disclosure)

**Probably no, but start a discussion:**
- New apps in default image (requires justification — we ship opinions)
- Removing apps from default image (same)
- New branding or visual identity changes
- Desktop environment alternatives (we ship KDE; alternatives make the project three times the work)

**No, thanks:**
- Anything that makes the image mutable or breaks rollback guarantees
- Telemetry, analytics, or "metrics" of any kind
- Anything that adds a required account (any required account)
- Ad platforms, affiliate code, sponsored-content features
- Custom forks of upstream components unless there is no other option (we'd rather file upstream)

## How to propose a change

### For code/config changes

1. **Fork** the repo.
2. **Branch** — use a short, descriptive name: `fix/hearty-boot-hang`, `docs/install-clearer`.
3. **Commit messages** — short subject (~60 chars), blank line, optional body explaining why. Imperative mood ("Fix X" not "Fixed X").
4. **PR** — link any related issue, describe what changed and why, call out any tradeoffs. If it's a user-facing change, screenshots help.
5. **Wait for review** — we're volunteer-driven. Be patient; feel free to ping after a week.

### For copy and docs

Same flow, lower ceremony. Typos and clarity fixes often get merged within a day.

### For the voice police

If a PR introduces text that **breaks the door metaphor** (says "Windows" or "Microsoft" in user-facing copy), reviewers will ask for a rewrite. This isn't us being precious — the joke only works if nobody spells it out. See `CLAUDE.md` for background.

## Testing expectations

For image changes:
- Build locally with `podman build` or `just build` (whatever the Makefile/justfile provides)
- Boot the image in a VM (at minimum: install from ISO, reboot, confirm login)
- If the change touches gaming, test with one Proton game and confirm Steam launches
- If the change touches rollback behaviour, test rollback

For docs / website changes: preview locally, confirm links don't 404.

We don't require comprehensive tests from contributors for small changes. We do require honest notes in the PR about what you tested and what you didn't.

## Style

- Commit messages, docs, code comments — conversational English, like this document. Not formal, not corporate.
- Write for the reader, not the author.
- "We" for the project, "you" for the user. Avoid passive voice.

## Licensing

By contributing, you agree your work is licensed under Apache 2.0 (same as the project). No CLA, no copyright assignment. Your commits stay in your name.

## Recognition

Contributors are listed in `CREDITS.md` (created during scaffold) and called out in release notes for meaningful changes. We're grateful for your time.

## When Things Go Wrong

If a PR is declined, we'll explain why. If you disagree, push back respectfully — we've been wrong before. But repeated re-submissions of the same rejected idea will be closed without discussion.

Code of conduct (`CODE_OF_CONDUCT.md`) applies to every interaction on this repo.
