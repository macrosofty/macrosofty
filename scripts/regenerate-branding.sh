#!/usr/bin/env bash
#
# regenerate-branding.sh — re-render every brand-derived PNG/SVG from
# its canonical source.
#
# Run this after editing any of:
#   branding/logo-master.svg                       (the doorway icon)
#   branding/themes/saffron/source/wallpaper.svg   (default dark wallpaper)
#   branding/themes/tjopper/source/background.svg  (Tjopper-pack wallpaper bg)
#   branding/tjopper/anaconda-header.svg           (Anaconda header banner)
#   branding/tjopper/tjopper-*.svg                 (Tjopper expressions; wave
#                                                   is also composited into
#                                                   the Tjopper wallpaper)
#
# Idempotent. Re-running with no source changes overwrites with bit-
# equivalent output (modulo PNG mtime / sub-pixel rounding).
#
# What it does NOT touch:
#   - config/identity.env brand strings — those are picked up at OCI
#     build time (generate-os-release.sh, scrub-upstream-branding.sh)
#     and at netinstall ISO build time (rebrand-netinstall-iso.sh).
#     No host-time regen is required for string changes.
#   - system_files/shared/usr/share/macrosofty/themes/saffron/icons/
#     start-here-*.svg — these are hand-tuned for the kickoff-icon
#     context (different viewBox for the symbolic variant). Edit the
#     SVGs directly.
#   - branding/iterations/ — design history, not consumed by the build.
#
# See branding/README.md for the full source-to-derived map.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHARED="$REPO_ROOT/system_files/shared/usr/share"

LOGO_MASTER="$REPO_ROOT/branding/logo-master.svg"
WALLPAPER_SVG="$REPO_ROOT/branding/themes/saffron/source/wallpaper.svg"
ANACONDA_HEADER_SVG="$REPO_ROOT/branding/tjopper/anaconda-header.svg"
TJOPPER_SRC_DIR="$REPO_ROOT/branding/tjopper"
TJOPPER_BG_SVG="$REPO_ROOT/branding/themes/tjopper/source/background.svg"
TJOPPER_WAVE_SVG="$TJOPPER_SRC_DIR/tjopper-wave.svg"

# --- Sanity checks ---------------------------------------------------------

for f in "$LOGO_MASTER" "$WALLPAPER_SVG" "$ANACONDA_HEADER_SVG" "$TJOPPER_BG_SVG" "$TJOPPER_WAVE_SVG"; do
    [ -f "$f" ] || { echo "Missing source: $f" >&2; exit 1; }
done

if ! command -v magick >/dev/null 2>&1; then
    echo "Error: ImageMagick (magick) not on PATH." >&2
    echo "  Fedora/RHEL:  sudo dnf install ImageMagick" >&2
    exit 1
fi

echo "Regenerating brand-derived assets from canonical sources."
echo

# --- 1. Icon theme (delegate) ----------------------------------------------
# generate-logos.sh handles the freedesktop hicolor tree (16-512 px PNGs +
# scalable SVG + pixmaps fallback). It also installs the canonical
# /usr/share/macrosofty/logo.svg.
echo "[1/5] Icon theme + scalable SVG (delegating to generate-logos.sh)..."
"$REPO_ROOT/scripts/generate-logos.sh"

# --- 2. Anaconda installer pixmaps -----------------------------------------
# These ride into install.img via scripts/rebrand-netinstall-iso.sh.
# The rebrand script overlays whatever we put here onto the upstream
# Fedora installer rootfs.
echo
echo "[2/5] Anaconda installer pixmaps..."
ANACONDA_DIR="$SHARED/anaconda/pixmaps"
mkdir -p "$ANACONDA_DIR"

# 1920x1080 wallpaper — used as both the splash background and the
# sidebar background (they're the same file in stock Fedora; we keep
# them identical).
magick -background none "$WALLPAPER_SVG" -strip -resize 1920x1080 \
    "$ANACONDA_DIR/anaconda_splash.png"
cp -f "$ANACONDA_DIR/anaconda_splash.png" "$ANACONDA_DIR/sidebar-bg.png"
echo "  + anaconda_splash.png  (1920x1080  from wallpaper.svg)"
echo "  + sidebar-bg.png       (1920x1080  identical to splash)"

# 800x88 Tjopper banner that sits at the top of every Anaconda screen.
magick -background none "$ANACONDA_HEADER_SVG" -strip -resize 800x88 \
    "$ANACONDA_DIR/anaconda_header.png"
echo "  + anaconda_header.png  (800x88     from tjopper/anaconda-header.svg)"

# 150x69 doorway in the sidebar — replaces the upstream "fedora"
# wordmark. Logo rendered at 69x69 then padded to 150 width with
# transparent canvas to match where the original logo sat.
magick -background none "$LOGO_MASTER" -strip -resize x69 \
    -gravity center -extent 150x69 \
    "$ANACONDA_DIR/sidebar-logo.png"
echo "  + sidebar-logo.png     (150x69     from logo-master.svg)"

# --- 3. Macrosofty default theme pack --------------------------------------
# Applied at OCI build time by `macrosofty-theme apply saffron` per
# edition. Pack components are listed in pack.json next to these files.
echo
echo "[3/5] Macrosofty default theme pack..."
THEME_DIR="$SHARED/macrosofty/themes/saffron"
mkdir -p "$THEME_DIR/plymouth"

# Wallpaper + login background — same image, two filenames (KDE looks
# up the wallpaper by the first path; SDDM by the second).
magick -background none "$WALLPAPER_SVG" -strip -resize 1920x1080 \
    "$THEME_DIR/wallpaper-1920x1080.png"
cp -f "$THEME_DIR/wallpaper-1920x1080.png" "$THEME_DIR/login-bg.png"
echo "  + wallpaper-1920x1080.png  (from wallpaper.svg)"
echo "  + login-bg.png             (identical to wallpaper)"

# 256x256 logo — used by Plymouth boot splash and as a fallback in
# pack.json's "logo" component.
magick -background none "$LOGO_MASTER" -strip -resize 256x256 \
    "$THEME_DIR/logo-256.png"
cp -f "$THEME_DIR/logo-256.png" "$THEME_DIR/plymouth/logo.png"
echo "  + logo-256.png             (256x256 from logo-master.svg)"
echo "  + plymouth/logo.png        (identical to logo-256.png)"

# --- 4. Tjopper SVG library ------------------------------------------------
# The 6 expression SVGs ship as vectors into /usr/share/macrosofty/
# tjopper/. The firstboot welcome dialog and AppHelperThingy reference
# them at runtime. anaconda-header.svg is rasterised above (step 2)
# rather than copied; it is not used at runtime.
echo
echo "[4/5] Tjopper SVG library..."
TJOPPER_DEST="$SHARED/macrosofty/tjopper"
mkdir -p "$TJOPPER_DEST"
copied=0
for svg in "$TJOPPER_SRC_DIR"/tjopper-*.svg; do
    [ -f "$svg" ] || continue
    cp -f "$svg" "$TJOPPER_DEST/$(basename "$svg")"
    copied=$((copied + 1))
done
echo "  + $copied SVGs copied to /usr/share/macrosofty/tjopper/"

# --- 5. Macrosofty Tjopper theme pack --------------------------------------
# Partial pack: ships only wallpaper + login-bg. The rest of the system
# (kickoff icon, plymouth, motd, GRUB) inherits from whichever pack was
# applied previously (default at first boot). macrosofty-theme apply
# treats missing components as no-ops, which is the contract we rely on.
#
# Composition: brand background SVG (dark gradient + wordmark, no big
# saffron arch) + Tjopper wave PNG, layered with ImageMagick. Rendered
# at the target sizes — no inlining of the wave SVG into the bg, so a
# future edit to tjopper-wave.svg flows through automatically.
echo
echo "[5/5] Macrosofty Tjopper theme pack..."
TJOPPER_THEME_DIR="$SHARED/macrosofty/themes/tjopper"
mkdir -p "$TJOPPER_THEME_DIR"

TMP_BG="$(mktemp --suffix=.png)"
TMP_TJ="$(mktemp --suffix=.png)"
trap 'rm -f "$TMP_BG" "$TMP_TJ"' EXIT

magick -background none "$TJOPPER_BG_SVG" -strip -resize 1920x1080 "$TMP_BG"
magick -background none "$TJOPPER_WAVE_SVG" -strip -resize 720x720 "$TMP_TJ"
magick "$TMP_BG" "$TMP_TJ" -gravity center -geometry +0-40 -composite -strip \
    "$TJOPPER_THEME_DIR/wallpaper-1920x1080.png"
cp -f "$TJOPPER_THEME_DIR/wallpaper-1920x1080.png" "$TJOPPER_THEME_DIR/login-bg.png"
echo "  + wallpaper-1920x1080.png  (Tjopper wave on brand bg, 1920x1080)"
echo "  + login-bg.png             (identical to wallpaper)"

# --- Done ------------------------------------------------------------------
echo
echo "Done. Review the diff and commit:"
echo "  git status system_files/shared/"
echo
echo "Brand-string changes (BRAND_NAME, URLs, taglines) live in"
echo "config/identity.env and do NOT need this script — they are"
echo "applied at OCI build / netinstall ISO build time."
