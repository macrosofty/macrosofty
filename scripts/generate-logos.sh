#!/usr/bin/env bash
#
# generate-logos.sh — render Macrosofty logo assets from the master SVG
# into the build context where each edition's build.sh will pick them up.
#
# Host-time script. Run from anywhere in the project; produces:
#
#   system_files/shared/usr/share/macrosofty/logo.svg            (canonical SVG)
#   system_files/shared/usr/share/icons/hicolor/scalable/apps/macrosofty.svg
#   system_files/shared/usr/share/icons/hicolor/<size>x<size>/apps/macrosofty.png
#       for sizes: 16 24 32 48 64 96 128 192 256 384 512
#   system_files/shared/usr/share/pixmaps/macrosofty.png         (256, fallback)
#
# Idempotent. Re-run any time logo-master.svg changes.
#
# To extend with per-edition colour variants (v0.2 work):
#   1. Add the edition to the EDITIONS array below.
#   2. The COLOUR_<edition> map gives each edition its accent.
#   3. Output paths would shift to editions/<name>/files/usr/share/...
#      and each build.sh would `cp -r /ctx/edition/files/. /` after the
#      shared overlay. Not done in v0.1 — single saffron mark for everyone.

set -euo pipefail

# --- Paths ------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MASTER_SVG="$REPO_ROOT/branding/logo-master.svg"
SHARED="$REPO_ROOT/system_files/shared/usr/share"

if [ ! -f "$MASTER_SVG" ]; then
    echo "Error: $MASTER_SVG not found." >&2
    exit 1
fi

if ! command -v magick >/dev/null 2>&1; then
    echo "Error: ImageMagick (magick) not on PATH." >&2
    exit 1
fi

# --- Sizes used by the freedesktop.org hicolor icon theme spec --------------
SIZES=(16 24 32 48 64 96 128 192 256 384 512)

# --- Layout the output tree -------------------------------------------------
mkdir -p \
    "$SHARED/macrosofty" \
    "$SHARED/icons/hicolor/scalable/apps" \
    "$SHARED/pixmaps"

for s in "${SIZES[@]}"; do
    mkdir -p "$SHARED/icons/hicolor/${s}x${s}/apps"
done

# --- Install the SVG --------------------------------------------------------
cp "$MASTER_SVG" "$SHARED/macrosofty/logo.svg"
cp "$MASTER_SVG" "$SHARED/icons/hicolor/scalable/apps/macrosofty.svg"
echo "Installed scalable SVG"

# --- Render PNGs at every size ----------------------------------------------
for s in "${SIZES[@]}"; do
    out="$SHARED/icons/hicolor/${s}x${s}/apps/macrosofty.png"
    magick -background none "$MASTER_SVG" -resize "${s}x${s}" "$out"
    printf "  %3dx%-3d  %s\n" "$s" "$s" "${out#$REPO_ROOT/}"
done

# --- Pixmaps fallback (256, used by some legacy DMs / GRUB themes) ---------
cp "$SHARED/icons/hicolor/256x256/apps/macrosofty.png" "$SHARED/pixmaps/macrosofty.png"
echo "Installed pixmaps/macrosofty.png (256, fallback)"

echo
echo "Done. Run 'gtk-update-icon-cache' inside the image build if you want"
echo "the icon theme cache refreshed — each edition's build.sh handles that."
