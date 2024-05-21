# Enable instant prompt. Should stay close to the top of .zshrc. The code between this
# and the line sourcing .p10k.zsh must not produce any output to stdout.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# define colors
eval $(dircolors -b)


# Source p10k theme
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# Syntax highlighting
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# Autosuggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Completions
source $ZDOTDIR/completions.zsh

# set navigation settings
source $ZDOTDIR/navigation.zsh

# set history settings
source $ZDOTDIR/history.zsh

# Activate p10k prompt
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

