#!/usr/bin/env bash
set -euo pipefail

MISE_BIN="${MISE_BIN:-$HOME/.local/bin/mise}"

ensure_mise() {
    if command -v mise >/dev/null 2>&1; then
        return 0
    fi

    if [[ -x "$MISE_BIN" ]]; then
        export PATH="$(dirname "$MISE_BIN"):$PATH"
        return 0
    fi

    echo "[bootstrap-mise] installing mise..."
    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
}

install_tools() {
    local mise_cmd
    mise_cmd="$(command -v mise || true)"
    if [[ -z "$mise_cmd" && -x "$MISE_BIN" ]]; then
        mise_cmd="$MISE_BIN"
    fi

    if [[ -z "$mise_cmd" ]]; then
        echo "[bootstrap-mise] mise not found after install" >&2
        exit 1
    fi

    local config_file="${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.toml"
    if [[ ! -f "$config_file" ]]; then
        echo "[bootstrap-mise] no $config_file found, skipping tool installation"
        return 0
    fi

    echo "[bootstrap-mise] installing tools from $config_file"
    "$mise_cmd" install
}

ensure_mise
install_tools

echo "[bootstrap-mise] done"
