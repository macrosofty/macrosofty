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

if [ -d /ctx/system_files/shared ] && [ -n "$(ls -A /ctx/system_files/shared 2>/dev/null)" ]; then
    cp -r /ctx/system_files/shared/. /
fi

echo "::endgroup::"
