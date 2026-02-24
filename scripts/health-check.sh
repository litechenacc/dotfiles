#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.local/dotfiles}"
MAPPING_FILE="$DOTFILES_DIR/mapping.toml"

PASS_COUNT=0
FAIL_COUNT=0
DIR_CHECK_COUNT=0
LINK_CHECK_COUNT=0

expand_path() {
    local path="$1"
    local current_user="${USER:-$(id -un)}"

    path="${path//\$\{USER\}/$current_user}"
    path="${path//\$USER/$current_user}"
    path="${path//\$\{HOME\}/$HOME}"
    path="${path//\$HOME/$HOME}"

    printf '%s\n' "$path"
}

report_pass() {
    local message="$1"
    PASS_COUNT=$((PASS_COUNT + 1))
    echo "[OK] $message"
}

report_fail() {
    local message="$1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    echo "[FAIL] $message"
}

check_dir() {
    local raw_path="$1"
    local path

    path="$(expand_path "$raw_path")"
    DIR_CHECK_COUNT=$((DIR_CHECK_COUNT + 1))

    if [[ -L "$path" ]]; then
        report_fail "DIR $path is a symlink (expected real directory)"
        return
    fi

    if [[ -d "$path" ]]; then
        report_pass "DIR $path"
    elif [[ -e "$path" ]]; then
        report_fail "DIR $path exists but is not a directory"
    else
        report_fail "DIR $path is missing"
    fi
}

check_link() {
    local src_rel="$1"
    local dst_raw="$2"
    local src
    local dst
    local src_resolved
    local dst_resolved
    local current_target

    src="$DOTFILES_DIR/$src_rel"
    dst="$(expand_path "$dst_raw")"
    LINK_CHECK_COUNT=$((LINK_CHECK_COUNT + 1))

    if [[ ! -e "$src" && ! -L "$src" ]]; then
        report_fail "LINK source missing: $src"
        return
    fi

    if [[ ! -L "$dst" ]]; then
        if [[ -e "$dst" ]]; then
            report_fail "LINK $dst exists but is not a symlink"
        else
            report_fail "LINK $dst is missing"
        fi
        return
    fi

    src_resolved="$(readlink -f "$src" 2>/dev/null || true)"
    dst_resolved="$(readlink -f "$dst" 2>/dev/null || true)"
    current_target="$(readlink "$dst")"

    if [[ -z "$dst_resolved" ]]; then
        report_fail "LINK $dst is broken (current: $current_target)"
        return
    fi

    if [[ -z "$src_resolved" ]]; then
        report_fail "LINK source cannot be resolved: $src"
        return
    fi

    if [[ "$dst_resolved" == "$src_resolved" ]]; then
        report_pass "LINK $dst -> $current_target"
    else
        report_fail "LINK $dst points to $current_target, expected $src"
    fi
}

run_checks() {
    if [[ ! -f "$MAPPING_FILE" ]]; then
        echo "mapping file not found: $MAPPING_FILE" >&2
        return 1
    fi

    while IFS=$'\t' read -r kind first second; do
        case "$kind" in
            DIR)
                check_dir "$first"
                ;;
            LINK)
                check_link "$first" "$second"
                ;;
            *)
                report_fail "unknown mapping entry: $kind"
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

run_checks

echo
echo "Health-check stats:"
echo "  dirs checked: $DIR_CHECK_COUNT"
echo "  links checked: $LINK_CHECK_COUNT"
echo "  checks passed: $PASS_COUNT"
echo "  checks failed: $FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
    exit 1
fi

echo "Health-check passed"
