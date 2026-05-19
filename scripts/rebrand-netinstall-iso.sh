#!/usr/bin/env bash
#
# rebrand-netinstall-iso.sh — overlay Macrosofty branding onto a stock
# Fedora netinstall ISO so the Anaconda installer chrome looks like
# Macrosofty instead of "FEDORA 43 INSTALLATION" / "fedora SERVER".
#
# This script ONLY rebrands the installer chrome (what you see while
# Anaconda is running). The OS that gets installed is unaffected — that
# comes from the OCI image we pull at install time, which is already
# Macrosofty-branded via system_files/shared/.
#
# ## Usage
#
#   scripts/rebrand-netinstall-iso.sh <source.iso> <edition> <output.iso>
#
#   <source.iso>   stock Fedora-Server-netinst-x86_64-43-*.iso
#   <edition>      hearty | chunky | padkos | braai
#   <output.iso>   path to write the rebranded ISO
#
# ## What it does
#
# 1. Extracts /images/install.img (the installer rootfs squashfs) from
#    the source ISO into a working dir.
# 2. unsquashfs -> overlays our pixmaps, product.d/macrosofty.conf, and
#    a Macrosofty-flavoured /etc/os-release + /usr/lib/os-release ->
#    mksquashfs back to a new install.img.
# 3. xorriso -indev source -outdev output -boot_image any replay
#    -map new-install.img /images/install.img — surgical replacement
#    that preserves El Torito BIOS boot + EFI boot + GPT layout.
#
# ## Why "any replay" works
#
# `-boot_image any replay` reads the source ISO's boot config and
# applies it verbatim to the output. We only swap install.img; isolinux
# config, grub.cfg, efiboot.img, partition layout — all untouched.
# Volid is also preserved so kickstart `inst.stage2=hd:LABEL=...` lines
# still resolve.
#
# ## Tools required
#
#   - squashfs-tools (unsquashfs, mksquashfs)
#   - xorriso
#   - coreutils, findutils
#
# Designed to run inside a privileged Fedora 43 container in CI, or on
# any host with the above tools installed. No loop-mount required —
# we use xorriso to extract install.img directly from the ISO, which
# avoids needing CAP_SYS_ADMIN.

set -euo pipefail

# --------------------------------------------------------------------------
# Args + paths
# --------------------------------------------------------------------------

if [ $# -ne 3 ]; then
    echo "usage: $0 <source.iso> <edition> <output.iso>" >&2
    exit 64
fi

SRC_ISO="$1"
EDITION="$2"
OUT_ISO="$3"

# Resolve repo root from this script's location, so the script works
# whether invoked from repo root, from CI's $PWD, or anywhere else.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

ASSETS_DIR="${REPO_ROOT}/system_files/shared/usr/share/anaconda"
IDENTITY_ENV="${REPO_ROOT}/config/identity.env"

# --------------------------------------------------------------------------
# Sanity checks
# --------------------------------------------------------------------------

[ -r "${SRC_ISO}" ]      || { echo "Source ISO not readable: ${SRC_ISO}" >&2; exit 1; }
[ -r "${IDENTITY_ENV}" ] || { echo "identity.env not found: ${IDENTITY_ENV}" >&2; exit 1; }
[ -d "${ASSETS_DIR}" ]   || { echo "Anaconda assets dir not found: ${ASSETS_DIR}" >&2; exit 1; }

for tool in xorriso unsquashfs mksquashfs; do
    command -v "${tool}" >/dev/null \
        || { echo "Required tool missing: ${tool}" >&2; exit 1; }
done

case "${EDITION}" in
    hearty)  PRETTY="Hearty"  ;;
    chunky)  PRETTY="Chunky"  ;;
    padkos)  PRETTY="Padkos"  ;;
    braai)   PRETTY="Braai"   ;;
    *) echo "Unknown edition: ${EDITION}" >&2; exit 1 ;;
esac

# Pick up BRAND_NAME, URLs, etc. from identity.env so we never hard-code
# the brand name in two places.
# shellcheck source=/dev/null
. "${IDENTITY_ENV}"

# --------------------------------------------------------------------------
# Working directory + cleanup
# --------------------------------------------------------------------------

WORK_DIR="$(mktemp -d -t rebrand-iso.XXXXXX)"
trap 'rm -rf "${WORK_DIR}"' EXIT

ROOTFS_DIR="${WORK_DIR}/rootfs"
NEW_INSTALL_IMG="${WORK_DIR}/install.img"
SRC_INSTALL_IMG="${WORK_DIR}/install.img.orig"

echo "[rebrand] working in ${WORK_DIR}"
echo "[rebrand] source: ${SRC_ISO}"
echo "[rebrand] edition: ${EDITION} (${PRETTY})"
echo "[rebrand] output: ${OUT_ISO}"

# --------------------------------------------------------------------------
# 1. Extract install.img from the source ISO
# --------------------------------------------------------------------------
# xorriso's -osirrox lets us pull a single file out of the ISO without
# loop-mounting (no CAP_SYS_ADMIN needed). Faster than copying the whole
# ISO contents and only extracting what we change.

echo "[rebrand] extracting /images/install.img from source ISO..."
xorriso -osirrox on \
        -indev "${SRC_ISO}" \
        -extract /images/install.img "${SRC_INSTALL_IMG}" \
        2>&1 | tail -5

if [ ! -s "${SRC_INSTALL_IMG}" ]; then
    echo "[rebrand] failed to extract install.img" >&2
    exit 1
fi

# --------------------------------------------------------------------------
# 2. unsquashfs -> overlay our assets -> mksquashfs
# --------------------------------------------------------------------------

echo "[rebrand] unsquashfs install.img..."
unsquashfs -d "${ROOTFS_DIR}" -no-progress "${SRC_INSTALL_IMG}" >/dev/null

# Make target dirs in case upstream version doesn't have them. (They do,
# but better to be safe than have cp fail mid-build.)
install -d "${ROOTFS_DIR}/usr/share/anaconda/pixmaps"
install -d "${ROOTFS_DIR}/usr/share/anaconda/product.d"

# Overlay pixmaps. Each cp follows the canonical asset's mode; mksquashfs
# stores the new mtime which is fine.
echo "[rebrand] overlaying anaconda pixmaps..."
for png in anaconda_header.png anaconda_splash.png sidebar-bg.png sidebar-logo.png topbar-bg.png; do
    src="${ASSETS_DIR}/pixmaps/${png}"
    if [ -r "${src}" ]; then
        cp -f "${src}" "${ROOTFS_DIR}/usr/share/anaconda/pixmaps/${png}"
        echo "  + ${png}"
    else
        echo "  ! missing source pixmap: ${src} (skipping)" >&2
    fi
done

# Anaconda product config — this is what makes Anaconda call itself
# "Macrosofty" instead of "Fedora" in titles, dialogs, error messages.
echo "[rebrand] overlaying product.d/macrosofty.conf..."
cp -f "${ASSETS_DIR}/product.d/macrosofty.conf" \
      "${ROOTFS_DIR}/usr/share/anaconda/product.d/macrosofty.conf"

# --------------------------------------------------------------------------
# 3. Rewrite os-release inside install.img
# --------------------------------------------------------------------------
# Anaconda's product detection reads /etc/os-release of the running
# installer environment. If NAME and VARIANT match macrosofty.conf's
# [Product] block, our product config wins. Otherwise the title falls
# back to "Fedora 43 INSTALLATION".
#
# We keep ID=fedora because deep parts of Anaconda check `os-release.ID
# == "fedora"` for fedora-specific code paths. Brand identity comes
# through NAME / PRETTY_NAME / VARIANT, not ID — same trick used by
# Aurora and Bazzite.

echo "[rebrand] rewriting os-release inside install.img..."
cat > "${ROOTFS_DIR}/usr/lib/os-release" <<EOF
NAME="${BRAND_NAME}"
PRETTY_NAME="${BRAND_NAME} ${PRETTY} 43 (Installer)"
VERSION="43 (Installer)"
VERSION_ID=43
ID=fedora
ID_LIKE=fedora
VARIANT="${BRAND_NAME} ${PRETTY}"
VARIANT_ID=${EDITION}
LOGO=${BRAND_NAME_LOWER}
HOME_URL="${BRAND_HOMEPAGE_URL}"
DOCUMENTATION_URL="${BRAND_DOCS_URL}"
SUPPORT_URL="${BRAND_SUPPORT_URL}"
BUG_REPORT_URL="${BRAND_ISSUES_URL}"
DEFAULT_HOSTNAME=${BRAND_DEFAULT_HOSTNAME}
EOF

# Keep /etc/os-release as a symlink to /usr/lib/os-release per
# systemd convention.
ln -sf ../usr/lib/os-release "${ROOTFS_DIR}/etc/os-release"

# /etc/system-release feeds the boot menu / installer "<distro> <version>"
# string. /etc/redhat-release is a legacy symlink to system-release.
echo "${BRAND_NAME} ${PRETTY} 43 (Installer)" \
    > "${ROOTFS_DIR}/etc/system-release"
ln -sf system-release "${ROOTFS_DIR}/etc/redhat-release"

# --------------------------------------------------------------------------
# 3b. Rewrite /.buildstamp inside install.img
# --------------------------------------------------------------------------
# This is the *actual* source of the "FEDORA 43 INSTALLATION" title
# Anaconda renders at the top of the installer — it reads
# pyanaconda/core/product.py:get_product_values() which reads
# /.buildstamp's [Main] Product + Version. os-release / product.d
# do NOT control this title. We rewrite Product, BugURL, Variant in
# place and leave Version/IsFinal/UUID/Compose alone so we don't drift
# from whatever Lorax ships upstream.

echo "[rebrand] rewriting /.buildstamp Product line..."
if [ -r "${ROOTFS_DIR}/.buildstamp" ]; then
    sed -i \
        -e "s|^Product=.*|Product=${BRAND_NAME} ${PRETTY}|" \
        -e "s|^BugURL=.*|BugURL=${BRAND_ISSUES_URL}|" \
        -e "s|^Variant=.*|Variant=${BRAND_NAME}|" \
        "${ROOTFS_DIR}/.buildstamp"
else
    echo "  ! /.buildstamp missing in upstream install.img — skipping" >&2
fi

# --------------------------------------------------------------------------
# 4. Repack squashfs
# --------------------------------------------------------------------------
# Match Fedora's compression to keep size sane: xz with x86 BCJ filter
# and a 1M block size. Drop -no-progress for CI logs to show progress.

echo "[rebrand] mksquashfs (this takes a few minutes)..."
mksquashfs "${ROOTFS_DIR}" "${NEW_INSTALL_IMG}" \
    -comp xz \
    -Xbcj x86 \
    -b 1M \
    -noappend \
    -no-progress \
    -no-xattrs \
    >/dev/null

# Free the rootfs dir's disk usage early — we have the new img, don't need
# the extracted tree anymore. (CI runner has limited free space.)
rm -rf "${ROOTFS_DIR}"

ls -lh "${SRC_INSTALL_IMG}" "${NEW_INSTALL_IMG}"

# --------------------------------------------------------------------------
# 5. Repack ISO with xorriso, replacing only install.img
# --------------------------------------------------------------------------
# `-boot_image any replay` preserves the source ISO's El Torito boot
# catalog (BIOS isolinux + EFI efiboot.img) without us having to know
# the exact xorriso flags for hybrid boot. `-map src dst` overwrites the
# named path inside the ISO with src from the host filesystem.

echo "[rebrand] xorriso repack ISO..."
mkdir -p "$(dirname "${OUT_ISO}")"
rm -f "${OUT_ISO}"

xorriso \
    -indev  "${SRC_ISO}" \
    -outdev "${OUT_ISO}" \
    -boot_image any replay \
    -map "${NEW_INSTALL_IMG}" /images/install.img \
    -end \
    2>&1 | tail -10

if [ ! -s "${OUT_ISO}" ]; then
    echo "[rebrand] xorriso produced no output" >&2
    exit 1
fi

echo "[rebrand] done: ${OUT_ISO}"
ls -lh "${OUT_ISO}"
