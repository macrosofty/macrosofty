#!/bin/bash
# Run the Macrosofty website locally.
# Auto-installs deps on first run (or after package.json changes).
set -e

cd "$(dirname "$0")"

echo "============================================================"
echo " Macrosofty website — Astro dev server"
echo "============================================================"

# Pick a package manager — pnpm preferred, fall back to npm
if command -v pnpm &>/dev/null; then
    PM=pnpm
elif command -v npm &>/dev/null; then
    PM=npm
else
    echo "ERROR: Neither pnpm nor npm found on PATH."
    echo "Install Node.js (which bundles npm): https://nodejs.org/"
    echo "Or install pnpm:  curl -fsSL https://get.pnpm.io/install.sh | sh -"
    exit 1
fi

echo "Using: $PM  ($(command -v $PM))"
echo ""

# Install deps if node_modules is missing or package.json is newer than the lockfile
need_install=0
if [ ! -d node_modules ]; then
    need_install=1
elif [ package.json -nt node_modules ]; then
    need_install=1
fi

if [ "$need_install" = 1 ]; then
    echo "Installing dependencies..."
    $PM install
    echo ""
fi

echo "Starting dev server on http://localhost:8006"
echo "Hot reload is on — save any file and the browser refreshes."
echo "Ctrl-C to stop."
echo ""

$PM run dev
