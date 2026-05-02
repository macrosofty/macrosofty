# Session Notes — 2026-05-02

## Summary

Wrote the satellite-project scaffolder for the Macrosofty org
(`scripts/new-project.sh` + `scripts/templates/`). Also wrote the
sibling AppHelperThingy's `CLAUDE.md` and seeded its per-project
memory — both done from this session but landed in their respective
repos.

## Changes Made

### Macrosofty: satellite-project scaffolder (committed bde0050, pushed)

- New `scripts/new-project.sh` (222 lines, executable). Three required
  args: `<slug> "<Title>" "<one-line description>"`. Flags:
  `--public` (override default-private), `--no-remote` (skip GitHub
  step), `--parent <dir>` (default `/var/mnt/code`).
- 7 templates under `scripts/templates/` with `{{SLUG}}`, `{{TITLE}}`,
  `{{DESCRIPTION}}`, `{{TODAY}}` placeholders:
  `CLAUDE.md.tmpl` (voice + principles inherited from Macrosofty),
  `README.md.tmpl`, `ROADMAP.md.tmpl` (Tier 1/2/3/brainstorm/won't-do
  scaffold), `NEXT_SESSION.md.tmpl` (paste-ready kickoff prompt),
  `CONTRIBUTING.md.tmpl`, `SESSION_NOTES.md.tmpl` (kickoff session
  note), `gitignore.tmpl`.
- LICENSE copied verbatim from `macrosofty/LICENSE` (Apache-2.0) at
  scaffold time, not templated.
- `scripts/README.md` got an "Org tooling" section so the script is
  discoverable.
- End-to-end dry-run verified: `--no-remote --parent /tmp` produced
  8 substituted files + clean git commit.

### AppHelperThingy: CLAUDE.md + per-project memory (separate repo)

- Wrote `/var/mnt/code/AppHelperThingy/CLAUDE.md` (sibling-project
  framing, voice rules inherited from Macrosofty, 8 core principles,
  tech stack table, repo layout, dev workflow, runtime quirks,
  should/shouldn't lists).
- Created `/home/elje/.claude/projects/-var-mnt-code-AppHelperThingy/memory/`
  with `MEMORY.md` index + 7 files: `user_profile.md`,
  `feedback_voice.md`, `feedback_session_notes.md`,
  `feedback_no_premature_abstractions.md`, `project_state.md`,
  `project_next_session.md`, `reference_paths.md`,
  `reference_runtime_quirks.md`. (User has since updated several of
  these in a later sub-session — the 2026-05-03 state with seven Tier
  4 wins + 16 routers + snap catalogue is the current truth.)

## Files Changed

**New (this commit, in macrosofty):**
- `scripts/new-project.sh`
- `scripts/templates/CLAUDE.md.tmpl`, `README.md.tmpl`, `ROADMAP.md.tmpl`,
  `NEXT_SESSION.md.tmpl`, `CONTRIBUTING.md.tmpl`,
  `SESSION_NOTES.md.tmpl`, `gitignore.tmpl`

**Modified:**
- `scripts/README.md` — added "Org tooling" section + templates note

**Outside this repo (related work):**
- `/var/mnt/code/AppHelperThingy/CLAUDE.md` (new)
- `/home/elje/.claude/projects/-var-mnt-code-AppHelperThingy/memory/*` (8 files)

## Technical Decisions

- **Lives in macrosofty repo, not its own repo.** It's org-meta tooling;
  putting it in `macrosofty/scripts/` keeps it co-located with the
  other host-time scripts (logo gen, image verify) and avoids a
  separate repo for a single bash script.
- **Default `--private` on the GitHub repo.** The user explicitly
  asked for this mid-session. `--public` is the override flag.
- **Prefer `gh`, fall back to GitHub REST API via curl.** The user
  installed gh via `rpm-ostree install gh` but on Bazzite that needs
  a reboot to activate, not just a shell restart. Rather than block
  on that, the script tries `gh repo create --private --source=. --push`
  first, then falls back to a curl `POST /orgs/macrosofty/repos`
  using `$GITHUB_TOKEN` from `~/.config/macrosofty/load-tokens.sh`.
  Either path works today.
- **Templates substitute via Python heredoc, not sed.** Sed is fine
  for simple replacements but the descriptions contain quotes,
  apostrophes, and shell metacharacters. Python `str.replace()` is
  bulletproof and is already a dep of any Macrosofty dev environment.
- **MVP is docs-only — no FastAPI/SPA app skeleton.** Most items on
  the value-adds roadmap (KDE applets, systemd services, CLIs,
  Flatpaks) won't be FastAPI apps. Adding a `--type app` flag that
  drops in an AHT-shaped skeleton is a clean follow-up when the first
  new app project comes up.
- **`originSessionId` field in memory frontmatter** is added by the
  runtime, not by us. Don't strip it on subsequent edits.

## Known Issues / Follow-up

- **`gh` install on this host still pending a reboot.** Until then
  the script transparently uses the curl fallback — no functional gap
  but worth knowing.
- **No `--type app` flag yet.** When the first satellite project
  needs the FastAPI + single-file SPA + `app/`-package shape, lift
  the skeleton from AppHelperThingy into `scripts/templates/app/` and
  add the flag. Don't do it speculatively.
- **Scaffolded `CLAUDE.md.tmpl` cross-references AppHelperThingy** by
  filesystem path (`/var/mnt/code/AppHelperThingy/`). If/when AHT
  moves under the macrosofty org on GitHub, the URL refs in
  `README.md.tmpl` ("https://github.com/macrosofty/AppHelperThingy")
  start working; the filesystem ref keeps working regardless.
- **`.claude/` is untracked and intentionally so** — it's local-only
  Claude state. The scaffolder's `gitignore.tmpl` includes it for new
  projects.
