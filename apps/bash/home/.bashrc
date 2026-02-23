#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias grep='grep --color=auto'

export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

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

PS1='[\u@\h \W]\$ '

eval "$(starship init bash)"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

