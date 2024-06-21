# This repo

This is just a collection of my dotfiles and a couple of scripts that I use day-to-day.

## Installation

Make sure you have `stow` installed.

Clone this repo somewhere, I keep it under my home directory like so: `~/.dotfiles`
Then just `cd` into the repo dir and run:

```bash
# dry-run, do not change anything:
stow -nvt ~ [config_to_apply]

# apply the config:
stow -t ~ [config_to_apply]

# i.e. for zsh config:
stow -t ~ zsh
```
Note that the `-t ~` part is required only if you have this repo cloned anywhere but your home directory.

## ZSH setup prerequisites

These are the CLI tools and zsh plugins I have installed:

- bat
- powerlevel10k
- fzf
- fzf-tab
- zsh-syntax-highlighting
- zsh-autosuggestions
- zsh-vi-mode
- zoxide
- aws zsh completer (typically installed with aws CLI)
- direnv
- ripgrep
- vivid
- thefuck