#!/usr/bin/env bash

source /etc/os-release

install_stow() {
	echo "Installing stow"
	sudo apt-get update
	sudo apt-get install -y stow
	echo
	echo "Stow is installed"
}

install_docker() {
	echo "Adding docker package sources"
	type -p curl >/dev/null || sudo apt-get install -y curl
	type -p update-ca-crertificates >/dev/null || sudo apt-get install -y ca-certificates
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
	echo "Installing docker"
	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin
	echo
	echo "Docker is installed"
}

install_gh_cli() {
	echo "Adding gh-cli package sources"
	type -p curl >/dev/null || sudo apt-get install -y curl
	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/etc/apt/keyrings/githubcli-archive-keyring.gpg
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
    https://cli.github.com/packages stable main" |
		sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
	echo "Installing gh-cli"
	sudo apt-get update
	sudo apt-get install -y gh
	echo
	echo "gh-cli is installed. Don't forget to run 'gh auth login' to authenticate"
}

install_k8s() {
	echo "Adding k8s package sources"
	type -p curl >/dev/null || sudo apt-get install -y curl
	type -p update-ca-crertificates >/dev/null || sudo apt-get install -y ca-certificates
	test -f /usr/share/doc/apt-transport-https/copyright || sudo apt-get install -y apt-transport-https
	type -p gpg >/dev/null || sudo apt-get install -y gnupg
	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
	echo \
		'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' |
		sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null
	echo "Installing kubectl"
	sudo apt-get update
	sudo apt-get install -y kubectl
	echo
	echo "kubectl is installed"
}

install_nvim() {
	read -p "Install [s]table or [n]ightly version? Nightly is recommended [s/N]" -n 1 -r nvim_version
	echo
	if [[ "${nvim_version}" =~ ^[Ss]$ ]]; then
		nvim_version="stable"
	else
		nvim_version="unstable"
	fi
	echo "Adding neovim package sources"
	sudo add-apt-repository -y ppa:neovim-ppa/${nvim_version}
	echo "Installing neovim"
	sudo apt-get update
	sudo apt-get install -y neovim
	echo
	echo "Neovim is installed"
	read -p "Do you want to set neovim as default editor? [Y/n]" -n 1 -r set_nvim
	echo
	[[ "${set_nvim}" =~ ^[Nn]$ ]] && return
	echo "Setting neovim as default editor"
	sudo update-alternatives --install /usr/bin/editor editor "$(which nvim)" 50
}

install_pritunl() {
	echo "Adding pritunl-client package sources"
	echo "deb https://repo.pritunl.com/stable/apt jammy main" | sudo tee /etc/apt/sources.list.d/pritunl.list
	type -p gpg >/dev/null || sudo apt-get install -y gnupg
	gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
	gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A | sudo tee /etc/apt/trusted.gpg.d/pritunl.asc
	echo "Installing pritunl-client"
	sudo apt-get update
	sudo apt-get install -y pritunl-client-electron
	echo
	echo "Pritunl client is installed"
}

install_zsh() {
	echo "Installing zsh"
	sudo apt-get update
	sudo apt-get install -y zsh
	read -p "Do you want to set zsh as default shell? [Y/n]" -n 1 -r set_zsh
	echo
	if [[ "${set_zsh}" =~ ^[Nn]$ ]]; then
		echo "Zsh is installed"
		return
	fi
	echo "Setting zsh as default shell"
	sudo chsh -s "$(which zsh)" "$(whoami)"
	echo "Zsh is installed and set as default shell"
}

install_terminal() {
	echo "Installing kitty as a default terminal emulator"
	sudo apt-get update
	sudo apt-get install -y kitty
	echo "Copying configuration for kitty"
	mkdir -p "$HOME/.config/kitty"
	cp -r ./kitty/* "$HOME/.config/kitty"
	read -p "Do you want to set kitty as default terminal emulator? [Y/n]" -n 1 -r set_kitty
	echo
	[[ "${set_kitty}" =~ ^[Nn]$ ]] && return
	echo "Setting kitty as default terminal emulator"
	sudo update-alternatives --set x-terminal-emulator "$(which kitty)"
}
