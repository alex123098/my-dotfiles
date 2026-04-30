# mise Migration Design

**Date:** 2026-04-29  
**Status:** Approved

## Goal

Migrate from the current fragmented tool management setup (nvm, direnv, bun, system dotnet) to [mise](https://mise.jdx.dev/) as a unified runtime and environment manager. Enables per-project tool versions (especially .NET SDK versions across projects) and a consistent workflow before introducing team-wide adoption.

## Current State

| Concern | Current tool |
|---|---|
| Node.js version management | nvm (slow shell startup) |
| Per-directory env vars | direnv + `.envrc` |
| Bun | Installed directly to `~/.bun` |
| .NET SDK | System install, `~/.dotnet/tools` in PATH |
| Go | System install, `GOBIN` in PATH; tools installed via `go install` |
| Python / Rust | System install |

## Target State

| Concern | New tool |
|---|---|
| All runtime versions | mise global config |
| Per-project tool versions | `.mise.toml` (committed) |
| Per-project env vars | `.mise.local.toml` (gitignored, personal) |
| Shell activation | Single `eval "$(mise activate zsh)"` |

## Approach

**Option A — mise as full environment manager.** mise replaces both nvm and direnv. Shell integration is a single eval hook. Global defaults live in `~/.config/mise/config.toml`. Per-project overrides live in `.mise.toml`. Migration is gradual: nvm stays installed until Node is validated through mise, direnv stays until all `.envrc` files are migrated.

## Architecture

### New stow package: `mise/`

```
mise/
└── .config/
    └── mise/
        ├── config.toml       ← global tool versions + settings
        └── go-packages       ← Go tools to auto-install with each Go version
```

### Global config (`~/.config/mise/config.toml`)

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

- `lts` / `latest` resolved and pinned at install time
- Activated automatically when no project-level `.mise.toml` is found

### Go tooling

Go tools (delve, gopls, goimports, etc.) must be compiled with the same Go version that mise activates — otherwise version skew causes subtle breakage (e.g. delve compiled with Go 1.24 cannot debug binaries compiled with Go 1.25+).

mise handles this via:

- **`go_set_goroot = true`** — sets `GOROOT` to the mise-managed Go installation, ensuring `go install` uses the correct SDK. This is the default; included explicitly for clarity.
- **`go_default_packages_file`** — points to `~/.config/mise/go-packages`, a plain text file listing Go tools to auto-install when the Go version changes

> **Note — `go_set_gopath` is deprecated:** mise previously offered `go_set_gopath = true` to set `GOPATH` to a mise-managed path. This setting is now deprecated and emits a warning. It has been removed from the config. Go tools installed via `go install` land in `$GOROOT/bin` (managed by mise via `go_set_goroot`), which is sufficient.

> **Note — Go packages require a Go reinstall to trigger:** `go_default_packages_file` is only processed during a Go *install*, not when Go is already present and `mise install` is re-run. If you add packages to the file or change the settings key, you must force a Go reinstall (`mise uninstall go@latest && mise install`) to trigger package installation.

**`mise/.config/mise/go-packages`** (new file, committed to dotfiles):
```
golang.org/x/tools/gopls@latest
github.com/go-delve/delve/cmd/dlv@latest
golang.org/x/tools/cmd/goimports@latest
mvdan.cc/gofumpt@latest
github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

When `mise install` runs (or Go version changes), mise automatically runs `go install` for each package in this file using the activated Go SDK. This guarantees tools are always compiled against the current Go version.

**`zsh/.zshenv` change:** Remove `GOBIN=$HOME/go/bin` from PATH — mise manages the Go bin path via `GOROOT`. The tools remain accessible because mise shims or `GOROOT/bin` is on PATH via mise activation.

> **Note — `dotnet_isolated = true` is required:** By default, mise's dotnet backend symlinks to whatever `dotnet` binary is on the system (e.g. the Arch `dotnet-sdk` package) rather than downloading its own SDK. This defeats per-project version pinning. Setting `dotnet_isolated = true` makes mise download and manage its own .NET SDKs independently of the system install.

### Per-project config

**`.mise.toml`** (committed to project repo — tool versions only):
```toml
[tools]
node = "20"
dotnet = "8.0"
```

**`.mise.local.toml`** (gitignored — personal env vars):
```toml
[env]
DATABASE_URL = "postgres://localhost/myapp"
ASPNETCORE_ENVIRONMENT = "Development"
```

This separation keeps the committed file safe for team use once the workflow is proven, while allowing personal env var management now.

mise respects existing `.nvmrc` and `.node-version` files automatically — existing projects don't need immediate migration.

### What mise does NOT manage

System CLI tools (`kubectl`, `docker`, `fzf`, `bat`, `ripgrep`, `oh-my-posh`, etc.) stay managed by `yay`/`pacman`. mise is for runtimes and SDKs only.

## Dotfiles Changes

### `zsh/.config/zsh/.zshrc`

| Action | Line |
|---|---|
| Remove | `source /usr/share/nvm/init-nvm.sh` |
| Remove | `source <(direnv hook zsh)` |
| Remove | `[ -s "/home/alex/.bun/_bun" ] && source "/home/alex/.bun/_bun"` |
| Add | `eval "$(mise activate zsh)"` |

### `zsh/.zshenv`

| Action | Change |
|---|---|
| Remove | `$HOME/.dotnet/tools` from PATH |
| Remove | `GOBIN=$HOME/go/bin` from PATH (mise manages Go bin path via `GOPATH`) |

### `git/.gitignore.global`

Add `.mise.local.toml` so it is excluded from all repos without per-repo config.

## Migration Sequence

1. Install mise (`yay -S mise`)
2. Create `mise/.config/mise/config.toml` with global tool versions + Go settings
3. Create `mise/.config/mise/go-packages` with Go tools list
4. `stow -t ~ mise` to symlink the config
5. Add `eval "$(mise activate zsh)"` to `.zshrc`, keep nvm/direnv lines for now
6. Run `mise install` to download all global tools (Go tools auto-installed via `go-packages`)
7. Validate each runtime: `node -v`, `go version`, `dotnet --version`, `dlv version`, etc.
8. Remove `source /usr/share/nvm/init-nvm.sh` from `.zshrc`
9. Remove `source <(direnv hook zsh)` and bun completions from `.zshrc`
10. Remove `$HOME/.dotnet/tools` and `$GOBIN` from PATH in `.zshenv`
11. Add `.mise.local.toml` to `~/.gitignore.global`
12. Migrate existing `.envrc` files to `.mise.local.toml` as projects are touched

## Out of Scope (for now)

- mise task runner (may revisit later)
- Team `.mise.toml` rollout (after personal workflow is proven)
- Migrating all existing `.envrc` files upfront (done gradually as projects are touched)
