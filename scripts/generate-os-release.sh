#!/usr/bin/env bash
#
# generate-os-release.sh — write Macrosofty's identity files into the image.
#
# Called from each edition's build.sh during container build:
#     /ctx/scripts/generate-os-release.sh "$EDITION" "$MACROSOFTY_VERSION"
#
# Writes:
#   /usr/lib/os-release   (the canonical file; /etc/os-release is a symlink to it)
#   /etc/issue            (pre-login TTY banner)
#   /etc/issue.net        (network pre-login banner; same content)
#
# Idempotent — safe to call more than once. Edition is required; version
# defaults to 0.1.0-dev if not given. Adding a new edition is one new
# row in the case statement below; nothing else needs touching.

set -euo pipefail

EDITION="${1:?usage: $0 <edition> [version]}"
VERSION="${2:-0.1.0-dev}"

# Source the brand identity (single source of truth for BRAND_NAME, URLs,
# default hostname, etc. — see config/identity.env). Look in /ctx/config/
# during image build, falling back to relative path for local testing.
if [ -r /ctx/config/identity.env ]; then
    # shellcheck source=/dev/null
    . /ctx/config/identity.env
elif [ -r "$(dirname "$0")/../config/identity.env" ]; then
    # shellcheck source=/dev/null
    . "$(dirname "$0")/../config/identity.env"
else
    echo "generate-os-release.sh: missing config/identity.env" >&2
    exit 1
fi

case "$EDITION" in
    hearty)  PRETTY="Hearty";  RGB="198;107;61"  ;;  # saffron orange
    chunky)  PRETTY="Chunky";  RGB="176;70;56"   ;;  # roasted red
    padkos)  PRETTY="Padkos";  RGB="122;136;104" ;;  # sage green
    braai)   PRETTY="Braai";   RGB="107;44;57"   ;;  # deep wine
    bokkie)  PRETTY="Bokkie";  RGB="170;130;90"  ;;  # buck-tan; tentative ARM
    *) echo "Unknown edition: $EDITION" >&2; exit 1 ;;
esac

# Why ID=fedora and VERSION_ID=43 — bootc-image-builder feeds os-release
# into osbuild, which expects "<ID>-<VERSION_ID>" to map to a known distro
# definition (e.g. fedora-43.toml). We don't ship a macrosofty distro
# definition upstream yet, so on the build-tool channel we identify as
# Fedora 43 — the actual upstream — and shine the Macrosofty identity
# through every user-visible field instead. Aurora and Bazzite get away
# with their own ID because they ship distro defs upstream; v0.2 work.
cat > /usr/lib/os-release <<EOF
NAME="${BRAND_NAME} ${PRETTY}"
PRETTY_NAME="${BRAND_NAME} ${PRETTY}"
VERSION="${VERSION} (${PRETTY})"
VERSION_ID=43
ID=fedora
ID_LIKE=fedora
VARIANT="${BRAND_NAME} ${PRETTY}"
VARIANT_ID=${EDITION}
ANSI_COLOR="0;38;2;${RGB}"
LOGO=${BRAND_NAME_LOWER}
HOME_URL="${BRAND_HOMEPAGE_URL}"
DOCUMENTATION_URL="${BRAND_DOCS_URL}"
SUPPORT_URL="${BRAND_SUPPORT_URL}"
BUG_REPORT_URL="${BRAND_ISSUES_URL}"
DEFAULT_HOSTNAME=${BRAND_DEFAULT_HOSTNAME}
IMAGE_ID=${EDITION}
IMAGE_VERSION="${VERSION}"
EOF

# /etc/system-release is what Anaconda reads for the boot-menu / install
# screen "<distro> <version>" line.
echo "${BRAND_NAME} ${PRETTY} 43" > /etc/system-release
ln -sf system-release /etc/redhat-release 2>/dev/null || true

# /etc/hostname — Aurora ships this set to "aurora", which means a fresh
# Padkos install lands at "user@aurora" in the terminal until the user
# picks something else. Override so the default matches the brand. User
# can change in Settings → System → About or interactively in Anaconda.
echo "${BRAND_DEFAULT_HOSTNAME}" > /etc/hostname

# /etc/os-release is conventionally a symlink to /usr/lib/os-release on
# systemd systems. Force the symlink in case the upstream ships a real file.
ln -sf ../usr/lib/os-release /etc/os-release

# TTY banner. \r is kernel release; \l is the tty.
cat > /etc/issue <<EOF
${BRAND_NAME} ${PRETTY} \\r (\\l)

EOF
cp /etc/issue /etc/issue.net

echo "os-release written: ${BRAND_NAME} ${PRETTY} ${VERSION}"
