fpath=($ZDOTDIR/funcs $fpath)
autoload -Uz bashcompinit && bashcompinit -i
autoload -U compinit && compinit

# init fzf integrations
eval $(fzf --zsh)

# source /usr/bin/aws_zsh_completer.sh
compdef '_docker compose build' dcbr

source /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.zsh

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle 'fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle 'fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

if type "glow" > /dev/null; then
  eval $(glow completion zsh)
fi

if type "opencode" > /dev/null; then
  eval "$(opencode completion zsh)"
fi

export NVM_COMPLETION=true