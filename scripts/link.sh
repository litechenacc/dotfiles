#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.local/dotfiles}"
MAPPING_FILE="$DOTFILES_DIR/mapping.toml"

expand_home_path() {
    local path="$1"

    if [[ "$path" == "~" ]]; then
        printf '%s\n' "$HOME"
    elif [[ "$path" == "~/"* ]]; then
        printf '%s\n' "$HOME/${path#~/}"
    else
        printf '%s\n' "$path"
    fi
}

ensure_aqua() {
    if command -v aqua >/dev/null 2>&1; then
        return
    fi

    if ! command -v curl >/dev/null 2>&1; then
        echo "aqua is missing and curl is required to install it" >&2
        return 1
    fi

    mkdir -p "$HOME/.local/bin"
    curl -fsSL https://raw.githubusercontent.com/aquaproj/aqua-installer/v3.1.1/aqua-installer | bash -s -- -y -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
}

install_aqua_packages() {
    export AQUA_GLOBAL_CONFIG="$HOME/.config/aquaproj-aqua/aqua.yaml"
    aqua i -a
}

link_item() {
    local src="$1"
    local dst="$2"

    if [[ ! -e "$src" && ! -L "$src" ]]; then
        echo "source does not exist: $src" >&2
        return 1
    fi

    mkdir -p "$(dirname "$dst")"

    if [[ -L "$dst" ]]; then
        rm -f "$dst"
    elif [[ -e "$dst" ]]; then
        mv "$dst" "${dst}.bak.$(date +%s)"
    fi

    ln -s "$src" "$dst"
}

ensure_dir() {
    local path="$1"

    if [[ -L "$path" ]]; then
        rm -f "$path"
    elif [[ -e "$path" && ! -d "$path" ]]; then
        mv "$path" "${path}.bak.$(date +%s)"
    fi

    mkdir -p "$path"
}

apply_mapping() {
    if [[ ! -f "$MAPPING_FILE" ]]; then
        echo "mapping file not found: $MAPPING_FILE" >&2
        return 1
    fi

    while IFS=$'\t' read -r kind first second; do
        case "$kind" in
            DIR)
                ensure_dir "$(expand_home_path "$first")"
                ;;
            LINK)
                link_item "$DOTFILES_DIR/$first" "$(expand_home_path "$second")"
                ;;
            *)
                echo "unknown mapping entry: $kind" >&2
                return 1
                ;;
        esac
    done < <(
        python - "$MAPPING_FILE" <<'PY'
import sys
import tomllib

with open(sys.argv[1], "rb") as f:
    data = tomllib.load(f)

for entry in data.get("dirs", []):
    print(f"DIR\t{entry['path']}")

for entry in data.get("links", []):
    print(f"LINK\t{entry['source']}\t{entry['target']}")
PY
    )
}

apply_mapping

ensure_aqua
install_aqua_packages

echo "Dotfiles symlinked from $DOTFILES_DIR"
