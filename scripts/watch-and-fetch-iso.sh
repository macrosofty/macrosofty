#!/usr/bin/env bash
# watch-and-fetch-iso.sh — wait for the public CI image + ISO builds to finish,
# then download (with retries, checksum-verified) one edition's full ISO and
# print the path it landed at.
#
# Local dev utility — NOT published (excluded in publish-to-public.sh). Paths
# are hard-wired to this dev box.
#
#   Usage:
#     scripts/watch-and-fetch-iso.sh [EDITION] [COMMIT_SHA]
#
#   EDITION     edition to fetch (default: padkos)
#   COMMIT_SHA  commit to track (default: current macrosofty/macrosofty main)
#
#   On success the final line is machine-parseable (for a boot-test step to read):
#     ISO_PATH=/var/mnt/code/macrosofty-iso/macrosofty-<edition>-<date>.iso
#
# Chain: watch "Build edition images" (push) → wait for "Build edition ISOs"
# (workflow_run) to be queued → watch it → download the edition artefact into
# the ISO folder, verify its sha256 (re-download on mismatch), print the path.
set -uo pipefail

REPO="macrosofty/macrosofty"
EDITION="${1:-padkos}"
SHA="${2:-}"
DEST="/var/mnt/code/macrosofty-iso"
WATCH_INTERVAL=60          # seconds between gh-run-watch refreshes
APPEAR_TRIES=60            # how many 30s polls to wait for the ISO run to queue
RETRY_TRIES=5             # attempts for flaky steps (download, artefact lookup)
RETRY_BACKOFF=15          # base seconds between retries (grows linearly)

# shellcheck disable=SC1090
source ~/.config/macrosofty/load-tokens.sh 2>/dev/null || true
export GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"

log()  { printf '%s  %s\n' "$(date -u +%H:%M:%S)" "$*"; }
warn() { log "⚠ $*"; }
die()  { log "✗ $*"; exit 1; }

command -v gh >/dev/null || die "gh CLI not found"
[ -n "${GH_TOKEN:-}" ] || die "no GH_TOKEN — source ~/.config/macrosofty/load-tokens.sh"

# retry CMD… — run CMD up to RETRY_TRIES times with linear backoff (15s, 30s, …).
# Returns CMD's success, or non-zero if every attempt failed.
retry() {
    local n=1 delay="$RETRY_BACKOFF"
    while true; do
        "$@" && return 0
        [ "$n" -ge "$RETRY_TRIES" ] && return 1
        warn "attempt $n/$RETRY_TRIES failed — retrying in ${delay}s"
        sleep "$delay"
        n=$((n + 1))
        delay=$((delay + RETRY_BACKOFF))
    done
}

# watch_run RUN_ID LABEL — watch a run to completion, surviving transient drops
# in `gh run watch`. Only fails on a genuine non-success conclusion; a dropped
# watch on a still-running job is re-attached, not treated as a failure.
watch_run() {
    local run="$1" label="$2" status conclusion
    while true; do
        gh run watch "$run" --repo "$REPO" --exit-status --interval "$WATCH_INTERVAL" && return 0
        status="$(gh run view "$run" --repo "$REPO" --json status -q .status 2>/dev/null)"
        conclusion="$(gh run view "$run" --repo "$REPO" --json conclusion -q .conclusion 2>/dev/null)"
        if [ "$status" = "completed" ]; then
            [ "$conclusion" = "success" ] && return 0
            log "✗ $label finished: conclusion=$conclusion"
            return 1
        fi
        warn "$label watch dropped (status=${status:-unknown}) — re-attaching in 10s"
        sleep 10
    done
}

# Resolve the commit we're tracking.
[ -n "$SHA" ] || SHA="$(gh api "repos/$REPO/commits/main" -q .sha 2>/dev/null)"
[ -n "$SHA" ] || die "could not resolve a commit SHA to track"
SHORT="${SHA:0:7}"
log "Tracking $EDITION @ $SHORT on $REPO"

# --- 1. Image build (event=push on this commit) -----------------------------
IMG_RUN="$(gh run list --repo "$REPO" --workflow "Build edition images" \
            --commit "$SHA" --limit 5 \
            --json databaseId,event \
            -q 'first(.[] | select(.event=="push") | .databaseId)' 2>/dev/null)"
[ -n "$IMG_RUN" ] || die "no push-triggered image build found for $SHORT"
log "Image build run $IMG_RUN — watching (this is ~7-10 min)…"
watch_run "$IMG_RUN" "image build" \
    || die "image build failed (run $IMG_RUN) — ISO build will skip; nothing to fetch"
log "✓ image build succeeded"

# --- 2. ISO build (event=workflow_run on this commit) -----------------------
log "Waiting for the ISO build to be queued…"
ISO_RUN=""
for _ in $(seq 1 "$APPEAR_TRIES"); do
    ISO_RUN="$(gh run list --repo "$REPO" --workflow "Build edition ISOs" \
                --commit "$SHA" --limit 5 \
                --json databaseId,event \
                -q 'first(.[] | select(.event=="workflow_run") | .databaseId)' 2>/dev/null)"
    [ -n "$ISO_RUN" ] && break
    sleep 30
done
[ -n "$ISO_RUN" ] || die "ISO build never appeared for $SHORT (waited $((APPEAR_TRIES / 2)) min)"
log "ISO build run $ISO_RUN — watching (this is ~22 min)…"
watch_run "$ISO_RUN" "ISO build" || die "ISO build failed (run $ISO_RUN)"
log "✓ ISO build succeeded"

# --- 3. Resolve the edition artefact (retry — listing can lag the run) ------
resolve_artefact() {
    ART="$(gh api "repos/$REPO/actions/runs/$ISO_RUN/artifacts" --paginate \
            -q ".artifacts[] | select(.name | startswith(\"macrosofty-${EDITION}-\")) | .name" \
            2>/dev/null | head -1)"
    [ -n "$ART" ]
}
ART=""
retry resolve_artefact || die "no macrosofty-${EDITION}-* artefact on run $ISO_RUN"
log "Artefact: $ART"

# --- 4. Download + verify (re-download on network failure OR checksum miss) --
# gh stages the artefact as a zip in $TMPDIR before extracting; the default
# /tmp here is a ~8 GB tmpfs that a 5-6 GB ISO overflows ("disk quota
# exceeded"). Point gh at a staging dir on the roomy ISO filesystem instead.
mkdir -p "$DEST"
ISO_FILE="$DEST/${ART}.iso"
SUM_FILE="$DEST/${ART}.iso.sha256"
GH_TMP="$DEST/.gh-download-tmp"
trap 'rm -rf "$GH_TMP"' EXIT

download_and_verify() {
    log "Downloading '$ART' → $DEST/"
    rm -f "$ISO_FILE" "$SUM_FILE"          # clear partials so a retry starts clean
    rm -rf "$GH_TMP"; mkdir -p "$GH_TMP"   # fresh staging dir (dodges tmpfs overflow)
    TMPDIR="$GH_TMP" gh run download "$ISO_RUN" --repo "$REPO" -n "$ART" -D "$DEST" \
        || { warn "download failed"; return 1; }
    if [ -f "$SUM_FILE" ]; then
        log "Verifying sha256…"
        ( cd "$DEST" && sha256sum -c "${ART}.iso.sha256" ) \
            || { warn "checksum mismatch — will re-download"; return 1; }
        log "✓ checksum OK"
    else
        warn "no .sha256 alongside the ISO — skipping verification"
    fi
    [ -f "$ISO_FILE" ] || { warn "expected $ISO_FILE missing after download"; return 1; }
}
retry download_and_verify \
    || die "could not fetch a verified ${ART}.iso after $RETRY_TRIES tries"

# --- 5. Report --------------------------------------------------------------
log "✓ done — ISO ready ($(du -h "$ISO_FILE" | cut -f1)):"
ls -lh "$ISO_FILE"
echo "ISO_PATH=$ISO_FILE"
