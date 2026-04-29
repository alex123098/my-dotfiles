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
| Go | System install, `GOBIN` in PATH |
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
        └── config.toml    ← global tool versions
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
```

- `lts` / `latest` resolved and pinned at install time
- Activated automatically when no project-level `.mise.toml` is found

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
| Keep | `GOBIN=$HOME/go/bin` (still useful for `go install`-ed tools) |

### `git/.gitignore.global`

Add `.mise.local.toml` so it is excluded from all repos without per-repo config.

## Migration Sequence

1. Install mise (`yay -S mise`)
2. Create `mise/.config/mise/config.toml` with global tool versions
3. `stow -t ~ mise` to symlink the config
4. Add `eval "$(mise activate zsh)"` to `.zshrc`, keep nvm/direnv lines for now
5. Run `mise install` to download all global tools
6. Validate each runtime: `node -v`, `go version`, `dotnet --version`, etc.
7. Remove `source /usr/share/nvm/init-nvm.sh` from `.zshrc`
8. Remove `source <(direnv hook zsh)` and bun completions from `.zshrc`
9. Remove `$HOME/.dotnet/tools` from PATH in `.zshenv`
10. Add `.mise.local.toml` to `~/.gitignore.global`
11. Migrate existing `.envrc` files to `.mise.local.toml` as projects are touched

## Out of Scope (for now)

- mise task runner (may revisit later)
- Team `.mise.toml` rollout (after personal workflow is proven)
- Migrating all existing `.envrc` files upfront (done gradually as projects are touched)
