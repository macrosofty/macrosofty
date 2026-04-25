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
NAME="Macrosofty ${PRETTY}"
PRETTY_NAME="Macrosofty ${PRETTY}"
VERSION="${VERSION} (${PRETTY})"
VERSION_ID=43
ID=fedora
ID_LIKE=fedora
VARIANT="${PRETTY}"
VARIANT_ID=${EDITION}
ANSI_COLOR="0;38;2;${RGB}"
LOGO=macrosofty
HOME_URL="https://macrosofty.org"
DOCUMENTATION_URL="https://github.com/macrosofty/macrosofty"
SUPPORT_URL="https://github.com/macrosofty/macrosofty/discussions"
BUG_REPORT_URL="https://github.com/macrosofty/macrosofty/issues"
DEFAULT_HOSTNAME=macrosofty
IMAGE_ID=${EDITION}
IMAGE_VERSION="${VERSION}"
EOF

# /etc/system-release is what Anaconda reads for the boot-menu / install
# screen "<distro> <version>" line. Mirroring NAME so the installer shows
# "Macrosofty <Edition> 43" instead of just "Macrosofty 43".
echo "Macrosofty ${PRETTY} 43" > /etc/system-release
ln -sf system-release /etc/redhat-release 2>/dev/null || true

# /etc/os-release is conventionally a symlink to /usr/lib/os-release on
# systemd systems. Force the symlink in case Aurora ships a real file.
ln -sf ../usr/lib/os-release /etc/os-release

# TTY banner. \r is kernel release; \l is the tty.
cat > /etc/issue <<EOF
Macrosofty ${PRETTY} \\r (\\l)

EOF
cp /etc/issue /etc/issue.net

echo "os-release written: Macrosofty ${PRETTY} ${VERSION}"
