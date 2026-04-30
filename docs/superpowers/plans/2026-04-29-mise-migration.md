# mise Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate from nvm + direnv + scattered runtime installs to mise as a unified runtime and environment manager across the dotfiles.

**Architecture:** Install mise via AUR, create a new `mise/` stow package with global config and Go packages list, wire mise into the shell replacing nvm/direnv/bun hooks, then clean up legacy PATH entries. Migration is gradual — old tools stay installed until each runtime is validated through mise.

**Tech Stack:** mise (jdx.dev), GNU Stow, zsh, Arch Linux (yay/AUR)

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `mise/.config/mise/config.toml` | Create | Global tool versions + Go settings |
| `mise/.config/mise/go-packages` | Create | Go tools auto-installed per Go version |
| `zsh/.config/zsh/.zshrc` | Modify | Replace nvm/direnv/bun hooks with mise activate |
| `zsh/.zshenv` | Modify | Remove `.dotnet/tools` and `GOBIN` from PATH |
| `git/.gitignore.global` | Modify | Add `.mise.local.toml` |

---

### Task 1: Install mise

**Files:** none (system install)

- [ ] **Step 1: Install mise from AUR**

```bash
yay -S mise
```

Expected output: mise installs successfully. Confirm with:

```bash
mise --version
```

Expected: prints a version string like `mise 2024.x.x`

- [ ] **Step 2: Commit nothing — installation is system-level, not tracked in dotfiles**

---

### Task 2: Create the `mise` stow package

**Files:**
- Create: `mise/.config/mise/config.toml`
- Create: `mise/.config/mise/go-packages`

- [ ] **Step 1: Create the directory structure**

```bash
mkdir -p ~/.dotfiles/mise/.config/mise
```

- [ ] **Step 2: Create `mise/.config/mise/config.toml`**

```toml
[tools]
node = "lts"
go = "latest"
python = "latest"
rust = "latest"
dotnet = "latest"
bun = "latest"

[settings]
go_set_goroot = true
go_default_packages_file = "~/.config/mise/go-packages"
dotnet_isolated = true
```

- [ ] **Step 3: Create `mise/.config/mise/go-packages`**

```
golang.org/x/tools/gopls@latest
github.com/go-delve/delve/cmd/dlv@latest
golang.org/x/tools/cmd/goimports@latest
mvdan.cc/gofumpt@latest
github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

- [ ] **Step 4: Commit**

```bash
cd ~/.dotfiles
git add mise/
git commit -m "feat: add mise stow package with global config and go-packages"
```

---

### Task 3: Stow the mise package and install tools

**Files:** none (symlinks + runtime installs)

- [ ] **Step 1: Dry-run stow to check for conflicts**

```bash
stow -nvt ~ mise
```

Expected: lines like `LINK: .config/mise/config.toml => ...` with no `CONFLICT` lines. If conflicts appear, remove or back up the conflicting files before proceeding.

- [ ] **Step 2: Apply stow**

```bash
stow -t ~ mise
```

- [ ] **Step 3: Verify symlinks**

```bash
ls -la ~/.config/mise/
```

Expected: `config.toml` and `go-packages` are symlinks pointing into `~/.dotfiles/mise/.config/mise/`.

- [ ] **Step 4: Run mise install to download all runtimes**

```bash
mise install
```

This downloads Node LTS, Go latest, Python latest, Rust latest, .NET latest, Bun latest, and then runs `go install` for each package in `go-packages`. This will take several minutes.

Expected: no errors. Each tool line shows `✓ installed`.

> **Note:** `go_default_packages_file` is only processed during a Go *install*, not when Go is already present. If Go was already installed before this step, the packages will not be installed automatically. In that case, force a reinstall: `mise uninstall go@latest && mise install`. This is expected behaviour.

---

### Task 4: Wire mise into the shell (alongside existing tools)

**Files:**
- Modify: `zsh/.config/zsh/.zshrc`

At this stage, mise is added but nvm/direnv/bun lines are kept. This lets you validate mise works before removing the old hooks.

- [ ] **Step 1: Add mise activation to `.zshrc` — insert it before the nvm line**

Open `~/.dotfiles/zsh/.config/zsh/.zshrc`. The file currently contains:

```zsh
# setup nvm
source /usr/share/nvm/init-nvm.sh
```

Add `eval "$(mise activate zsh)"` on a new line immediately before the nvm block:

```zsh
# mise — unified runtime manager
eval "$(mise activate zsh)"

# setup nvm
source /usr/share/nvm/init-nvm.sh
```

- [ ] **Step 2: Reload the shell**

```bash
exec zsh
```

- [ ] **Step 3: Verify mise-managed runtimes are active**

```bash
mise current
```

Expected: table showing node, go, python, rust, dotnet, bun all with versions.

```bash
node --version   # should show mise-managed Node LTS
go version       # should show mise-managed Go
dotnet --version # should show mise-managed .NET
dlv version      # should show delve compiled with mise Go
gopls version    # should show gopls compiled with mise Go
```

- [ ] **Step 4: Commit**

```bash
cd ~/.dotfiles
git add zsh/.config/zsh/.zshrc
git commit -m "feat: add mise shell activation to .zshrc"
```

---

### Task 5: Remove legacy shell hooks

**Files:**
- Modify: `zsh/.config/zsh/.zshrc`

Only proceed once Task 4 validation passed — all runtimes confirmed working through mise.

- [ ] **Step 1: Remove nvm, direnv, and bun lines from `.zshrc`**

Current state of the relevant lines in `~/.dotfiles/zsh/.config/zsh/.zshrc`:

```zsh
# setup nvm
source /usr/share/nvm/init-nvm.sh

# ...

source <(direnv hook zsh)
# bun completions
[ -s "/home/alex/.bun/_bun" ] && source "/home/alex/.bun/_bun"
```

Remove all three blocks. The file should retain only the mise activation line added in Task 4:

```zsh
# mise — unified runtime manager
eval "$(mise activate zsh)"
```

- [ ] **Step 2: Reload and verify nothing broke**

```bash
exec zsh
node --version
go version
dotnet --version
bun --version
```

All should still work via mise.

- [ ] **Step 3: Commit**

```bash
cd ~/.dotfiles
git add zsh/.config/zsh/.zshrc
git commit -m "chore: remove nvm, direnv, and bun shell hooks (replaced by mise)"
```

---

### Task 6: Clean up legacy PATH entries

**Files:**
- Modify: `zsh/.zshenv`

- [ ] **Step 1: Remove `.dotnet/tools` and `GOBIN` from PATH in `.zshenv`**

Current line in `~/.dotfiles/zsh/.zshenv`:

```zsh
export GOBIN="$HOME/go/bin"

export PATH="$HOME/.dotnet/tools:$HOME/.local/bin:$GOBIN:$PATH"
```

Replace with:

```zsh
export PATH="$HOME/.local/bin:$PATH"
```

Both `$HOME/.dotnet/tools` and `$GOBIN` are removed. mise manages the Go bin path via `GOROOT/bin` (set by `go_set_goroot = true`) and dotnet shims via its own shim directory, both of which are on PATH through `mise activate`.

- [ ] **Step 2: Reload and verify tools still accessible**

```bash
exec zsh
go version
dotnet --version
dlv version
gopls version
goimports --help 2>&1 | head -1
```

All should resolve to mise-managed versions.

- [ ] **Step 3: Commit**

```bash
cd ~/.dotfiles
git add zsh/.zshenv
git commit -m "chore: remove legacy GOBIN and .dotnet/tools from PATH (managed by mise)"
```

---

### Task 7: Add `.mise.local.toml` to global gitignore

**Files:**
- Modify: `git/.gitignore.global`

- [ ] **Step 1: Add the entry**

Open `~/.dotfiles/git/.gitignore.global` and add:

```
# mise per-project local overrides (personal env vars, not for team)
.mise.local.toml
```

- [ ] **Step 2: Verify git respects it**

```bash
cd /tmp && mkdir mise-test && cd mise-test && git init
touch .mise.local.toml
git status
```

Expected: `.mise.local.toml` does NOT appear in untracked files.

```bash
rm -rf /tmp/mise-test
```

- [ ] **Step 3: Commit**

```bash
cd ~/.dotfiles
git add git/.gitignore.global
git commit -m "chore: add .mise.local.toml to global gitignore"
```

---

### Task 8: Smoke test the full setup

**Files:** none

- [ ] **Step 1: Open a fresh shell and verify mise is the active manager**

```bash
exec zsh
mise current
```

Expected: all tools listed with their versions, no errors.

- [ ] **Step 2: Verify Go tools are version-consistent**

```bash
go version
dlv version
gopls version
```

The Go version reported by `go version` and the Go version embedded in `dlv version` / `gopls version` should match (same major.minor).

- [ ] **Step 3: Verify per-project override works**

```bash
mkdir /tmp/mise-project-test && cd /tmp/mise-project-test
cat > .mise.toml << 'EOF'
[tools]
node = "18"
EOF
mise install
node --version
```

Expected: `v18.x.x` (not the global LTS version).

```bash
cd ~ && node --version
```

Expected: global LTS version restored.

```bash
rm -rf /tmp/mise-project-test
```

- [ ] **Step 4: Verify `.mise.local.toml` env vars work**

```bash
mkdir /tmp/mise-env-test && cd /tmp/mise-env-test
cat > .mise.local.toml << 'EOF'
[env]
TEST_VAR = "hello-mise"
EOF
echo $TEST_VAR
```

Expected: `hello-mise`

```bash
cd ~ && echo $TEST_VAR
```

Expected: empty (var not set outside the directory).

```bash
rm -rf /tmp/mise-env-test
```

- [ ] **Step 5: All good — migration complete**

No commit needed. The migration is done.
