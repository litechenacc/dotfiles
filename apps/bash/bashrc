#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias grep='grep --color=auto'

path_prepend() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}

path_cleanup() {
    local cleaned=""
    local p

    IFS=':' read -r -a _path_parts <<< "$PATH"
    for p in "${_path_parts[@]}"; do
        [[ -z "$p" || "$p" == *"/.bun/bin"* ]] && continue
        case ":$cleaned:" in
            *":$p:"*) ;;
            *) cleaned="${cleaned:+$cleaned:}$p" ;;
        esac
    done

    PATH="$cleaned"
    unset _path_parts p cleaned
}

export PNPM_HOME="$HOME/.local/share/pnpm"
path_prepend "$HOME/.opencode/bin"
path_prepend "$HOME/.local/bin"
path_prepend "$PNPM_HOME"

eval "$(~/.local/bin/mise activate bash)"
path_cleanup

if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
elif [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
fi

if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --bash)"
fi

if command -v bat >/dev/null 2>&1; then
    source <(bat --completion bash)
fi

if command -v rg >/dev/null 2>&1; then
    source <(rg --generate complete-bash)
fi

if [[ -f "$HOME/.bash_aliases" ]]; then
    source "$HOME/.bash_aliases"
fi

eval "$(starship init bash)"

