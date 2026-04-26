#!/usr/bin/env bash
#
# Braai — gaming edition.
# Bazzite already ships Steam, Proton, gamescope, MangoHud, the HDR stack,
# controller drivers, and the tuning for handhelds + desktop. Our job here
# is a light touch: Macrosofty branding, not reinventing what Bazzite does.

set -euo pipefail

echo "::group::Braai build"

# --- Identity ---------------------------------------------------------------
/ctx/scripts/generate-os-release.sh braai "${MACROSOFTY_VERSION:-0.1.0-dev}"

# --- Packages ---------------------------------------------------------------
# Bazzite already does the gaming heavy lifting (Steam, Proton, gamescope,
# MangoHud, controllers). We add only what's needed for our scripts.
# Bazzite already strips plasma-welcome upstream so no removal needed here.
dnf5 install -y \
    jq

# --- Shared system files ----------------------------------------------------
if [ -d /ctx/system_files/shared ] && [ -n "$(ls -A /ctx/system_files/shared 2>/dev/null)" ]; then
    cp -r /ctx/system_files/shared/. /
fi

# --- Apply the default Macrosofty theme pack --------------------------------
macrosofty-theme apply default

echo "::endgroup::"
