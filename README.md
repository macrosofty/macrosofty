# 🍲 Macrosofty

**A Linux that doesn't suck.**

No ads. No accounts. No nonsense. A computer that respects you.

*"We open the door — not just a window to peek through."*

---

## What this is

Macrosofty is a Linux distribution for ordinary humans. It's built on **Universal Blue + Fedora Atomic Desktop** — the same doesn't-break foundation that Bazzite, Bluefin, and Aurora ride.

We don't reinvent. We curate. The plumbing is theirs. The friendly face is ours.

## What you get

| Edition | For | Base |
|---|---|---|
| 🍲 **Hearty** | Everyday use — browser, email, photos, Netflix, printing | Aurora |
| 🍖 **Chunky** | Real work — office, dev tools, more muscle | Aurora-DX |
| 🥣 **Broth** | Older laptops, 4 GB RAM, second-life machines | Aurora (stripped) |
| 🍷 **Feast** | Gaming — Steam, Proton, controllers, all of it | Bazzite |

🐰 **Bokkie** (Pi 5 / ARM) is a tentative post-v1 stretch. The honest answer for now is "still coming."

## What we promise

- **Free for everyone. Forever.**
- No ads. No telemetry. No accounts required. Ever.
- A system that updates itself and rolls back when it shouldn't.
- One identity across all four editions. They're cousins, not strangers.
- **Peace, not war.** If your current OS works for you, enjoy it. We're an alternative, not a protest.

## Status — building in the open

There's no installable image yet. When there is, we'll say so loudly. Until then this repo holds the plan, the scaffolding, and the trail of decisions.

- [`VISION.md`](./VISION.md) — what we're building, who it's for, what it isn't.
- [`CLAUDE.md`](./CLAUDE.md) — how we work on it.
- [`editions/`](./editions/) — Containerfiles per edition.
- [`website/`](./website/) — the (forthcoming) landing page.

To follow along, **watch this repo**. Discussions go live around v0.1.

## The shoulders we stand on

This project would be ~10× the work without:

- [Universal Blue](https://universal-blue.org/) — Bluefin, Aurora, Bazzite. The atomic-desktop reality.
- [Fedora Project](https://fedoraproject.org/) — the underlying OS.
- [Flatpak](https://flatpak.org/) and [Flathub](https://flathub.org/) — the app store that just works.
- [bootc](https://github.com/containers/bootc), [rpm-ostree](https://coreos.github.io/rpm-ostree/), [cosign](https://github.com/sigstore/cosign).

See [`ATTRIBUTION.md`](./ATTRIBUTION.md) for the full list.

## Reading

- [`CONTRIBUTING.md`](./CONTRIBUTING.md) — PR process. What we accept, what we don't.
- [`CODE_OF_CONDUCT.md`](./CODE_OF_CONDUCT.md) — be kind. That's the rule.
- [`SECURITY.md`](./SECURITY.md) — found a hole? Tell us privately.
- [`SIGNING.md`](./SIGNING.md) — how to verify a build is ours.
- [`docs/app-curation.md`](./docs/app-curation.md) — what ships in each edition, and the process to change it.

## License

Apache 2.0. See [`LICENSE`](./LICENSE).

---

*Made with lekker in Mzansi · Free for everyone. Forever.*

*The door is always open.*
