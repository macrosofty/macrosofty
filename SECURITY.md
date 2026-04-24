# Security Policy

Macrosofty is a small project. We take security seriously but we're not a company with a 24-hour pager rotation — please read the below before reporting.

## Reporting a vulnerability

**Do not open a public GitHub issue for security problems.** Instead:

- **Preferred:** Email `security@macrosofty.<tld>` (placeholder until scaffolding). Include:
  - A clear description of the issue
  - Steps to reproduce
  - Impact assessment (what can an attacker do?)
  - Any suggested fix
- **Backup:** Use GitHub's private vulnerability reporting on the repo

We will:
- **Acknowledge** within 7 days
- **Triage** and assign severity within 14 days
- **Patch and release** on a timeline matching severity (see below)
- **Credit you** in the release notes unless you ask to be anonymous

## Scope

**In scope:**
- The Macrosofty images themselves (Hearty, Chunky, Broth, Feast)
- Our build pipeline (GitHub Actions workflows, signing)
- Our website (static site) and any forms there
- Macrosofty-specific packages or scripts

**Out of scope (report upstream instead):**
- Vulnerabilities in Fedora, Bluefin, Bazzite, KDE, or any upstream package — these are best handled by their respective teams. We may fast-track a rebuild once a fix is available upstream.
- Vulnerabilities in third-party Flatpaks we ship — report to Flathub or the app maintainer.

## Severity and response times

| Severity | Example | Response target |
|---|---|---|
| Critical | Remote code execution, privilege escalation without interaction | Patch within 72 hours |
| High | Local privilege escalation, signing-key compromise | Patch within 7 days |
| Medium | Information disclosure, spoofing | Patch within 30 days |
| Low | Cosmetic security issues, hardening opportunities | Patch in next release |

"Response target" is when we aim to ship a patched image, not just acknowledge. **Best-effort, love-project caveat applies** — we'll do better than this if we can, and we'll be transparent if we can't meet it.

## Supply-chain security

- All images are signed via **Sigstore cosign keyless signing** using GitHub's OIDC token. Verification keys are in [`SIGNING.md`](./SIGNING.md) (placeholder until scaffolding).
- No human holds a private signing key. We cannot be compelled to sign a backdoored image because there is no persistent key to compel.
- Build logs are public (GitHub Actions).
- Every image build is reproducible from the Containerfile and pinned base image digests.

## What we won't do

- Pay bug bounties — we can't afford to. We will credit researchers generously in release notes.
- Sign NDAs or exclusive-disclosure contracts — security work is public-interest work.
- Take down disclosure posts — once we ship a fix, researchers are free to publish as they see fit.
