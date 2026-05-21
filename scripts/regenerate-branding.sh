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
#   branding/Gemini_Generated_Image_*.png          (19 slideshow source images;
#                                                   resized + logo-overlaid into
#                                                   /usr/share/backgrounds/macrosofty/)
#   branding/tjopper/tjopper-wave.svg              (also composited with tjopper-
#   branding/tjopper/tjopper-heart.svg              heart on a saffron radial glow
#                                                   into the plasma-setup
#                                                   "finished" wizard PNG that
#                                                   ships Katie + Konqi upstream)
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
echo "[1/8] Icon theme + scalable SVG (delegating to generate-logos.sh)..."
"$REPO_ROOT/scripts/generate-logos.sh"

# --- 2. Anaconda installer pixmaps -----------------------------------------
# These ride into install.img via scripts/rebrand-netinstall-iso.sh.
# The rebrand script overlays whatever we put here onto the upstream
# Fedora installer rootfs.
echo
echo "[2/8] Anaconda installer pixmaps..."
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

# 1920x132 nav-box topbar background — Aurora's fedora.css points
# AnacondaSpokeWindow #nav-box at /usr/share/anaconda/pixmaps/topbar-bg.png.
# If we don't ship our own, Aurora's purple aurora-borealis art bleeds
# through every spoke header. Same SVG as anaconda_header.png, rendered
# at 132px tall (preserving aspect → ~1200px wide) and composited
# centred on a warm-charcoal canvas that matches the saffron theme.
magick -background '#1f1a14' -size 1920x132 canvas:'#1f1a14' \
    \( "$ANACONDA_HEADER_SVG" -background none -resize x132 \) \
    -gravity center -composite -strip \
    "$ANACONDA_DIR/topbar-bg.png"
echo "  + topbar-bg.png        (1920x132   from tjopper/anaconda-header.svg on warm-charcoal)"

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
echo "[3/8] Macrosofty default theme pack..."
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
echo "[4/8] Tjopper SVG library..."
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
echo "[5/8] Macrosofty Tjopper theme pack..."
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

# --- 6. Desktop slideshow wallpapers ---------------------------------------
# 19 Gemini-sourced wallpapers, resized to 2560x1396 JPEG q92 and tagged
# with the Macrosofty doorway in the bottom-right. The doorway sits over
# a localised 96x96 blur patch that erases the Gemini sparkle watermark
# baked into every source image. Lands in /usr/share/backgrounds/
# macrosofty/ and is wired up by macrosofty-apply-defaults as the Plasma
# wallpaper + lockscreen slideshow.
#
# Ordering: sorted by source filename. If you add/remove a source PNG,
# the macrosofty-NN.jpg numbering will shift — re-stage with care.
echo
echo "[6/8] Desktop slideshow wallpapers..."
SLIDESHOW_DIR="$SHARED/backgrounds/macrosofty"
mkdir -p "$SLIDESHOW_DIR"

# Logo overlay tuning (see preview iterations 2026-05-19/20):
#   - 96x96 saffron arch at 50% opacity
#   - gravity southeast, offset +55+55 (px from right / bottom)
#   - 96x96 region blur (radius 14) under the logo to mask the sparkle
LOGO_PX=96
LOGO_OFFSET_X=55
LOGO_OFFSET_Y=55
TARGET_W=2560
TARGET_H=1396
BLUR_X=$(( TARGET_W - LOGO_OFFSET_X - LOGO_PX ))
BLUR_Y=$(( TARGET_H - LOGO_OFFSET_Y - LOGO_PX ))

idx=1
for src in $(ls "$REPO_ROOT"/branding/Gemini_Generated_Image_*.png 2>/dev/null | sort); do
    [ -f "$src" ] || continue
    out=$(printf "%s/macrosofty-%02d.jpg" "$SLIDESHOW_DIR" "$idx")
    magick "$src" \
        -filter Lanczos -resize "${TARGET_W}x${TARGET_H}^" \
        -gravity center -extent "${TARGET_W}x${TARGET_H}" \
        -unsharp 0x0.75+0.5+0.008 \
        -region "${LOGO_PX}x${LOGO_PX}+${BLUR_X}+${BLUR_Y}" -blur 0x30 +region \
        \( "$LOGO_MASTER" -background none -resize "${LOGO_PX}x${LOGO_PX}" \
           -alpha set -channel A -evaluate multiply 0.45 +channel \) \
        -gravity southeast -geometry "+${LOGO_OFFSET_X}+${LOGO_OFFSET_Y}" -composite \
        -quality 92 -strip "$out"
    idx=$((idx + 1))
done
echo "  + $((idx - 1)) wallpapers regenerated at ${TARGET_W}x${TARGET_H} into /usr/share/backgrounds/macrosofty/"

# --- 7. Plasma-setup "finished" wizard image -------------------------------
# Upstream KDE's plasma-setup ships a 500x334 Konqi+Katie PNG at
# /usr/share/plasma/packages/org.kde.plasmasetup.finished/contents/ui/
# konqi-calling.png — visible on the "Completed!" screen after firstboot
# setup. We overlay our own file at the same path so the OCI layer wins.
# Two Tjoppers (wave on the left, heart on the right) at 280px tall on
# a soft saffron radial-gradient glow, to match the original aspect and
# add warmth in place of the upstream pure-white backdrop.
echo
echo "[7/8] Plasma-setup finished-wizard image..."
PSETUP_DIR="$SHARED/plasma/packages/org.kde.plasmasetup.finished/contents/ui"
mkdir -p "$PSETUP_DIR"
magick \
    \( -size 500x334 radial-gradient:'rgba(232,154,43,0.35)-rgba(232,154,43,0)' \) \
    \( "$TJOPPER_SRC_DIR/tjopper-wave.svg"  -background none -resize 280x280 \) \
    -gravity west -geometry +30+10 -composite \
    \( "$TJOPPER_SRC_DIR/tjopper-heart.svg" -background none -resize 280x280 \) \
    -gravity east -geometry +30+10 -composite \
    -strip "$PSETUP_DIR/konqi-calling.png"
echo "  + konqi-calling.png    (500x334   tjopper-wave + tjopper-heart on saffron glow)"

# --- 8. KSplash boot-to-desktop logo ---------------------------------------
# KSplash is the logo shown between SDDM login and the Plasma desktop. It is
# driven by the look-and-feel package named in each global theme's
# [KSplash] Theme= default. Both Aurora global themes (dev.getaurora.aurora
# AND dev.getaurora.auroralight) point at the SAME splash theme,
# dev.getaurora.aurora — so one saffron logo covers light and dark. We
# overlay our doorway at the package's images/aurora_logo.svgz; Splash.qml
# loads it by that relative path and renders it centred on black at
# gridUnit*8. Keeping it a vector svgz means it scales crisply on hidpi.
# Upstream ships the .aurora and .auroralight copies byte-identical, so we
# mirror into both — covers the edge case of a user hand-picking the
# "Aurora (light)" splash theme in System Settings.
echo
echo "[8/8] KSplash boot logo..."
KSPLASH_BASE="$SHARED/plasma/look-and-feel"
TMP_SPLASH_SVG="$(mktemp --suffix=.svg)"
# Set an explicit 375x375 (matching the file we replace) on the svg root
# while keeping logo-master's 0 0 400 400 viewBox, so the doorway geometry
# and centring carry over unchanged. -n keeps the gzip output deterministic
# (no embedded filename/mtime) so re-runs are bit-equivalent.
sed '0,/<svg /s//<svg width="375" height="375" /' "$LOGO_MASTER" > "$TMP_SPLASH_SVG"
for theme in dev.getaurora.aurora dev.getaurora.auroralight; do
    dest="$KSPLASH_BASE/$theme.desktop/contents/splash/images"
    mkdir -p "$dest"
    gzip -9 -n -c "$TMP_SPLASH_SVG" > "$dest/aurora_logo.svgz"
    echo "  + $theme.desktop/.../aurora_logo.svgz  (375x375 saffron doorway from logo-master.svg)"
done
rm -f "$TMP_SPLASH_SVG"

# --- Done ------------------------------------------------------------------
echo
echo "Done. Review the diff and commit:"
echo "  git status system_files/shared/"
echo
echo "Brand-string changes (BRAND_NAME, URLs, taglines) live in"
echo "config/identity.env and do NOT need this script — they are"
echo "applied at OCI build / netinstall ISO build time."
