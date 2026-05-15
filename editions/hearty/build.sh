#!/usr/bin/env bash
#
# Hearty — the everyday edition.
# Aurora (KDE) base, plus a small handful of opinionated defaults.
# Philosophy: inherit ruthlessly, add only what earns its place.

set -euo pipefail

echo "::group::Hearty build"

# --- Identity ---------------------------------------------------------------
# Make the running system identify as Macrosofty Hearty rather than Aurora.
/ctx/scripts/generate-os-release.sh hearty "${MACROSOFTY_VERSION:-0.1.0-dev}"

# --- Packages ---------------------------------------------------------------
# Aurora already ships a full KDE desktop, Flatpak, codecs, and the sensible
# Universal Blue tooling — including tmux, vim, zsh, fish, htop, fastfetch,
# distrobox, and ~70 others (see docs/iso-size-analysis.md §3.1 for the full
# inherited set). We add only what's needed for our scripts.
#
#   jq                     — used by the macrosofty-theme apply script.
#   yad                    — used by the firstboot welcome dialog (renders
#                            Tjopper inline, which kdialog cannot do).
#   git                    — used by install-apphelperthingy.sh to clone
#                            the pinned AHT tag during this build.
#   python3                — needed by AHT's install-system.sh to build
#                            the bundled venv (Aurora ships python3 but
#                            we list it explicitly so the dependency is
#                            visible to anyone reading this file).
#   desktop-file-utils     — for update-desktop-database (AHT installer).
#   gtk-update-icon-cache  — refreshes the hicolor icon cache after AHT
#                            drops its icons into /usr/share/icons/.

dnf5 install -y \
    jq \
    yad \
    git \
    python3 \
    desktop-file-utils \
    gtk-update-icon-cache

# --- Strip Aurora-specific welcome popups -----------------------------------
# Aurora keeps `plasma-welcome` (KDE's first-launch tour with KDE/Aurora
# branding). We replace this experience later via our own "Make it yours"
# panel; for now strip to avoid the Aurora-branded greeting on first login.
dnf5 -y remove plasma-welcome || true

# --- Bundle AppHelperThingy -------------------------------------------------
/ctx/scripts/install-apphelperthingy.sh

# --- Shared system files ----------------------------------------------------
# Copy anything from /ctx/system_files/shared into the image rootfs. This
# includes the Macrosofty theme pack assets at
# /usr/share/macrosofty/themes/default/ and the macrosofty-theme apply
# script at /usr/bin/macrosofty-theme.

if [ -d /ctx/system_files/shared ] && [ -n "$(ls -A /ctx/system_files/shared 2>/dev/null)" ]; then
    cp -r /ctx/system_files/shared/. /
fi

# --- Apply the default Macrosofty theme pack --------------------------------
# Drops kickoff icon, wallpaper, MOTD, GRUB distributor, Plymouth theme,
# SDDM background, and (placeholder) Look-and-Feel. Re-runnable later by
# the user via `sudo macrosofty-theme apply <pack>` when "Make it yours"
# lands; same script either way.
macrosofty-theme apply default

# --- Scrub upstream branding from inherited menu items -----------------
# Rewrites "Aurora" → "Macrosofty" in the Name/Comment/etc. fields of
# inherited .desktop entries (e.g. "Aurora Offline Docs" → "Macrosofty
# Offline Docs"). Doesn't touch Exec= so the underlying program still
# launches fine.
/ctx/scripts/scrub-upstream-branding.sh "$EDITION"

# --- Services ---------------------------------------------------------------
# Leave upstream defaults alone unless we have a reason. Aurora's firstboot
# flow handles the rest.

echo "::endgroup::"
