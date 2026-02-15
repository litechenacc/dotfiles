#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.local/dotfiles}"

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

link_item "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"
link_item "$DOTFILES_DIR/bash/.bash_aliases" "$HOME/.bash_aliases"
link_item "$DOTFILES_DIR/niri/.config/niri" "$HOME/.config/niri"
link_item "$DOTFILES_DIR/nvim/.config/nvim" "$HOME/.config/nvim"
link_item "$DOTFILES_DIR/noctalia/.config/noctalia" "$HOME/.config/noctalia"
ensure_dir "$HOME/.config/opencode"
link_item "$DOTFILES_DIR/opencode/.config/opencode/global-AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
link_item "$DOTFILES_DIR/opencode/.config/opencode/skills" "$HOME/.config/opencode/skills"
link_item "$DOTFILES_DIR/aqua/.config/aquaproj-aqua/aqua.yaml" "$HOME/.config/aquaproj-aqua/aqua.yaml"

ensure_aqua
install_aqua_packages

echo "Dotfiles symlinked from $DOTFILES_DIR"
