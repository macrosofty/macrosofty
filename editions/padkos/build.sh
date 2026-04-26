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
# the resulting layer. Removed to stop pretending Padkos is structurally
# lighter than Hearty when we're inheriting Aurora unchanged.
#
# Padkos's actual differentiation lives elsewhere: offline-first-boot
# Firefox RPM (below), and the planned LibreOffice RPM (next change),
# plus reduced firstboot Flatpak pressure.
#
# If we ever want to genuinely shrink the deployed-system size (not the
# OCI image — see iso-size-analysis.md §3.3 for why), candidates that DO
# exist in Aurora upstream are: Linuxbrew (~132 MiB), Noto CJK fonts
# (~150 MiB), and the Tesseract OCR language packs except `eng` (~80 MiB).
# Keep this commented for the next maintainer to find.

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
