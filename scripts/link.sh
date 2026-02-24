#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.local/dotfiles}"
MAPPING_FILE="$DOTFILES_DIR/mapping.toml"

declare -a LINK_EVENTS=()
DIR_TOTAL=0
LINK_TOTAL=0
LINK_CREATED=0
LINK_RELINKED=0
LINK_REPLACED=0
LINK_UNCHANGED=0

expand_path() {
    local path="$1"
    local current_user="${USER:-$(id -un)}"

    path="${path//\$\{USER\}/$current_user}"
    path="${path//\$USER/$current_user}"
    path="${path//\$\{HOME\}/$HOME}"
    path="${path//\$HOME/$HOME}"

    printf '%s\n' "$path"
}

record_link_event() {
    local action="$1"
    local src="$2"
    local dst="$3"
    local backup_path="${4:-}"

    LINK_TOTAL=$((LINK_TOTAL + 1))

    case "$action" in
        created)
            LINK_CREATED=$((LINK_CREATED + 1))
            ;;
        relinked)
            LINK_RELINKED=$((LINK_RELINKED + 1))
            ;;
        replaced)
            LINK_REPLACED=$((LINK_REPLACED + 1))
            ;;
        unchanged)
            LINK_UNCHANGED=$((LINK_UNCHANGED + 1))
            ;;
    esac

    LINK_EVENTS+=("$action|$dst|$src|$backup_path")
}

print_link_stats() {
    local entry
    local action
    local dst
    local src
    local backup_path

    echo
    echo "Link operations:"
    if [[ ${#LINK_EVENTS[@]} -eq 0 ]]; then
        echo "  (no links configured)"
    else
        for entry in "${LINK_EVENTS[@]}"; do
            IFS='|' read -r action dst src backup_path <<<"$entry"
            if [[ -n "$backup_path" ]]; then
                echo "  [$action] $dst -> $src (backup: $backup_path)"
            else
                echo "  [$action] $dst -> $src"
            fi
        done
    fi

    echo
    echo "Link stats:"
    echo "  dirs ensured: $DIR_TOTAL"
    echo "  links processed: $LINK_TOTAL"
    echo "  links created: $LINK_CREATED"
    echo "  links relinked: $LINK_RELINKED"
    echo "  links replaced with backup: $LINK_REPLACED"
    echo "  links unchanged: $LINK_UNCHANGED"
}

link_item() {
    local src="$1"
    local dst="$2"
    local action=""
    local backup_path=""
    local src_resolved=""
    local dst_resolved=""

    if [[ ! -e "$src" && ! -L "$src" ]]; then
        echo "source does not exist: $src" >&2
        return 1
    fi

    mkdir -p "$(dirname "$dst")"

    src_resolved="$(readlink -f "$src" 2>/dev/null || true)"

    if [[ -L "$dst" ]]; then
        dst_resolved="$(readlink -f "$dst" 2>/dev/null || true)"

        if [[ -n "$src_resolved" && -n "$dst_resolved" && "$src_resolved" == "$dst_resolved" ]]; then
            record_link_event "unchanged" "$src" "$dst"
            return 0
        fi

        rm -f "$dst"
        action="relinked"
    elif [[ -e "$dst" ]]; then
        backup_path="${dst}.bak.$(date +%s)"
        mv "$dst" "$backup_path"
        action="replaced"
    else
        action="created"
    fi

    ln -s "$src" "$dst"
    record_link_event "$action" "$src" "$dst" "$backup_path"
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
                ensure_dir "$(expand_path "$first")"
                DIR_TOTAL=$((DIR_TOTAL + 1))
                ;;
            LINK)
                link_item "$DOTFILES_DIR/$first" "$(expand_path "$second")"
                ;;
            *)
                echo "unknown mapping entry: $kind" >&2
                return 1
                ;;
        esac
    done < <(
        python3 - "$MAPPING_FILE" <<'PY'
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

print_link_stats

echo "Dotfiles symlinked from $DOTFILES_DIR"
