# ISO Size Analysis

**Status:** Analysis as of 2026-04-26. Living document — refresh whenever upstream Aurora's footprint shifts meaningfully or we change our build pipeline.

## The question that prompted this

Padkos's 2026-04-26 ISO came in at **5.0 GB** — *bigger* than Hearty's 4.8 GB. Padkos is supposed to be the "old hardware, light edition." The 187 MB delta in the wrong direction surfaced two questions:

1. Why is Padkos heavier than Hearty?
2. Why are our ISOs ~5 GB at all, when some Linux distros ship in 2–3 GB?

This document captures the audit answer in detail so we don't re-derive it next time the question comes up.

---

## TL;DR

- **Padkos > Hearty by 187 MB** because Padkos's `build.sh` adds Firefox RPM (~270 MB uncompressed → ~150 MiB compressed) plus the rpmdb side-effect of a `dnf install` (~115 MB uncompressed → ~35 MiB compressed). The strip commands in Padkos's `build.sh` produce **zero whiteouts** — they're all no-ops, because Aurora doesn't ship Krita/Kdenlive/digiKam/Akonadi/KMail/Kontact in the first place.
- **Our 5 GB total is normal for an atomic-KDE distro.** Kubuntu 24.04 is 4.6 GB; Bazzite KDE is 5–7 GB; Bluefin is 4–5 GB. The "Ubuntu is smaller" intuition is really "Lubuntu (LXQt) and Xubuntu (XFCE) are smaller" — those are 3 GB. Kubuntu, our actual peer, is the same ballpark as us.
- **Layered OCI images don't physically shrink when you `dnf remove` from a parent layer.** Removing a package adds a whiteout entry that hides the file at runtime; the parent-layer bytes stay in the OCI manifest and the ISO. Strips help installed-system size, not download size.
- **The single biggest lever for shrinking the ISO is the desktop environment.** KDE Plasma + Qt = ~770 MiB compressed. Switching to XFCE/LXQt would cut ~600 MB. Everything else (compression algo, dropping fonts, dropping Linuxbrew) is sub-200 MB territory.

---

## 1. Hard-data breakdown of Padkos

Methodology: pulled the OCI manifest with `skopeo inspect --raw` and the build history with `skopeo inspect --config`, then paired layer sizes against the build commands. Then downloaded just the final layer blob and ran `tar -tzvf` to inspect contents and look for whiteouts.

### 1.1 The 187 MiB Macrosofty layer (Padkos minus Hearty)

| Item | Uncompressed | Why |
|---|---|---|
| Firefox engine + langpacks | ~270 MB | `libxul.so` 161 MB; two `omni.ja` files 45 + 40 MB; ~100 langpack `.xpi` files; codecs; crashreporter |
| `usr/share/rpm/rpmdb.sqlite` (full rewrite) | 114 MB | RPM rewrites the entire database after any `dnf install`; the post-install rpmdb winds up in this layer |
| Other dnf transaction metadata | ~40 MB | Transaction history, libdnf5 SQLite WAL, log files, system-release marker |
| **Whiteout entries (deletions)** | **0 bytes** | **Zero whiteouts.** Every strip in `padkos/build.sh` is a no-op — none of `akonadi*`, `kmail*`, `kontact*`, `korganizer*`, `kaddressbook*`, `kalendar*`, `kdepim*`, `krita`, `kdenlive`, or `digikam` was ever installed in Aurora upstream. The `\|\| true` masks the "package not installed" exit code. |
| **Total uncompressed** | **~426 MB** | |
| **Total compressed (the layer blob)** | **187 MiB** | The OCI/ISO weight |

**Bonus finding:** Hearty's final layer is **0 bytes** — `dnf5 install -y tmux` did literally nothing because Aurora ships `tmux` already. Confirms the planned removal of the `tmux` line in Hearty's and Chunky's `build.sh`.

### 1.2 The other 3.7 GiB — full Padkos OCI breakdown

Aurora uses `rpm-ostree`-style **rechunking**: each layer is a coherent group of packages, named for what's in it (`dedi:meta:firmware`, `dedi:meta:kde`, etc.). Total of 75 layers in Padkos, 3,866 MiB compressed.

Bucketed by purpose:

| Bucket | Compressed size | What's in it |
|---|---|---|
| **Hardware & boot** | **~870 MiB** | `firmware` 375 (wifi/Bluetooth/GPU blobs for hundreds of cards), `initramfs` 232, `kernel` 197, `mesa` 52, `intel-driver` 15 |
| **KDE Plasma + Qt** | **~770 MiB** | `kde` 313, `qt6` 150, `kf6` 63, `qt6-base` 42, `plasma` 29, `qt5` 28, `kde-apps` 27, `kf5` 25, `ibus` 25, `gtk3` 9 |
| **Rechunked misc** | **~950 MiB** | ~40 small layers grouping minor RPMs (audio stack, NetworkManager, fish/zsh, KDE small tools, etc.) |
| **System libraries** | **~270 MiB** | `glibc` 82, `libgcc` 73, `llvm-libs` 49, `python3` 18, `python3-botocore` 16, ostree metadata 9, `qemu` 6 |
| **Aurora-specific extras** | **~285 MiB** | `homebrew` (Linuxbrew pre-installed!) 132, `rclone` 40, `mariadb` 39, `tailscale` 36, `argyllcms` 19, `vlc` 18, `git` 17 |
| **Internationalisation fonts** | **~227 MiB** | `google-fonts` (full Noto CJK + Balinese + Javanese + Sundanese set) |
| **Macrosofty layer** (Firefox + rpmdb) | **~187 MiB** | Our `build.sh` |
| **Unpackaged files** | **~134 MiB** | ostree boot config, generated `/etc`, branding overlays, plymouth theme |
| **Total** | **~3,866 MiB / 3.77 GiB** | |

ISO size (~5.0 GB) ≈ OCI image size (~3.77 GiB) + Anaconda/lorax/boot-loader overhead (~0.5–1 GiB).

---

## 2. Why our 5 GB is normal — peer comparison

Apples-to-apples LTS-era ISOs:

| Distro | ISO size | DE | Architecture |
|---|---|---|---|
| Ubuntu Server 24.04 | ~2.5 GB | none | Traditional installer, no GUI |
| Lubuntu 24.04 | ~3.0 GB | LXQt | Traditional installer |
| Xubuntu 24.04 | ~3.1 GB | XFCE | Traditional installer |
| **Kubuntu 24.04** | **~4.6 GB** | **KDE Plasma** | Traditional installer |
| Bluefin | ~4–5 GB | GNOME | Atomic / bootc |
| **Macrosofty (Hearty/Padkos)** | **~5.0 GB** | **KDE Plasma** | **Atomic / bootc** |
| Ubuntu Desktop 24.04 | ~5.7 GB | GNOME | Traditional installer |
| Bazzite KDE | ~5–7 GB | KDE Plasma | Atomic / bootc |
| Ubuntu Studio | ~6 GB | KDE + creative bundle | Traditional installer |

**The "Ubuntu is smaller" intuition is really "LXQt and XFCE Ubuntus are smaller."** The DE is the dominant variable. Kubuntu — our actual peer — is the same ballpark as us.

---

## 3. Architectural reasons KDE-atomic ISOs land at ~5 GB

### 3.1 The desktop environment is the single biggest fixed cost

| DE | Approximate compressed footprint |
|---|---|
| LXQt | ~150 MiB |
| XFCE | ~150–200 MiB |
| MATE | ~250 MiB |
| GNOME | ~700–900 MiB |
| **KDE Plasma + Qt5/6 + KF6** | **~770 MiB** |

We ship KDE Plasma deliberately — it's the brand promise (Windows-familiar layout, integrated theming, single-window/file-manager idiom). That's a fixed ~770 MiB. Same constraint Kubuntu/Aurora/Bluefin-DE/Bazzite all face.

### 3.2 Atomic + bootc OCI carries ~500 MiB–1 GiB of structural overhead

Traditional installers (Ubuntu, Fedora Workstation, Debian) ship:
- A small live `squashfs` for the installation environment.
- Package archives (`.deb` / `.rpm`) the installer apt/dnf-installs at install time, deduplicating against the system as it goes.

Our ISOs ship:
- The **entire deployed bootc OCI image** — every layer, every blob, the rpmdb snapshot, the ostree commit objects.
- The bootc deployer + Anaconda + lorax templates.

You pay this once, in exchange for "updates don't break" — the load-bearing promise. Strips help the deployed system but not the OCI image.

### 3.3 OCI layered images don't physically shrink when you `dnf remove`

This is the catch that confused us initially.

When `padkos/build.sh` runs `dnf5 -y remove krita`, **two things happen**:
1. At the OCI level: a "whiteout" entry is added to our top layer (a tiny metadata marker that hides Krita's files from the rootfs view).
2. At deploy time: ostree honours the whiteout when materialising the rootfs — Krita's files don't appear on the installed disk.

But the **original Krita bytes are still in Aurora's parent layer**, still in the OCI image, still in the ISO. There's no way to physically remove parent-layer content from a downstream layered image without re-baking the upstream.

So:
- **Installed-system size** (post-`bootc deploy` on the user's disk): WILL shrink with strips.
- **Download / ISO size**: will NOT shrink with strips.

This is why the `padkos/build.sh` strip lines, even if they were stripping real things, would never make Padkos's *ISO* smaller — only the runtime memory pressure on the installed machine.

### 3.4 i18n is bundled by default, not chosen at install

Aurora ships:
- Full Noto fonts including CJK + Balinese + Javanese + Sundanese (~227 MiB)
- Full `fcitx5` stack (Chinese, Korean, Vietnamese, Thai, Japanese — ~50 MiB)
- Tesseract OCR with 16 language packs (~100 MiB)

Ubuntu offers a language picker at install and downloads only what's chosen. We currently don't. ~350 MiB of our image is "every language for every user."

### 3.5 OCI default compression is gzip

The OCI image format defaults to gzip-compressed layers. Modern ISOs (Ubuntu, recent Fedora) use **zstd or xz on the squashfs**, which is 20–40% smaller for the same content. jasonn3 may or may not let us swap — needs investigation.

---

## 4. Levers we actually have to shrink the ISO

In rough order of payoff per unit of effort:

| Lever | Realistic saving | Effort | Impact |
|---|---|---|---|
| **Switch jasonn3 ISO compression** to zstd or xz, if supported | **~700 MiB–1 GiB** | Low — config flag if it exists; needs verification | Free win across all editions |
| **Build a "netinstall" ISO variant** (~150 MiB, pulls OCI from GHCR at install) | **Reduces download to ~150 MiB**; install requires internet | High — new ISO target, new install path, new docs | Best long-term answer for slow-connection users |
| **Drop Noto CJK fonts on non-international editions** | **~150 MiB** | Medium — would need to remove the package via `build.sh` strip; might require a font-only Aurora fork to actually shrink the ISO (whiteouts don't help) | Tradeoff: a Padkos user who happens to read Chinese mail can't render it. They'd have to install the font Flatpak-style |
| **Drop Linuxbrew on Padkos and Hearty** | **~130 MiB** | Medium — same caveat: whiteout doesn't shrink OCI, would need an Aurora fork or upstream PR | Padkos audience would never invoke `brew`; Hearty audience essentially never |
| **Drop Tesseract OCR language packs except `eng`** | **~80 MiB** | Medium | OCR tooling exists; non-English use cases lose default support |
| **Switch to a lighter DE on one or more editions** | **~600 MiB** per edition | Medium for the build, **high** for the brand identity | See §5 |
| Drop `mariadb`, `python3-botocore`, other niche deps | ~70 MiB combined | Medium | Low-risk if these aren't load-bearing for anything we ship |
| Switch `bootc-image-builder` ISO output format | Possibly meaningful | Unknown | Needs investigation |

The compression flag is the obvious first thing to check — biggest payoff per line of code. The netinstall variant is the obvious right answer for v0.2+ — the same approach Debian uses. Everything else is nibbling at the edges.

---

## 5. The DE question (resolved 2026-04-26 — KDE everywhere, revisit on evidence)

Switching the DE for one or more editions is the single biggest size lever. It's also the biggest brand-cohesion break — CLAUDE.md says "Four editions, one identity. Hearty, Chunky, Padkos, Braai all feel like Macrosofty. No edition is visually a different OS."

The specific candidate weighed: an XFCE-flavoured Padkos. Real considerations on both sides:

**For:** runtime weight on 4 GB-RAM hardware (KDE 6 idle ~400–600 MB vs XFCE ~250 MB), structurally honest delivery of "lighter than Hearty," recognition value among Linux-on-old-hardware users.

**Against:** breaks the "one identity" principle on sight (different panel idiom, file manager, settings UI). No upstream atomic XFCE base exists (Aurora is KDE, Bluefin is GNOME, Bazzite is KDE; Fedora's atomic spins are Silverblue + Kinoite, no XFCE) — we'd be doing original distro engineering rather than curation, violating CLAUDE.md's "inherit ruthlessly" principle. Significant ongoing maintenance for a love-project. **Crucially: we have no evidence yet that KDE Padkos actually struggles on the target hardware.**

**Resolution (2026-04-26):**
- **v0.1:** ship KDE Plasma on every edition. Boot-test Padkos on appropriate hardware. Brand cohesion + inherit-ruthlessly + no-premature-optimisation all pull the same direction.
- **v0.2 (contingent):** if real-user feedback after v0.1 shows KDE Padkos genuinely fails on its target hardware, the answer is **add a new lighter edition** (a 5th brand) rather than swap Padkos's DE underneath users. That preserves the four KDE-cohesive editions for everyone who's already on them, and gives a clean home for the lighter variant. The new edition would need its own food-themed name and a real upstream story — possibly forking Fedora atomic ourselves if no atomic-XFCE base has emerged by then.
- **Trigger to revisit:** repeated GitHub Discussions reports of "Padkos won't run on my X" with X being target Padkos hardware (4 GB RAM, 2014-era). One-off complaints aren't enough; a pattern is.

The smaller-download problem is solved separately via the netinstall variant (see §6). That gives slow-connection users a sub-200-MB install path without compromising the KDE identity on the running system.

---

## 6. Decisions and roadmap

**Locked 2026-04-26:**

1. **KDE Plasma on every edition for v0.1.** No XFCE/LXQt variants now. If v0.2 evidence shows the need for a lighter edition, add a *new* (5th) edition rather than swap Padkos's DE underneath users — see §5 for the full reasoning.
2. **ISO size optimisation is deferred to v0.2.** v0.1 ships at the natural Aurora-derived size (~5 GB) and we don't oversell "small download" in marketing. Reframe Padkos's promise from "smaller install" to "fast on old hardware" / "less default-app pressure" / "offline-first-boot" — promises we can actually deliver.
3. **A netinstall ISO variant is the planned answer for slow-connection users in v0.2.** ~150 MiB ISO that pulls the OCI image from GHCR at install time and runs `bootc switch` to deploy the right edition. Same install experience after the network step. Doesn't sacrifice the KDE identity on the running system.

**Cleanup work for v0.1 (truthfulness, not optimisation):**

4. **Drop the no-op strip lines from `padkos/build.sh`.** They produced zero whiteouts in the audit. Replace with a truthful comment that Aurora doesn't ship those packages upstream. *(Could also add real strips for Linuxbrew or CJK fonts here, but they'd only shrink installed-system size, not download size — see §3.3 for why.)*
5. **Drop the `tmux` install line from Hearty and Chunky `build.sh`.** Confirmed no-op against Aurora.

**v0.2 work (when we get there):**

6. **Investigate whether jasonn3 supports zstd/xz ISO compression.** Possible 700 MB–1 GB win across all editions if it works as a config flag.
7. **Build the netinstall variant.** Concretely: a tiny Anaconda-based ISO whose only job is to boot, run network setup, and `bootc switch ghcr.io/macrosofty/<edition>:latest` against a freshly partitioned disk. Same machinery we'd use for upgrades, just at install time. Edition picker happens during install rather than at download.

**Post-v1 maybes:**

8. **Revisit i18n bundling.** A language-picker in Anaconda could strip ~350 MiB of CJK fonts / Tesseract OCR languages / fcitx5 input methods that most users never need. This is an Aurora-fork-or-PR conversation; not low-hanging.

---

## 7. Methodology notes (so this can be reproduced)

To reproduce this analysis on a future image:

```bash
# Layer-size + history pairing
skopeo inspect --raw docker://ghcr.io/macrosofty/padkos:latest \
  | jq -r '.layers[] | .size' > /tmp/sizes.txt
skopeo inspect --config docker://ghcr.io/macrosofty/padkos:latest \
  | jq -r '.history[] | select(.empty_layer != true) | (.created_by // "—")' \
  | sed 's/[[:space:]]\+/ /g' > /tmp/cmds.txt
paste /tmp/sizes.txt /tmp/cmds.txt \
  | awk -F'\t' '{ printf "%6.1f MiB  %s\n", $1/1024/1024, $2 }' \
  | sort -rn

# Drill into a specific layer's contents (small download — single layer, not full image)
DIGEST=$(skopeo inspect --raw docker://ghcr.io/macrosofty/padkos:latest \
  | jq -r '.layers[-1].digest')
TOKEN=$(curl -s "https://ghcr.io/token?scope=repository:macrosofty/padkos:pull&service=ghcr.io" \
  | jq -r .token)
curl -sLo layer.tgz \
  -H "Authorization: Bearer $TOKEN" \
  "https://ghcr.io/v2/macrosofty/padkos/blobs/$DIGEST"
tar -tzvf layer.tgz | awk '{print $3, $NF}' | sort -rn | head -20
tar -tzvf layer.tgz | grep '\.wh\.'   # whiteout entries (deletions)
```

The whiteout grep is the load-bearing diagnostic — it's how we proved the strip commands were no-ops. If a future Padkos build *does* strip real content, the whiteouts will show up here.
