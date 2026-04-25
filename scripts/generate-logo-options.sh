#!/usr/bin/env bash
#
# generate-logo-options.sh — generate N logo candidates via Cloudflare Workers AI.
#
# The design-iteration script that produced the iter01-v3 master mark.
# Captures the prompt-loop so future logo work (per-edition variants,
# Bokkie's mark, a wordmark, a reskin) is one command instead of a
# remembered curl-jq-base64 dance.
#
# Usage:
#   scripts/generate-logo-options.sh <out-dir> [< prompts.txt]
#
#   echo "prompt one
#   prompt two
#   prompt three" | scripts/generate-logo-options.sh branding/iterations/iter03
#
# Each non-blank, non-comment line of input becomes one image. Output is
# v1.png, v2.png, ... in <out-dir>. Skips/reports prompts that hit
# Flux's NSFW filter or other API errors so a single bad prompt doesn't
# kill the run.
#
# Prereqs:
#   - jq, curl on PATH
#   - ~/.config/macrosofty/cf-token containing:
#       account_id=<cloudflare account id>
#       token=<api token with Workers AI: Read scope>
#
# Tunable env:
#   MODEL  — default @cf/black-forest-labs/flux-1-schnell. Schnell takes
#            JSON input; flux-2-dev wants multipart and won't work here.
#   STEPS  — default 8. Lower = faster + rougher. 8 is the schnell sweet spot.

set -euo pipefail

CFG=~/.config/macrosofty/cf-token
MODEL="${MODEL:-@cf/black-forest-labs/flux-1-schnell}"
STEPS="${STEPS:-8}"

OUT_DIR="${1:?usage: $0 <out-dir>   (prompts on stdin, one per line)}"

if [ ! -f "$CFG" ]; then
    echo "Error: $CFG not found." >&2
    echo "Drop a two-line .env-style file with account_id= and token=." >&2
    exit 1
fi

# shellcheck disable=SC1090
source "$CFG"
: "${account_id:?account_id missing in $CFG}"
: "${token:?token missing in $CFG}"

mkdir -p "$OUT_DIR"

n=0
ok=0
fail=0
while IFS= read -r prompt; do
    # Skip blank lines and lines starting with #
    [ -z "${prompt// }" ] && continue
    [ "${prompt:0:1}" = "#" ] && continue

    n=$((n + 1))
    out="$OUT_DIR/v${n}.png"
    tmp="$(mktemp --suffix=.json)"

    printf "  v%d: " "$n"
    curl -s -X POST -H "Authorization: Bearer $token" -H "Content-Type: application/json" \
        "https://api.cloudflare.com/client/v4/accounts/$account_id/ai/run/$MODEL" \
        -d "$(jq -nc --arg p "$prompt" --argjson s "$STEPS" '{prompt:$p, steps:$s}')" \
        -o "$tmp"

    if jq -e '.result.image' "$tmp" >/dev/null 2>&1; then
        jq -r '.result.image' "$tmp" | base64 -d > "$out"
        printf "✓ %d bytes  %s\n" "$(stat -c%s "$out")" "${out#$PWD/}"
        ok=$((ok + 1))
    else
        msg="$(jq -r '.errors[0].message // .' "$tmp" | head -1)"
        printf "✗ %s\n" "$msg"
        fail=$((fail + 1))
    fi
    rm -f "$tmp"
done

echo
echo "Done. $ok succeeded, $fail failed (of $n total)."
