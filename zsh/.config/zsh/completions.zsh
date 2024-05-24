autoload -Uz bashcompinit && bashcompinit -i
autoload -U +X compinit && compinit

complete -C aws_completer aws

source /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.zsh

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle 'fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle 'fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# init fzf integrations
eval $(fzf --zsh)
