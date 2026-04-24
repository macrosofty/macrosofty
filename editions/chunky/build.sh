#!/usr/bin/env bash
#
# Chunky — power user / knowledge worker / light dev edition.
# Aurora DX base already includes distrobox, podman, VS Code, devcontainers.

set -euo pipefail

echo "::group::Chunky build"

# Aurora DX does most of the heavy lifting. Leave this minimal until we know
# a concrete gap we want to fill.
dnf5 install -y \
    tmux

if [ -d /ctx/system_files/shared ] && [ -n "$(ls -A /ctx/system_files/shared 2>/dev/null)" ]; then
    cp -r /ctx/system_files/shared/. /
fi

echo "::endgroup::"
