fpath=($ZDOTDIR/completions $fpath)

source /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.zsh

autoload -U +X compinit && compinit

# init fzf integrations
eval $(fzf --zsh)

# dotnet cli completions
_dotnet() {
	local completions=("$(dotnet complete "$words")")

	if [ -z "$completions" ]; then
		_arguments '*::arguments: _normal'
		return
	fi
	_values = "${(ps:\n:)completions}"
}

compdef _dotnet dotnet

# aws cli completions
source /usr/bin/aws_zsh_completer.sh
