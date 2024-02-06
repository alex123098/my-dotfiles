#!/usr/bin/env bash

remove_nvim_cfg() {
	echo "Removeing previous NeoVim config..."
	rm -rf ~/.config/nvim/
	rm -rf ~/.local/share/nvim/
	rm -rf ~/.local/state/nvim/
	rm -rf ~/.cache/nvim/
	echo "Previous NeoVim config removed!"
}

install_nvim_cfg() {
	if [ -d "${HOME}/.config/nvim" ]; then
		read -p "Remove previous nvim config? [y/N]" -n 1 -r remove_cfg
		echo
		[[ "${remove_cfg}" =~ ^[Yy]$ ]] && remove_nvim_cfg
	fi

	echo "Symlinking NeoVim config"
	stow -v nvim

	echo "Running headless install of NeoVim plugins..."
	nvim --headless "+Lazy! sync" +qa
	echo "NeoVim config installed!"
}

install_kitty_cfg() {
	if [ -d "${HOME}/.config/kitty" ]; then
		read -p "Remove previous kitty config? [y/N]" -n 1 -r remove_cfg
		echo
		[[ "${remove_cfg}" =~ ^[Yy]$ ]] && rm -rf ~/.config/kitty/
	fi

	echo "Symlinking kitty config"
	stow -v kitty
	echo "Kitty config installed!"
}

print_usage() {
	echo "Usage: install.sh <cmd>"
	echo "Commands:"
	echo "  nvim_cfg: Install NeoVim config"
	echo "  kitty_cfg: Install Kitty config"
}

get_gpg_keyid() {
	gpg --list-secret-keys --keyid-format long "$(git config --get user.email)" | sed 's/^sec.*\/\([[:alnum:]]*\).*$/\1/' | head -n 1
}

if [ -z "${1}" ]; then
	print_usage
	exit 1
fi

case "${1}" in
"nvim_cfg")
	install_nvim_cfg
	;;
"kitty_cfg")
	install_kitty_cfg
	;;
*)
	print_usage
	exit 1
	;;
esac
