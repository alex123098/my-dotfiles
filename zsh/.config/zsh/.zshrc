# Enable instant prompt. Should stay close to the top of .zshrc. The code between this
# and the line sourcing .p10k.zsh must not produce any output to stdout.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# define colors
export LS_COLORS=$(vivid generate $ZDOTDIR/vivid-theme.yml)

unsetopt beep

# Source p10k theme
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

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

# Activate p10k prompt
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source $ZDOTDIR/aliases.zsh

source <(direnv hook zsh)
