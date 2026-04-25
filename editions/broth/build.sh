#!/usr/bin/env bash
#
# Broth — older hardware / 4 GB RAM edition.
#
# Strategy: start from Aurora (same base as Hearty) and trim the heavier
# desktop apps an old laptop doesn't need on first boot. Anything we strip
# is one Discover/Flathub click away if the user wants it back.
#
# Conservative on purpose. Removing too much risks breaking the desktop;
# the doesn't-break property is load-bearing. We only trim well-known
# heavy apps with self-contained Flathub equivalents.

set -euo pipefail

echo "::group::Broth build"

# --- Strip heavyweights -----------------------------------------------------
# `|| true` per group: if upstream Aurora drops one of these in the future,
# we don't want a missing package to fail the whole build. Each group is
# independently survivable.

# Office suite — heavy on disk and RAM. Flathub's LibreOffice is current,
# self-contained, and a one-click install for users who want it back.
dnf5 -y remove 'libreoffice*' || true

# KDE PIM stack (Akonadi, KMail, Kontact, KOrganizer, KAddressBook).
# Akonadi runs a per-user MariaDB-equivalent in the background; on a 4 GB
# box that's the single biggest "why is this slow" culprit.
dnf5 -y remove \
    'akonadi*' \
    'kmail*' \
    'kontact*' \
    'korganizer*' \
    'kaddressbook*' \
    'kalendar*' \
    'kdepim*' \
    || true

# Heavy creative apps — Flathub has current builds of all of these.
dnf5 -y remove \
    krita \
    kdenlive \
    digikam \
    || true

# --- Light additions --------------------------------------------------------
# Nothing yet. Hearty's 'tmux' line is intentionally not mirrored — Broth's
# audience is least likely to open a terminal. Keep the surface small.

# --- Shared system files ----------------------------------------------------
# Same pattern as the other editions.

if [ -d /ctx/system_files/shared ] && [ -n "$(ls -A /ctx/system_files/shared 2>/dev/null)" ]; then
    cp -r /ctx/system_files/shared/. /
fi

# --- Tidy the package metadata ----------------------------------------------
dnf5 clean all

echo "::endgroup::"
