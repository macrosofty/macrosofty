#!/usr/bin/env bash
#
# Padkos — older hardware / 4 GB RAM edition.
#
# Strategy: start from Aurora (same base as Hearty) and trim the heavier
# desktop apps an old laptop doesn't need on first boot. Anything we strip
# is one Discover/Flathub click away if the user wants it back.
#
# Conservative on purpose. Removing too much risks breaking the desktop;
# the doesn't-break property is load-bearing. We only trim well-known
# heavy apps with self-contained Flathub equivalents.

set -euo pipefail

echo "::group::Padkos build"

# --- Identity ---------------------------------------------------------------
/ctx/scripts/generate-os-release.sh padkos "${MACROSOFTY_VERSION:-0.1.0-dev}"

# --- Strip heavyweights -----------------------------------------------------
# `|| true` per group: if upstream Aurora drops one of these in the future,
# we don't want a missing package to fail the whole build. Each group is
# independently survivable.
#
# What we *don't* strip (despite earlier instinct): LibreOffice. Real-world
# testing on a fresh Padkos install (2026-04-25) confirmed the audience
# actually needs an office suite — "no office" is broken for the
# old-laptop / second-life user, not a feature. The disk weight (~700 MB)
# is fine on a 4 GB-RAM box; the runtime weight is zero unless they open it.

# KDE PIM stack (Akonadi, KMail, Kontact, KOrganizer, KAddressBook).
# Akonadi runs a per-user MariaDB-equivalent in the background; on a 4 GB
# box that's the single biggest "why is this slow" culprit, and the audience
# is more likely to use webmail than a desktop mail client anyway.
dnf5 -y remove \
    'akonadi*' \
    'kmail*' \
    'kontact*' \
    'korganizer*' \
    'kaddressbook*' \
    'kalendar*' \
    'kdepim*' \
    || true

# Heavy creative-pro apps — Flathub has current builds of all of these,
# one-click installable via Discover for the rare user who wants them.
dnf5 -y remove \
    krita \
    kdenlive \
    digikam \
    || true

# --- Essential additions ----------------------------------------------------
# Aurora ships Firefox as a Flatpak via firstboot, which depends on the
# firstboot service firing AND the user having internet at first login.
# For a "works on first boot, even offline" experience, we install the
# Firefox RPM directly. Slight divergence from Aurora's pattern but
# matches Padkos's promise: the laptop just works when you turn it on.
dnf5 -y install firefox || true

# --- Shared system files ----------------------------------------------------
# Same pattern as the other editions.

if [ -d /ctx/system_files/shared ] && [ -n "$(ls -A /ctx/system_files/shared 2>/dev/null)" ]; then
    cp -r /ctx/system_files/shared/. /
fi

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -q -t /usr/share/icons/hicolor/ 2>/dev/null || true
fi

# --- Tidy the package metadata ----------------------------------------------
dnf5 clean all

echo "::endgroup::"
