#!/usr/bin/env bash
#
# scrub-upstream-branding.sh [edition] — rewrite upstream brand strings
# (Aurora, Bazzite, …) to our brand in the user-facing strings of the
# inherited image. Run from each edition's build.sh after the theme
# pack apply.
#
# Optional positional arg: the edition name (hearty, chunky, padkos,
# braai). When given, the script also adds an edition-specific URL
# substitution that rewrites the upstream OCI ref (e.g. "ghcr.io/
# ublue-os/aurora") to ours (e.g. "ghcr.io/macrosofty/padkos") so
# motd content displaying the source-image path lands on our path.
# Without the arg, the per-edition substitution is skipped.
#
# Single source of truth for what to scrub: config/identity.env.
# Edit that file (UPSTREAM_BRANDS, UPSTREAM_URL_SUBS, BRAND_NAME,
# EDITION_UPSTREAM_OCI, BRAND_OCI_PREFIX) to change what gets
# rewritten — this script reads from there.
#
# Functional fields (Exec=, file paths, package names) are left alone
# so we don't break what we inherited; only display strings + URLs are
# rewritten. Idempotent. Safe to re-run.

set -euo pipefail

EDITION="${1:-}"

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
[ -n "$EDITION" ] && echo "Edition: ${EDITION}" || echo "Edition: (not specified)"

# --- Per-edition URL substitution ------------------------------------------
# When called with an edition, look up the upstream OCI ref from
# EDITION_UPSTREAM_OCI in identity.env. Append a "this upstream OCI
# becomes our OCI for this edition" line to the URL substitutions list.
#
# Effect: a motd line like "ghcr.io/ublue-os/aurora:stable" becomes
# "ghcr.io/macrosofty/padkos:stable" on the Padkos build, instead of
# the literal string-replaced (and broken) "ghcr.io/ublue-os/macrosofty:
# stable" that the bare brand-name swap would produce.
if [ -n "$EDITION" ]; then
    # EDITION_UPSTREAM_OCI is one "<edition>:<oci_ref>" per line. Pull
    # the line for our edition and strip the leading "<edition>:". Sed
    # is simpler than awk here and dodges multi-line-in-$() issues.
    upstream_oci=$(printf '%s\n' "$EDITION_UPSTREAM_OCI" | sed -n "s/^${EDITION}://p" | head -1)
    if [ -n "$upstream_oci" ] && [ -n "${BRAND_OCI_PREFIX:-}" ]; then
        # Prepend so per-edition substitution wins over generic ones.
        UPSTREAM_URL_SUBS="${upstream_oci}|${BRAND_OCI_PREFIX}/${EDITION}
${UPSTREAM_URL_SUBS}"
        echo "Per-edition OCI substitution: ${upstream_oci} -> ${BRAND_OCI_PREFIX}/${EDITION}"
    elif [ -n "$EDITION" ]; then
        echo "Warning: edition '$EDITION' has no entry in EDITION_UPSTREAM_OCI; skipping per-edition substitution"
    fi
fi

# --- Build the sed program from identity.env ------------------------------
# Each upstream brand becomes two replacements (capitalized + lowercase).
# Each URL substitution becomes one. The sed program is reused across
# multiple file types — what differs is whether the lines are restricted
# to specific keys (.desktop) or applied whole-file (shell scripts, motd).
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

# Pre-compute the regex alternation for the case-insensitive grep + the
# URL hosts so we only run sed against files that contain at least one
# upstream reference. Avoids touching files we don't need to.
brand_regex=$(echo "$UPSTREAM_BRANDS" | tr ' ' '|')
url_host_regex=$(echo "$UPSTREAM_URL_SUBS" | awk -F'|' '{print $1}' \
                  | grep -v '^$' | tr '\n' '|' | sed 's/|$//')
combined_regex="${brand_regex}|${url_host_regex}"

# --- .desktop entries (system menu items + autostart) ----------------------
# Two-pass approach for .desktop files:
#   1. Restricted pass on Name/Comment/GenericName/Keywords lines for
#      brand strings (preserves Exec= and other functional fields).
#   2. Whole-file URL substitutions (URLs in .desktop fields can appear
#      in any line — Comment, X-KDE-PluginInfo-Website, X-XDG-URL, etc.
#      URL patterns are specific enough that whole-file is safe).
DESKTOP_BRAND_PROGRAM=$(
    {
        printf '/^\\(Name\\|Comment\\|GenericName\\|Keywords\\)\\(\\[[a-zA-Z_@]*\\]\\)\\?=/ {\n'
        build_brand_sed_lines
        printf '}\n'
    }
)

DESKTOP_URL_PROGRAM=$(build_url_sed_lines)

while IFS= read -r -d '' f; do
    [ -f "$f" ] || continue
    if grep -q -iE "$combined_regex" "$f" 2>/dev/null; then
        sed -i "$DESKTOP_BRAND_PROGRAM" "$f"
        sed -i "$DESKTOP_URL_PROGRAM" "$f"
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

# --- Shell-login greeting scripts + ublue-os helpers -----------------------
# These get the URL subs whole-file (they're prose / scripts that can
# contain URLs anywhere) and the brand-string pass.
GREETING_SED_PROGRAM=$(
    {
        # URL substitutions first (so URLs are rewritten before bare
        # brand-string substitutions might mangle them).
        build_url_sed_lines
        build_brand_sed_lines
    }
)

# /etc/profile.d, motd dirs, shell rc dirs.
while IFS= read -r -d '' f; do
    [ -f "$f" ] || continue
    if grep -q -iE "$combined_regex" "$f" 2>/dev/null; then
        sed -i "$GREETING_SED_PROGRAM" "$f"
    fi
done < <(find /etc/profile.d /etc/motd.d /etc/update-motd.d /etc/bashrc.d /etc/zsh \
            -type f \( -name '*.sh' -o -name 'bashrc' -o -name 'zshrc' \) -print0 2>/dev/null)

# Universal Blue's /usr/share/ublue-os tree (motd content, justfiles,
# brewfiles, fastfetch config). Restricted to text-shaped files; binary
# blobs skipped.
while IFS= read -r -d '' f; do
    [ -f "$f" ] || continue
    if grep -q -iE "$combined_regex" "$f" 2>/dev/null; then
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
