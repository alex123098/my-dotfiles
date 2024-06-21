nvim=$(command -v nvim)
GPG_TTY=$(tty)
export GPG_TTY
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export GOBIN="$HOME/go/bin"

export PATH="$HOME/.dotnet/tools:$HOME/.local/bin:$GOBIN:$PATH"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export MANPAGER="${nvim} +Man!"
export EDITOR="${nvim}"
export VISUAL="${nvim}"

export HISTFILE="$XDG_DATA_HOME/zsh/history"
export HISTSIZE=10000
export SAVEHIST=$HISTSIZE

export FZF_DEFAULT_OPTS="--height 60% \
--border sharp \
--layout reverse \
--color=fg:#c0caf5,bg:#1a1b26,hl:#ff9e64 \
--color=fg+:#c0caf5,bg+:#292e42,hl+:#ff9e64 \
--color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff \
--color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a \
--prompt '∷ ' \
--pointer ▶ \
--marker ⇒"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -n 10'"
export FZF_COMPLETION_DIR_COMMANDS="cd pushd rmdir tree ls"