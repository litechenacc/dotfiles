#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$DOTFILES_DIR"

echo "[bootstrap] repo: $DOTFILES_DIR"

echo "[bootstrap] syncing git submodules"
git submodule update --init --recursive

echo "[bootstrap] linking dotfiles"
"$DOTFILES_DIR/scripts/link.sh"

echo "[bootstrap] bootstrapping mise"
"$DOTFILES_DIR/scripts/bootstrap-mise.sh"

echo "[bootstrap] health check"
"$DOTFILES_DIR/scripts/health-check.sh"

echo "[bootstrap] done"
echo "Open a new shell or run: source ~/.bashrc"
