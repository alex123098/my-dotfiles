# define colors
export LS_COLORS=$(vivid generate $ZDOTDIR/vivid-theme.yml)

unsetopt beep

# set navigation settings
source $ZDOTDIR/navigation.zsh

# Syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Autosuggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Completions
source $ZDOTDIR/completions.zsh
autoload -Uz +X _dcbr
compdef _dcbr dcbr

# set history settings
source $ZDOTDIR/history.zsh

# the most useful command in the world ;)
eval $(thefuck --alias)

# set keybindings
source $ZDOTDIR/keybindings.zsh

# setup nvm
source /usr/share/nvm/init-nvm.sh

# Activate oh-my-posh
eval "$(oh-my-posh init zsh --config ~/.config/zsh/omp.conf.json)"

source $ZDOTDIR/aliases.zsh

source <(direnv hook zsh)