#!/usr/bin/env bash
#
# Hearty — the everyday edition.
# Aurora (KDE) base, plus a small handful of opinionated defaults.
# Philosophy: inherit ruthlessly, add only what earns its place.

set -euo pipefail

echo "::group::Hearty build"

# --- Identity ---------------------------------------------------------------
# Make the running system identify as Macrosofty Hearty rather than Aurora.
/ctx/scripts/generate-os-release.sh hearty "${MACROSOFTY_VERSION:-0.1.0-dev}"

# --- Packages ---------------------------------------------------------------
# Kept deliberately short. Aurora already ships a full KDE desktop, Flatpak,
# codecs, and the sensible Universal Blue tooling. Every line added here is a
# line we commit to maintaining.

dnf5 install -y \
    tmux

# --- Shared system files ----------------------------------------------------
# Copy anything from /ctx/system_files/shared into the image rootfs.
# Directory is allowed to be empty during scaffold.

if [ -d /ctx/system_files/shared ] && [ -n "$(ls -A /ctx/system_files/shared 2>/dev/null)" ]; then
    cp -r /ctx/system_files/shared/. /
fi

# --- Services ---------------------------------------------------------------
# Leave upstream defaults alone unless we have a reason. Aurora's firstboot
# flow handles the welcome experience.

echo "::endgroup::"
