#!/usr/bin/env bash
# new-project.sh — scaffold a new Macrosofty satellite project.
#
# Usage:
#   scripts/new-project.sh <slug> "<Display Title>" "<one-line description>"
#
# Example:
#   scripts/new-project.sh share-and-serve "Share & Serve" \
#     "One-tap LAN file + media share for trusted people on your network."
#
# What it does:
#   1. Creates /var/mnt/code/<slug>/ from the templates in this folder.
#   2. Substitutes {{SLUG}}, {{TITLE}}, {{DESCRIPTION}}, {{TODAY}} in templates.
#   3. Initialises a git repo, makes the first commit.
#   4. (Unless --no-remote) creates a private GitHub repo at macrosofty/<slug>
#      and pushes. Prefers `gh` if available; falls back to the GitHub REST API
#      using $GITHUB_TOKEN from ~/.config/macrosofty/load-tokens.sh.
#
# Flags:
#   --public         create the GitHub repo as public (default: private)
#   --no-remote      skip the GitHub repo creation + push step
#   --parent <dir>   parent directory to create the project in
#                    (default: /var/mnt/code)
#   -h, --help       show this help

set -euo pipefail

# ─ paths ──────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/templates"
LICENSE_SRC="${SCRIPT_DIR}/../LICENSE"
PARENT_DIR_DEFAULT="/var/mnt/code"
ORG="macrosofty"

# ─ helpers ────────────────────────────────────────────────────────────────────

red()   { printf '\033[0;31m%s\033[0m\n' "$*" >&2; }
green() { printf '\033[0;32m%s\033[0m\n' "$*"; }
blue()  { printf '\033[0;34m%s\033[0m\n' "$*"; }
warn()  { printf '\033[0;33m%s\033[0m\n' "$*" >&2; }

die()   { red "error: $*"; exit 1; }

usage() {
  sed -n '2,/^set -euo/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//;/^set -euo/d'
  exit "${1:-0}"
}

# Render a template file: replace {{SLUG}}, {{TITLE}}, {{DESCRIPTION}}, {{TODAY}}.
render() {
  local src="$1" dst="$2"
  python3 - "$src" "$dst" "$SLUG" "$TITLE" "$DESCRIPTION" "$TODAY" <<'PY'
import sys, pathlib
src, dst, slug, title, desc, today = sys.argv[1:7]
text = pathlib.Path(src).read_text()
text = (text.replace("{{SLUG}}", slug)
            .replace("{{TITLE}}", title)
            .replace("{{DESCRIPTION}}", desc)
            .replace("{{TODAY}}", today))
out = pathlib.Path(dst)
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(text)
PY
}

# ─ args ───────────────────────────────────────────────────────────────────────

VISIBILITY="private"
SKIP_REMOTE=0
PARENT_DIR="$PARENT_DIR_DEFAULT"
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --public)     VISIBILITY="public"; shift ;;
    --private)    VISIBILITY="private"; shift ;;
    --no-remote)  SKIP_REMOTE=1; shift ;;
    --parent)     PARENT_DIR="$2"; shift 2 ;;
    -h|--help)    usage 0 ;;
    --*)          die "unknown flag: $1 (try --help)" ;;
    *)            POSITIONAL+=("$1"); shift ;;
  esac
done

[[ ${#POSITIONAL[@]} -eq 3 ]] || { red "expected 3 positional args, got ${#POSITIONAL[@]}"; usage 1; }

SLUG="${POSITIONAL[0]}"
TITLE="${POSITIONAL[1]}"
DESCRIPTION="${POSITIONAL[2]}"
TODAY="$(date +%F)"

# slug sanity check — github + filesystem safe
[[ "$SLUG" =~ ^[a-z0-9][a-z0-9_-]*$ ]] \
  || die "slug must be lowercase alphanumerics + dashes/underscores, starting with letter or digit (got: $SLUG)"

PROJECT_DIR="${PARENT_DIR}/${SLUG}"
[[ ! -e "$PROJECT_DIR" ]] || die "directory already exists: $PROJECT_DIR"
[[ -d "$TEMPLATE_DIR" ]]  || die "template directory missing: $TEMPLATE_DIR"
[[ -f "$LICENSE_SRC"  ]]  || die "LICENSE source missing: $LICENSE_SRC"

# ─ scaffold ───────────────────────────────────────────────────────────────────

blue "▶ scaffolding ${SLUG} at ${PROJECT_DIR}"
mkdir -p "$PROJECT_DIR"

render "${TEMPLATE_DIR}/CLAUDE.md.tmpl"        "${PROJECT_DIR}/CLAUDE.md"
render "${TEMPLATE_DIR}/README.md.tmpl"        "${PROJECT_DIR}/README.md"
render "${TEMPLATE_DIR}/ROADMAP.md.tmpl"       "${PROJECT_DIR}/ROADMAP.md"
render "${TEMPLATE_DIR}/NEXT_SESSION.md.tmpl"  "${PROJECT_DIR}/NEXT_SESSION.md"
render "${TEMPLATE_DIR}/CONTRIBUTING.md.tmpl"  "${PROJECT_DIR}/CONTRIBUTING.md"
render "${TEMPLATE_DIR}/SESSION_NOTES.md.tmpl" "${PROJECT_DIR}/SESSION_NOTES_${TODAY}.md"
render "${TEMPLATE_DIR}/gitignore.tmpl"        "${PROJECT_DIR}/.gitignore"
cp "$LICENSE_SRC" "${PROJECT_DIR}/LICENSE"

green "✓ wrote $(find "$PROJECT_DIR" -maxdepth 1 -type f | wc -l) files"

# ─ git init + first commit ────────────────────────────────────────────────────

cd "$PROJECT_DIR"
git init -q -b main
git add .
git -c user.name="${GIT_AUTHOR_NAME:-Elje}" \
    -c user.email="${GIT_AUTHOR_EMAIL:-elje.vandeventer@oks.co.za}" \
    commit -q -m "Initial scaffold: ${TITLE}

Generated from the Macrosofty satellite-project template
(scripts/new-project.sh in github.com/${ORG}/macrosofty).

${DESCRIPTION}"
green "✓ git initialised + first commit"

# ─ github repo creation + push ────────────────────────────────────────────────

if [[ "$SKIP_REMOTE" -eq 1 ]]; then
  warn "↷ skipping GitHub repo creation (--no-remote)"
  echo
  green "Done. Project at: ${PROJECT_DIR}"
  echo "Next: cd ${PROJECT_DIR} && \$EDITOR ROADMAP.md"
  exit 0
fi

# Try to source tokens if present (idempotent — no error if missing).
if [[ -f "${HOME}/.config/macrosofty/load-tokens.sh" ]]; then
  # shellcheck source=/dev/null
  source "${HOME}/.config/macrosofty/load-tokens.sh" >/dev/null 2>&1 || true
fi

create_with_gh() {
  local vis_flag="--${VISIBILITY}"
  blue "▶ creating ${ORG}/${SLUG} on GitHub via gh (${VISIBILITY})"
  gh repo create "${ORG}/${SLUG}" \
    "$vis_flag" \
    --source=. \
    --remote=origin \
    --push \
    --description "${DESCRIPTION}"
}

create_with_curl() {
  local token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
  [[ -n "$token" ]] || die "no GITHUB_TOKEN/GH_TOKEN in env (and gh not found). source ~/.config/macrosofty/load-tokens.sh first."

  local private_json="true"
  [[ "$VISIBILITY" == "public" ]] && private_json="false"

  blue "▶ creating ${ORG}/${SLUG} on GitHub via REST API (${VISIBILITY})"
  local payload
  payload=$(python3 -c '
import json, sys
print(json.dumps({
  "name": sys.argv[1],
  "description": sys.argv[2],
  "private": sys.argv[3] == "true",
  "has_issues": True,
  "has_projects": False,
  "has_wiki": False,
  "auto_init": False,
}))
' "$SLUG" "$DESCRIPTION" "$private_json")

  local resp http
  resp=$(curl -sS -w '\n%{http_code}' \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${token}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -X POST "https://api.github.com/orgs/${ORG}/repos" \
    -d "$payload")
  http="${resp##*$'\n'}"
  body="${resp%$'\n'*}"

  if [[ "$http" != "201" ]]; then
    red "GitHub API responded with HTTP ${http}"
    echo "$body" >&2
    die "repo creation failed"
  fi

  git remote add origin "git@github.com:${ORG}/${SLUG}.git" 2>/dev/null \
    || git remote set-url origin "git@github.com:${ORG}/${SLUG}.git"
  # Prefer SSH; fall back to HTTPS+token if SSH push fails.
  if ! git push -u origin main 2>/dev/null; then
    warn "ssh push failed; retrying via https with token"
    git remote set-url origin "https://x-access-token:${token}@github.com/${ORG}/${SLUG}.git"
    git push -u origin main
  fi
}

if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  create_with_gh
else
  if command -v gh >/dev/null 2>&1; then
    warn "gh present but not authenticated; falling back to REST API"
  else
    warn "gh not found; falling back to REST API via curl"
  fi
  create_with_curl
fi

green "✓ pushed to https://github.com/${ORG}/${SLUG}"
echo
green "Done. Project at: ${PROJECT_DIR}"
echo "Next: cd ${PROJECT_DIR} && \$EDITOR ROADMAP.md"
