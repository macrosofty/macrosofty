#!/usr/bin/env bash
#
# scrub-upstream-branding.sh — rewrite upstream brand strings (Aurora,
# Bazzite, …) to our brand in the user-facing strings of the inherited
# image. Run from each edition's build.sh after the theme pack apply.
#
# Single source of truth for what to scrub: config/identity.env.
# Edit that file (UPSTREAM_BRANDS, UPSTREAM_URL_SUBS, BRAND_NAME) to
# change what gets rewritten — this script reads from there.
#
# Functional fields (Exec=, file paths, package names) are left alone
# so we don't break what we inherited; only display strings are
# rewritten. Idempotent. Safe to re-run.

set -euo pipefail

# --- Source identity config ------------------------------------------------
if [ -r /ctx/config/identity.env ]; then
    # shellcheck source=/dev/null
    . /ctx/config/identity.env
elif [ -r "$(dirname "$0")/../config/identity.env" ]; then
    # shellcheck source=/dev/null
    . "$(dirname "$0")/../config/identity.env"
else
    echo "scrub-upstream-branding.sh: missing config/identity.env" >&2
    exit 1
fi

echo "::group::Scrub upstream branding"
echo "Brand: ${BRAND_NAME} (lowercase: ${BRAND_NAME_LOWER})"
echo "Upstream brands to scrub: ${UPSTREAM_BRANDS}"

# --- Build the sed program from identity.env ------------------------------
# Each upstream brand becomes two replacements (capitalized + lowercase).
# Each URL substitution becomes one. The sed program is reused for both
# .desktop entries (Name/Comment/etc. lines only) and shell-greeting
# files (whole file).
build_brand_sed_lines() {
    for brand in $UPSTREAM_BRANDS; do
        local lower; lower=$(echo "$brand" | tr '[:upper:]' '[:lower:]')
        printf 's|%s|%s|g\n' "$brand" "$BRAND_NAME"
        printf 's|%s|%s|g\n' "$lower" "$BRAND_NAME_LOWER"
    done
}

build_url_sed_lines() {
    while IFS='|' read -r from to; do
        [ -n "$from" ] && [ -n "$to" ] || continue
        printf 's|%s|%s|g\n' "$from" "$to"
    done <<< "$UPSTREAM_URL_SUBS"
}

# Pre-compute the regex alternation for the case-insensitive grep, so
# we only run sed against files that contain at least one upstream
# brand reference. Avoids touching files we don't need to.
brand_regex=$(echo "$UPSTREAM_BRANDS" | tr ' ' '|')

# --- .desktop entries (system menu items + autostart) ----------------------
# Targets: Name, GenericName, Comment, Keywords (and locale variants).
# Exec=, Icon=, Categories= stay untouched so functionality is preserved.
DESKTOP_SED_PROGRAM=$(
    {
        printf '/^\\(Name\\|Comment\\|GenericName\\|Keywords\\)\\(\\[[a-zA-Z_@]*\\]\\)\\?=/ {\n'
        build_brand_sed_lines
        printf '}\n'
    }
)

while IFS= read -r -d '' f; do
    [ -f "$f" ] || continue
    if grep -q -iE "$brand_regex" "$f" 2>/dev/null; then
        sed -i "$DESKTOP_SED_PROGRAM" "$f"
    fi
done < <(find /usr/share/applications /etc/xdg/autostart -type f -name '*.desktop' -print0 2>/dev/null)

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q /usr/share/applications/ 2>/dev/null || true
fi

# --- /etc/*-release files --------------------------------------------------
# Skip the ones we own (os-release, system-release, redhat-release —
# populated by scripts/generate-os-release.sh from identity.env).
RELEASE_SED_PROGRAM=$(build_brand_sed_lines)

for f in /etc/*-release; do
    [ -f "$f" ] || continue
    base=$(basename "$f")
    case "$base" in
        os-release|system-release|redhat-release) continue ;;
    esac
    if grep -q -iE "$brand_regex" "$f" 2>/dev/null; then
        sed -i "$RELEASE_SED_PROGRAM" "$f"
    fi
done

# --- Shell-login greeting scripts ------------------------------------------
# Aurora / Bazzite ship /etc/profile.d/*.sh that print "Welcome to <brand>"
# plus links to their docs / issue tracker on every shell login. Rewrite
# both brand strings AND URLs so the welcome stays useful but points at
# our channels.
GREETING_SED_PROGRAM=$(
    {
        # URL substitutions first, so they don't get partially-rewritten
        # by the brand-string pass.
        build_url_sed_lines
        build_brand_sed_lines
    }
)

while IFS= read -r -d '' f; do
    [ -f "$f" ] || continue
    if grep -q -iE "$brand_regex" "$f" 2>/dev/null; then
        sed -i "$GREETING_SED_PROGRAM" "$f"
    fi
done < <(find /etc/profile.d /etc/motd.d /etc/update-motd.d /etc/bashrc.d /etc/zsh \
            -type f \( -name '*.sh' -o -name 'bashrc' -o -name 'zshrc' \) -print0 2>/dev/null)

# --- Universal Blue ublue-os helpers ---------------------------------------
# UBlue ships a /usr/share/ublue-os/ tree with the user motd content
# ("Welcome to Aurora", links, ujust recipes), brewfiles, justfiles, and
# fastfetch config. Aurora customises the motd content with their brand;
# we rewrite to ours. Limit to text-shaped files (.md, .txt, .sh, .just,
# .jsonc, .json, .conf, .toml, .yml, .yaml) so binary blobs are skipped.
while IFS= read -r -d '' f; do
    [ -f "$f" ] || continue
    if grep -q -iE "$brand_regex" "$f" 2>/dev/null; then
        sed -i "$GREETING_SED_PROGRAM" "$f"
    fi
done < <(find /usr/share/ublue-os \
            -type f \( -name '*.md' -o -name '*.txt' -o -name '*.sh' \
                       -o -name '*.just' -o -name '*.justfile' \
                       -o -name 'Justfile' -o -name 'Brewfile' \
                       -o -name '*.jsonc' -o -name '*.json' \
                       -o -name '*.conf' -o -name '*.toml' \
                       -o -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null)

echo "::endgroup::"
