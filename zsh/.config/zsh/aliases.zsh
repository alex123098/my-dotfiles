# LS
alias ls='ls --color=auto'
alias l='ls -lah'
alias la='ls -lAh'

# docker compose aliases
alias dcb='docker compose build'
alias dcr='docker compose run'
dcbr() {
	docker compose build $1 && docker compose run $1
}
alias dcup='docker compose up'
alias dcupb='docker compose up --build'
alias dcdn='docker compose down'
alias dcps='docker compose ps'
alias dcl='docker compose logs'
alias dclf='docker compose logs -f --tail=0'
alias dclF='docker compose logs -f'
alias dtop='docker top'

# git aliases
__git_main_branch() {
  # Verify if we under git repository
  command git rev-parse --git-dir &>/dev/null || return 1
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,master,default,trunk}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done

  echo "main"
  return 1
}
gdcol() {
  if ! git rev-parse >/dev/null 2>&1; then
    echo "Not a git repository"
    return 1
  fi
  git diff --name-only --line-prefix=`git rev-parse --show-toplevel`/ --diff-filter=d | xargs bat --diff
}
gdscol() {
  if ! git rev-parse >/dev/null 2>&1; then
    echo "Not a git repository"
    return 1
  fi
  git diff --name-only --line-prefix=`git rev-parse --show-toplevel`/ --diff-filter=d --staged | xargs bat --diff
}
alias g='git'
alias ga="git add"
alias gaa='git add --all'
alias gst='git status'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout $(__git_main_branch)'
alias gb="git branch"
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gbl='git branch -l'
alias gbla='git branch -la'
alias gc='git commit --verbose'
alias gcmsg='git commit -m'
alias gcmsgs='git commit -S -m'
alias gcs='git commit -S'
alias gca='git commit --verbose --all --amend'
alias gcna='git commit --verbose --no-edit --amend'
alias gd='git diff'
alias gds='git diff --staged'
alias gdc='git diff --cached'
alias gl='git pull'
alias gp='git push'
gpsup() {
	git push --set-upstream origin $(git branch --show-current)
}
alias grclean='git remote prune origin'
alias glgfull='git log --full-diff --pretty=format="%h%d: %s [%an]" -p'
alias glg='git log --oneline --decorate'
alias glgg='git log --oneline --decorate --graph --all'
alias glgs='git log --oneline --decorate --stat'
alias gm='git merge'
alias gcp='git cherry-pick'

# kubernetes
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgpw='kubectl get pods --watch'
alias kdp='kubectl describe pods'
alias kdel='kubectl delete'
alias kcuc='kubectl config use-context'
alias kccc='kubectl config current-context'
alias kgs='kubectl get svc'
alias kgsw='kubectl get svc --watch'
alias kds='kubectl describe svc'
alias kgd='kubectl get deploy'
alias kgdw='kubectl get deploy --watch'
alias kdd='kubectl describe deploy'
alias kl='kubectl logs'
alias klf='kubectl logs -f --tail=0'
alias klF='kubectl logs -f'
alias kcp='kubectl cp'
alias kgj='kubectl get job'
alias kgjw='kubectl get job --watch'
alias kdj='kubectl describe job'
alias kgcj='kubectl get cronjob'
alias kgcjw='kubectl get cronjob --watch'
alias kdcj='kubectl describe cronjob'
alias keti='kubectl exec -ti'
alias ktp='kubectl top pods'

# cat
alias cat='bat --paging=never'

# Send help to bat
# alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

# xclip
alias clip='xclip -sel clipboard'

# aws
agsjs() {
	aws secretsmanager get-secret-value --secret-id $1 --query SecretString --output text | jq $2
}
ags() {
	aws secretsmanager get-secret-value --secret-id $1 --query SecretString --output text
}

# kitty alias
alias icat='kitty icat'

# yay & pacman
alias yi='yay -S --noconfirm'
alias yfl='yay -Ql'  # yay file list
alias ys='yay -Ss'   # yay search
alias yrm='yay -Rns --noconfirm'
alias yli='yay -Qe'  # yay list installed
alias yrmc='yay -SC' # yay remove cache
sys_upgrade() {
	# just use eos-update if it's available
	if type -p eos-update &>/dev/null; then
		eos-update --aur
		return 0
	fi

	echo ":: Checking Arch Linux PGP keyring..."
	local installedkr="$(LANG= sudo pacman -Qi archlinux-keyring | grep -Po '(?<=Version\s{9}:\s).*')"
	local latestkr="$(LANG= sudo pacman -Si archlinux-keyring | grep -Po '(?<=Version\s{9}:\s).*')"
	if [ $installedkr != $latestkr ]; then
		echo " Updating Arch Linux PGP keyring..."
		sudo pacman -Sy --noconfirm archlinux-keyring
	else
		echo " Keyring is up to date."
	fi

	yay -Syuv --noconfirm
}
# show searchable package menu and install selected package(s)
alias yimenu="yay -Slq | fzf --multi --preview 'yay -Si {1}' | xargs yay -S --noconfirm"
# show searchable list of installed packages and remove selected
alias yrmenu="yay -Qq | fzf --multi --preview 'yay -Qi {1}' | xargs yay -Rns --noconfirm"

# tmux
alias t="tmux"
alias ta="tmux attach"
alias tks="tmux kill-session"
td() {
  query="$1"
  new_root="$(zoxide query "${query}" || exit 1)"
  tmux new-session -A -c "${new_root}"
}

# misc
alias vim='nvim'
alias grep='grep --color=always --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,node_modules}'
alias diff='diff --color=auto'
alias cless='LESS=" -Ri " LESSOPEN="| pygmentize -O style=tokyonight -g %s" less -M '
# launch yazi, cd after exit
yy() {
  local dir="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$dir"
  if cwd="$(command cat -- "$dir")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$dir"
}

# search file with preview, open for edit afterwards
frg() {
  result=$(rg --ignore-case --color=always --line-number --no-heading --with-filename --hidden -g "!.git" . |
      fzf --ansi \
          --color 'hl:-1:underline,hl+:-1:underline:reverse' \
          --delimiter ':' \
          --preview "bat --color=always {1} --highlight-line {2}" \
          --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
  file="${result%%:*}"
  linenumber=$(echo $result | cut -d ':' -f 2)
  if [ ! -z "$file" ]; then
    $EDITOR +"${linenumber}" "${file}"
  fi
}
alias kssh='kitten ssh'

tla() {
  local template_dir="$HOME/.tmux/layouts"
  if [ -z "$1" ]; then
    printf "Known templates: "
    ls "${template_dir}"
  else
    local full_path="${template_dir}/${1}"
    if [ -f "${full_path}" ]; then
      "${full_path}"
    else
      echo "Template not found: ${1}"
    fi
  fi
}

ytv() {
  bash ~/.config/zsh/ytv.sh
}