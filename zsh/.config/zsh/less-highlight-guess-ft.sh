#! /bin/sh

set -eu

SRCLANG=${SRCLANG:-}

guess_lang() {
	lang=$(echo -e ${1:-} | file - | cut -d" " -f2)
	echo $(tr [A-Z] [a-z] <<< "$lang")
}

is_lang_known() {
	fallback=""
	lang=$(source-highlight --lang-list | cut -d' ' -f1 | grep "${1:-}" || true)
	lang=${lang:-$fallback}
	echo $lang
}

for src in "$@"; do
	case $src in
		*ChangeLog|*changelog)
			source-highlight --failsafe -f esc --lang-def=changelog.lang --style-file=esc.style -i "$src"
			;;
		*Makefile|*makefile)
			source-highlight --failsafe -f esc --lang-def=makefile.lang --style-file=esc.style -i "$src"
			;;
		*.tar|*.tgz|*.gz|*.bz2|*.xz)
			lesspipe.sh "$src"
			;;
		*)
			if [[ "$src" != "-" && $(basename "$src") =~ \. ]]; then
				source-highlight --failsafe --infer-lang -f esc --style-file=esc.style -i "$src"
			else
				IFS= file=$([ "src" = "-" ] && command cat || command cat "$src")
				lang=$(guess_lang $file)
				lang=$(is_lang_known $lang)

				[ -n "$SRCLANG" ] && lang=$SRCLANG

				if [ -n "$lang" ]; then
					echo $file | source-highlight --failsafe -f esc --src-lang=$lang --style-file=esc.style
				else
					echo $file
				fi
			fi
			;;
	esac
done
