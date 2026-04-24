#!/usr/bin/env bash
#
# Feast — gaming edition.
# Bazzite already ships Steam, Proton, gamescope, MangoHud, the HDR stack,
# controller drivers, and the tuning for handhelds + desktop. Our job here
# is a light touch: Macrosofty branding, not reinventing what Bazzite does.

set -euo pipefail

echo "::group::Feast build"

if [ -d /ctx/system_files/shared ] && [ -n "$(ls -A /ctx/system_files/shared 2>/dev/null)" ]; then
    cp -r /ctx/system_files/shared/. /
fi

echo "::endgroup::"
