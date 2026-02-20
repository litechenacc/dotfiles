#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias grep='grep --color=auto'

export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

export AQUA_GLOBAL_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml"
if command -v aqua >/dev/null 2>&1; then
    export PATH="$(aqua root-dir)/bin:$PATH"
fi

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

if command -v aqua >/dev/null 2>&1; then
    yazi_bin="$(aqua which yazi 2>/dev/null)"
    if [[ -n "$yazi_bin" ]]; then
        yazi_completion_dir="$(dirname "$yazi_bin")/completions"
        if [[ -f "$yazi_completion_dir/yazi.bash" ]]; then
            source "$yazi_completion_dir/yazi.bash"
        fi
        if [[ -f "$yazi_completion_dir/ya.bash" ]]; then
            source "$yazi_completion_dir/ya.bash"
        fi
    fi
fi

if [[ -f "$HOME/.bash_aliases" ]]; then
    source "$HOME/.bash_aliases"
fi

PS1='[\u@\h \W]\$ '

eval "$(starship init bash)"
