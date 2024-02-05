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
	read -p "Remove previous nvim config? [y/N]" -n 1 -r remove_cfg
	if [[ "${remove_cfg}" =~ ^[Yy]$ ]]; then
		remove_nvim_cfg
	fi

	echo "Installing NeoVim config..."
	mkdir -p ~/.config/nvim/

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
