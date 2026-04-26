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

# --- Strip heavyweights (none, currently) ----------------------------------
# An OCI-layer audit on 2026-04-26 (docs/iso-size-analysis.md) proved that
# Aurora upstream does NOT ship any of: akonadi-server, kmail, kontact,
# korganizer, kaddressbook, kalendar, kdepim, krita, kdenlive, digikam.
# Earlier `dnf5 remove` calls for these were no-ops — zero whiteouts in
# the resulting layer.
#
# Padkos's actual differentiation lives elsewhere: offline-first-boot
# Firefox RPM (below) and reduced firstboot Flatpak pressure.

# --- Strip Aurora-specific welcome popups -----------------------------------
dnf5 -y remove plasma-welcome || true

# --- Essential additions ----------------------------------------------------
# Aurora ships Firefox as a Flatpak via firstboot, which depends on the
# firstboot service firing AND the user having internet at first login.
# For a "works on first boot, even offline" experience, we install the
# Firefox RPM directly. Same logic for the offline-first-boot promise —
# see docs/app-curation.md §4.4.
#
# `jq` is needed by the macrosofty-theme apply script below.
dnf5 -y install firefox jq || true

# --- Shared system files ----------------------------------------------------
# Includes the theme pack assets at /usr/share/macrosofty/themes/default/
# and the macrosofty-theme apply script at /usr/bin/macrosofty-theme.

if [ -d /ctx/system_files/shared ] && [ -n "$(ls -A /ctx/system_files/shared 2>/dev/null)" ]; then
    cp -r /ctx/system_files/shared/. /
fi

# --- Apply the default Macrosofty theme pack --------------------------------
# Kickoff icon, wallpaper, MOTD, GRUB distributor, Plymouth theme, SDDM
# background, Look-and-Feel. Re-runnable later by the user via
# `sudo macrosofty-theme apply <pack>` once we ship more packs.
macrosofty-theme apply default

# --- Tidy the package metadata ----------------------------------------------
dnf5 clean all

echo "::endgroup::"
