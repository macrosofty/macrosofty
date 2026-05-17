#!/usr/bin/env bash
#
# Chunky — power user / knowledge worker / light dev edition.
# Aurora DX base already includes distrobox, podman, VS Code, devcontainers.

set -euo pipefail

echo "::group::Chunky build"

# --- Identity ---------------------------------------------------------------
/ctx/scripts/generate-os-release.sh chunky "${MACROSOFTY_VERSION:-0.1.0-dev}"

# --- Packages ---------------------------------------------------------------
# Aurora DX does most of the heavy lifting — Cockpit, virt-manager, KVM,
# Docker, VS Code, podman-bootc, ROCm, bcc/bpftrace, and Aurora's full ~70-
# package base set on top (see docs/iso-size-analysis.md §3). We add only
# what's needed for our scripts.
#
#   jq                     — used by the macrosofty-theme apply script.
#   yad                    — firstboot welcome dialog (renders Tjopper
#                            inline, which kdialog cannot do).
#   git, python3,          — needed by install-apphelperthingy.sh to
#   desktop-file-utils,      clone the pinned AHT tag, build its venv,
#   gtk-update-icon-cache    refresh desktop + icon caches after install.
dnf5 install -y \
    jq \
    yad \
    git \
    python3 \
    desktop-file-utils \
    gtk-update-icon-cache

# --- Strip Aurora-specific welcome popups -----------------------------------
dnf5 -y remove plasma-welcome || true

# --- Bundle AppHelperThingy -------------------------------------------------
/ctx/scripts/install-apphelperthingy.sh

# --- Shared system files ----------------------------------------------------
if [ -d /ctx/system_files/shared ] && [ -n "$(ls -A /ctx/system_files/shared 2>/dev/null)" ]; then
    cp -r /ctx/system_files/shared/. /
fi

# --- Apply the default Macrosofty theme pack --------------------------------
macrosofty-theme apply saffron

# --- Scrub upstream branding ------------------------------------------------
/ctx/scripts/scrub-upstream-branding.sh "$EDITION"

echo "::endgroup::"
