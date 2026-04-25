#!/usr/bin/env bash
#
# Chunky — power user / knowledge worker / light dev edition.
# Aurora DX base already includes distrobox, podman, VS Code, devcontainers.

set -euo pipefail

echo "::group::Chunky build"

# --- Identity ---------------------------------------------------------------
/ctx/scripts/generate-os-release.sh chunky "${MACROSOFTY_VERSION:-0.1.0-dev}"

# Aurora DX does most of the heavy lifting. Leave this minimal until we know
# a concrete gap we want to fill.
dnf5 install -y \
    tmux

if [ -d /ctx/system_files/shared ] && [ -n "$(ls -A /ctx/system_files/shared 2>/dev/null)" ]; then
    cp -r /ctx/system_files/shared/. /
fi

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -q -t /usr/share/icons/hicolor/ 2>/dev/null || true
fi

echo "::endgroup::"
