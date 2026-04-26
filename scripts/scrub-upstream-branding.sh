#!/usr/bin/env bash
#
# scrub-upstream-branding.sh — rewrite "Aurora" → "Macrosofty" in
# user-facing strings of the inherited image. Run from each edition's
# build.sh after the theme pack apply. Functional fields (Exec=, file
# paths, package names) are left alone so we don't break what we
# inherited; only display strings are rewritten.
#
# Idempotent. Safe to re-run.

set -euo pipefail

echo "::group::Scrub upstream branding"

# --- .desktop entries (system menu items + autostart) ----------------------
# Targets: Name, GenericName, Comment, Keywords (and their locale variants).
# We replace "Aurora"/"Bazzite" with "Macrosofty" globally on those lines
# only — Exec=, Icon=, Categories=, etc. stay untouched. Covers both the
# system menu (/usr/share/applications) and the autostart directory
# (/etc/xdg/autostart) where login-launched helpers live.
while IFS= read -r -d '' f; do
    [ -f "$f" ] || continue
    if grep -q -iE 'aurora|bazzite' "$f" 2>/dev/null; then
        sed -i '/^\(Name\|Comment\|GenericName\|Keywords\)\(\[[a-zA-Z_@]*\]\)\?=/ {
            s/Aurora/Macrosofty/g
            s/aurora/macrosofty/g
            s/Bazzite/Macrosofty/g
            s/bazzite/macrosofty/g
        }' "$f"
    fi
done < <(find /usr/share/applications /etc/xdg/autostart -type f -name '*.desktop' -print0 2>/dev/null)

# Update the menu database so KDE / GNOME pick up the rewrites without
# needing a re-login. Best-effort.
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications/ 2>/dev/null || true
fi

# --- /etc/*-release files --------------------------------------------------
# Aurora may ship /etc/aurora-release or similar. Rewrite "Aurora" to
# "Macrosofty" in these. Skip the ones we own (os-release, system-release,
# redhat-release — already populated by scripts/generate-os-release.sh).
for f in /etc/*-release; do
    [ -f "$f" ] || continue
    base=$(basename "$f")
    case "$base" in
        os-release|system-release|redhat-release) continue ;;
    esac
    if grep -q -iE 'aurora|bazzite' "$f" 2>/dev/null; then
        sed -i 's/Aurora/Macrosofty/g; s/aurora/macrosofty/g; s/Bazzite/Macrosofty/g; s/bazzite/macrosofty/g' "$f"
    fi
done

# --- Other user-visible upstream strings -----------------------------------
# Aurora's plasma-welcome / first-run app branding lives in a few files.
# This is best-effort: we don't yet know the exact set of paths upstream
# uses, so we keep this list short and add to it as the next QEMU test
# surfaces things.
#
# Examples we'll add to once we observe them in a build:
#   /usr/share/plasma/plasmoids/.../Name fields
#   /etc/xdg/autostart/aurora-*.desktop (handled by .desktop loop above)

echo "::endgroup::"
