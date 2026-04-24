#!/usr/bin/env bash
#
# Broth — older hardware / 4 GB RAM edition.
#
# STATUS: skeleton only. Base-image decision pending (see Containerfile).
# Once resolved, this script needs to:
#   - Install KDE Plasma (minimal, no full @kde-desktop group)
#   - Install Flatpak + Flathub remote
#   - Install a light browser default (e.g. firefox from Flathub)
#   - Enable SDDM
#   - Apply Macrosofty branding from /ctx/system_files/shared
#
# Intentionally left as a TODO rather than guessing. Broth is the edition most
# at risk of "doesn't break" regression if we wing the package set.

set -euo pipefail

echo "::group::Broth build (skeleton)"

echo "Broth build is not yet implemented. See editions/broth/Containerfile"
echo "for the open question on base image."
exit 1
