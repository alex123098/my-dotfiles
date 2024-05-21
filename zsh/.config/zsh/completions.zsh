source /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.zsh

autoload -U +X compinit && compinit

# init fzf integrations
eval $(fzf --zsh)
