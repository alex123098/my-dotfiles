#!/usr/bin/env bash

function remove_nvim_cfg() {
	echo "Removeing previous NeoVim config..."
	rm -rf ~/.config/nvim/
	rm -rf ~/.local/share/nvim/
	rm -rf ~/.local/state/nvim/
	rm -rf ~/.cache/nvim/
	echo "Previous NeoVim config removed!"
}

function install_nvim_cfg() {
	if [ -d "${HOME}/.config/nvim" ]; then
		read -p "Remove previous nvim config? [y/N]" -n 1 -r remove_cfg
		[[ "${remove_cfg}" =~ ^[Yy]$ ]] && remove_nvim_cfg
	fi

	echo
	echo "Symlinking NeoVim config"
	stow -v nvim

	echo "Running headless install of NeoVim plugins..."
	nvim --headless "+Lazy! sync" +qa
	echo "NeoVim config installed!"
}

if [ -z "${1}" ]; then
	echo "Usage: install.sh <cmd>"
	exit 1
fi

case "${1}" in
"nvim")
	install_nvim_cfg
	;;
esac
