bindkey -v
export KEYTIMEOUT=1

# modify cursor depending on vi mode
modify_cursor() {
	cursor_block="\e[2 q"
	cursor_beam="\e[6 q"

	zle-keymap-select() {
		if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
			echo -ne $cursor_block;
		elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
			echo -ne $cursor_beam;
		fi
	}

	zle-line-init() {
		echo -ne $cursor_beam;
	}

	zle -N zle-keymap-select
	zle -N zle-line-init
}
modify_cursor
unset -f modify_cursor

# text objects support (ci", da(, etc.)
autoload -Uz select-bracketed select-quoted
zle -N select-quoted
zle -N select-bracketed
for km in viopp visual; do
  bindkey -M $km -- '-' vi-up-line-or-history
  for c in {a,i}${(s..)^:-\'\"\`\|,./:;=+@}; do
    bindkey -M $km $c select-quoted
  done
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $km $c select-bracketed
  done
done

# vim surround-like bindings
autoload -Uz vim-surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -M vicmd cs change-surround
bindkey -M vicmd ds delete-surround
bindkey -M vicmd ys add-surround
bindkey -M visual S add-surround

# completion mappings
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh