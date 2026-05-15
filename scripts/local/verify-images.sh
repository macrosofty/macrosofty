#!/usr/bin/env bash
#
# verify-images.sh — pull each Macrosofty edition image and verify its
# cosign keyless signature in one shot.
#
# Host-time helper. Use any time you want to confirm the published
# artefacts on GHCR are (a) reachable, (b) signed by our GitHub Actions
# workflow, (c) traceable back to a specific commit on main.
#
# Usage:
#   scripts/local/verify-images.sh                # all four editions
#   scripts/local/verify-images.sh padkos braai   # subset
#   scripts/local/verify-images.sh --no-pull      # verify already-pulled images
#   scripts/local/verify-images.sh --tag=v0.1.0   # specific tag (default: latest)
#
# Prereqs (all standard on Bazzite/Aurora):
#   - podman (or docker)
#   - cosign
#
# Auth:
#   If the GHCR packages are still private, run
#       echo $PAT | podman login ghcr.io -u <user> --password-stdin
#   first. Once they're flipped to public via the org settings, no auth
#   is needed.
#
# Exit codes:
#   0 — every requested edition pulled + verified
#   1 — at least one edition failed (pull or verify)

set -euo pipefail

ALL_EDITIONS=(hearty chunky padkos braai)
REGISTRY="ghcr.io/macrosofty"
TAG="latest"
PULL=1

# Cosign keyless identity — must match the workflow that signs the images.
# If we ever rename the workflow file or the org/repo, update both here.
CERT_IDENTITY_REGEXP='https://github\.com/macrosofty/macrosofty/.*'
OIDC_ISSUER='https://token.actions.githubusercontent.com'

# --- Argument parsing -------------------------------------------------------
editions=()
for arg in "$@"; do
    case "$arg" in
        --no-pull)   PULL=0 ;;
        --tag=*)     TAG="${arg#--tag=}" ;;
        --help|-h)
            sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        -*)
            echo "Unknown flag: $arg" >&2
            echo "Try $0 --help" >&2
            exit 2 ;;
        *)
            editions+=("$arg") ;;
    esac
done
[ ${#editions[@]} -eq 0 ] && editions=("${ALL_EDITIONS[@]}")

# --- Validate edition names -------------------------------------------------
for e in "${editions[@]}"; do
    case "$e" in
        hearty|chunky|padkos|braai|bokkie) ;;
        *) echo "Unknown edition: $e (expected one of: ${ALL_EDITIONS[*]} bokkie)" >&2; exit 2 ;;
    esac
done

# --- Tooling check ----------------------------------------------------------
have() { command -v "$1" >/dev/null 2>&1; }
have podman || { echo "podman not on PATH" >&2; exit 2; }
have cosign || { echo "cosign not on PATH — try: rpm-ostree install cosign  (or brew install cosign)" >&2; exit 2; }

# --- Run --------------------------------------------------------------------
fails=()

for e in "${editions[@]}"; do
    img="$REGISTRY/$e:$TAG"
    echo
    echo "════════ $e ════════"
    echo "image:  $img"

    if [ "$PULL" -eq 1 ]; then
        echo "→ pulling..."
        if ! podman pull "$img" >/dev/null 2>&1; then
            echo "  ✗ pull failed"
            fails+=("$e:pull")
            continue
        fi
        echo "  ✓ pulled"
    fi

    echo "→ verifying signature..."
    if cosign verify "$img" \
        --certificate-identity-regexp="$CERT_IDENTITY_REGEXP" \
        --certificate-oidc-issuer="$OIDC_ISSUER" \
        > /tmp/cosign-out.json 2>/tmp/cosign-err.log; then
        sha=$(jq -r '.[0].critical.image["docker-manifest-digest"] // ""' /tmp/cosign-out.json)
        commit=$(jq -r '.[0].optional["1.3.6.1.4.1.57264.1.3"] // ""' /tmp/cosign-out.json)
        echo "  ✓ signature valid"
        echo "    digest: ${sha:0:23}…"
        echo "    commit: ${commit:0:7}"
    else
        echo "  ✗ signature verification failed:"
        sed 's/^/      /' /tmp/cosign-err.log | head -3
        fails+=("$e:verify")
        continue
    fi
done

echo
echo "═══════════════════════════"
if [ ${#fails[@]} -eq 0 ]; then
    echo "✓ all ${#editions[@]} edition(s) verified"
    exit 0
else
    echo "✗ failures: ${fails[*]}"
    exit 1
fi
