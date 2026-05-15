#!/usr/bin/env bash
#
# install-apphelperthingy.sh — bundle AppHelperThingy into the OCI image.
#
# Called from each edition's build.sh during container build:
#     /ctx/scripts/install-apphelperthingy.sh
#
# Pinned by APPHELPERTHINGY_VERSION + APPHELPERTHINGY_RELEASE_REPO in
# config/identity.env. Hard-fails on any error — a broken AHT install
# means the OCI build fails and the previous green image stays in
# ghcr.io. That's the desired blast radius (see MACROSOFTY_BUNDLING.md
# in the AHT repo for the full contract).
#
# How it works:
#   1. Download the pinned-version AppImage + SHA256SUMS from the public
#      mirror repo (no auth — the source repo is private but the binary
#      mirror is public, by design).
#   2. Verify SHA256 against the published checksum. Mismatch → exit.
#   3. `--appimage-extract` the AppImage into a tmpdir (no FUSE needed;
#      type-2 AppImages self-extract). Move the AppDir to
#      /usr/lib/apphelperthingy/.
#   4. Drop a small wrapper at /usr/bin/apphelperthingy that exec's the
#      bundled AppRun. We use a wrapper rather than a symlink so AppRun's
#      $0/dirname logic always sees its real install dir, not /usr/bin/.
#   5. Copy the AppImage's icon-theme tree into /usr/share/icons/hicolor/
#      so the `Icon=apphelperthingy` reference in our .desktop launchers
#      resolves.
#
# What we DON'T install:
#   - The AppImage's own /usr/share/applications/apphelperthingy.desktop —
#     Macrosofty ships its own launchers via system_files/shared/:
#       * Help              → apphelperthingy %u
#       * Discover Apps     → apphelperthingy --page=catalogue
#       * System Health     → apphelperthingy --page=health
#       * AppHelperThingy   → apphelperthingy   (whole-app, top-level)
#     The first three deep-link into pages; the fourth is the dashboard
#     entry under its full brand name.

set -euo pipefail

# --- Source brand identity for the pinned version + mirror repo -----------
if [ -r /ctx/config/identity.env ]; then
    # shellcheck disable=SC1091
    . /ctx/config/identity.env
elif [ -r "$(dirname "$0")/../config/identity.env" ]; then
    # shellcheck disable=SC1091
    . "$(dirname "$0")/../config/identity.env"
else
    echo "install-apphelperthingy.sh: cannot find config/identity.env" >&2
    exit 1
fi

: "${APPHELPERTHINGY_VERSION:?must be set in config/identity.env}"
: "${APPHELPERTHINGY_RELEASE_REPO:?must be set in config/identity.env}"

APPIMAGE_NAME="AppHelperThingy-x86_64.AppImage"
BASE_URL="https://github.com/${APPHELPERTHINGY_RELEASE_REPO}/releases/download/${APPHELPERTHINGY_VERSION}"
APPIMAGE_URL="${BASE_URL}/${APPIMAGE_NAME}"
SHA256SUMS_URL="${BASE_URL}/SHA256SUMS"

INSTALL_DIR="/usr/lib/apphelperthingy"
WRAPPER="/usr/bin/apphelperthingy"

echo "::group::AppHelperThingy install ($APPHELPERTHINGY_VERSION)"
echo "Source: $APPIMAGE_URL"

# --- Fetch + verify -------------------------------------------------------
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

curl --fail --location --silent --show-error \
    --output "$TMPDIR/$APPIMAGE_NAME" "$APPIMAGE_URL"
curl --fail --location --silent --show-error \
    --output "$TMPDIR/SHA256SUMS" "$SHA256SUMS_URL"

( cd "$TMPDIR" && sha256sum -c SHA256SUMS )

# --- Extract --------------------------------------------------------------
chmod +x "$TMPDIR/$APPIMAGE_NAME"
( cd "$TMPDIR" && "./$APPIMAGE_NAME" --appimage-extract >/dev/null )
[ -d "$TMPDIR/squashfs-root" ] || {
    echo "AppImage extraction did not produce squashfs-root/" >&2
    exit 1
}
[ -x "$TMPDIR/squashfs-root/AppRun" ] || {
    echo "Extracted AppDir is missing executable AppRun" >&2
    exit 1
}

# --- Install AppDir to /usr/lib/apphelperthingy/ ------------------------------
# Wipe-and-replace if a previous version is somehow present (shouldn't
# happen in a fresh OCI build, but defensive — keeps the result identical
# regardless of base-image state).
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cp -a "$TMPDIR/squashfs-root/." "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/AppRun"

# --- Wrapper at /usr/bin/apphelperthingy ----------------------------------
cat > "$WRAPPER" <<EOF
#!/bin/sh
exec ${INSTALL_DIR}/AppRun "\$@"
EOF
chmod +x "$WRAPPER"

# --- Icon theme -----------------------------------------------------------
# The AppDir ships a full freedesktop hicolor tree at usr/share/icons/
# (16, 22, 32, 48, 64, 128, 256, 512). Copy it into the system icon
# theme so Icon=apphelperthingy in our 3 .desktop launchers resolves
# under KDE, GNOME, XFCE, etc.
if [ -d "$INSTALL_DIR/usr/share/icons/hicolor" ]; then
    mkdir -p /usr/share/icons/hicolor
    cp -a "$INSTALL_DIR/usr/share/icons/hicolor/." /usr/share/icons/hicolor/
fi

echo "::endgroup::"
