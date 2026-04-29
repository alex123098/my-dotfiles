# AGENTS.md

Agent context for the `~/.dotfiles` repository.

## Repo layout

Each top-level directory is a **GNU Stow package**. The internal path mirrors `$HOME` exactly (e.g. `nvim/.config/nvim/` → `~/.config/nvim/`). Never move files without preserving this structure.

```
awesome/    bat/    dunst/    git/    i3/    ideavim/
kitty/      neovide/  nvim/   omnisharp/  picom/  rofi/
spicetify/  tmux/   Xresources/  yazi/   zsh/
```

Git submodules: `awesome/freedesktop`, `awesome/lain`, `yazi/flavors/tokyo-night.yazi`. Tmux plugins under `tmux/.tmux/plugins/` are embedded repos but **not** in `.gitmodules`.

## Installing / applying changes

```bash
stow -nvt ~ <package>   # dry-run (always check first)
stow -t ~  <package>    # apply symlinks
```

`-t ~` is required because the repo is not cloned directly into `$HOME`.

## Neovim config (`nvim/.config/nvim/`)

**Entry point:** `init.lua` — loads `core` (options, keymaps, autocmds) and `plugins`.

**Plugin manager:** `vim.pack` (Neovim built-in, 0.12+). No third-party plugin manager. Do not reintroduce Lazy.nvim, zpack.nvim, or any other plugin manager.

**Internal framework (`lua/fw/`):** Use helpers instead of raw API calls:
- `fw.keys.{nmap,imap,vmap,map}` — wraps `vim.keymap.set`
- `fw.cmds.{autocmd,augroup,stub}` — autocmd helpers; `stub()` is the lazy-loading mechanism for user commands
- `fw.pack.add` — normalizes `"author/name"` shorthands to full GitHub URLs before calling `vim.pack.add`
- `fw.pack.languages()` — scans `lua/langs/*.lua` and returns all `LanguageSettings` descriptors

**Key plugin locations:**
| File | Responsibility |
|---|---|
| `lua/plugins/init.lua` | `vim.pack` plugin specs + snacks.nvim core |
| `lua/plugins/lspsetup.lua` | mason + nvim-lspconfig + fidget; scans langs, wires `LspAttach` mappings |
| `lua/plugins/completions.lua` | blink.cmp |
| `lua/plugins/autoformat.lua` | conform.nvim (format-on-save) |
| `lua/plugins/snacks.lua` | snacks.nvim config (picker, explorer, dashboard, etc.) |
| `lua/plugins/debug.lua` | DAP via nvim-dap, nvim-dap-ui, nvim-dap-virtual-text, mason-nvim-dap |
| `lua/plugins/testing.lua` | neotest + nvim-coverage |
| `lua/plugins/editor.lua` | dropbar, mini.pairs/ai/surround/move, todo-comments, colorizer, which-key |
| `lua/plugins/setuplangs.lua` | calls each lang's `setup` function at startup |
| `lua/plugins/ui.lua` | tokyonight colorscheme, mini.icons + `mock_nvim_web_devicons()`, mini.animate, noice.nvim, mini.tabline, custom statusline wiring |
| `lua/plugins/statusline.lua` | custom statusline module (no external plugin); uses mini.icons + gitsigns + tokyonight colors |
| `lua/plugins/git.lua` | gitsigns.nvim with hunk nav (`]c`/`[c`), blame (`<leader>gb`), diff (`<leader>gd`/`gD`) |
| `lua/plugins/diagnostics.lua` | trouble.nvim — `<leader>xx` diagnostics, `<leader>cs` symbols, `<leader>ct` LSP refs |
| `lua/plugins/linter.lua` | nvim-lint — runs `try_lint()` on BufReadPost/BufWritePost/InsertLeave |
| `lua/plugins/treesitter.lua` | nvim-treesitter (new imperative API: `install(grammars)`), treesitter-context |
| `lua/plugins/autosession.lua` | auto-session — auto-restores sessions; suppresses `~/` and `/` |
| `lua/plugins/chat.lua` | opencode.nvim — `<leader>ac` toggle, `<C-a>` in insert asks with `@this:` context |
| `lua/plugins/tmux.lua` | vim-tmux-navigator — `<C-h/j/k/l>` pane nav (duplicated in tmux config intentionally) |
| `lua/langs/*.lua` | per-language LSP/DAP/test/formatter setup |
| `lsp/*.lua` | per-server config via `vim.lsp.config()` — auto-detected by Neovim 0.12+ |

**Language support — `lua/langs/<lang>.lua` fields:**
- `lsps` — Mason tool names (LSP servers + formatters/linters)
- `packages` — extra `vim.pack` specs (plugins)
- `grammars` — Treesitter grammar names (informational only, not auto-wired)
- `setup` — imperative config called at startup (formatters, DAP adapter wiring, keymaps)
- `test_adapters` — neotest adapter specs consumed by `testing.lua`

Supported languages: `bash`, `clang` (C/C++), `csharp`, `docker`, `go`, `json`, `lua`, `markdown`, `python`, `renpy`, `rust`, `sql`, `typescript`, `yaml`, `zig`.

**DAP:** Adapters configured inline in each lang's `setup`. `mason-nvim-dap` handles auto-installation. Languages with DAP: `clang` (codelldb), `csharp` (netcoredbg), `typescript` (pwa-node), `go` (dap-go).

**`test_adapters` format** (consumed by `testing.lua`):
```lua
-- Format 1: numeric key, string value — require(name) and use as adapter directly
test_adapters = { "neotest-plenary" }

-- Format 2: string key → config table — require(name), then call setup/adapter/__call with config
test_adapters = { ["neotest-python"] = { dap = { justMyCode = false } } }
```

**DAP keymaps** (`lua/plugins/debug.lua`):
| Key | Action |
|---|---|
| `<F5>` | Continue / Start |
| `<C-F5>` | Start with args (prompts) |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<S-F10>` | Step out |
| `<C-F10>` | Run to cursor |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dt` | Terminate |
| `<leader>dr` | Toggle REPL |

**Test keymaps** (`lua/plugins/testing.lua`):
| Key | Action |
|---|---|
| `<leader>tt` | Run tests in current file |
| `<leader>tT` | Run all tests in cwd |
| `<leader>tr` | Run nearest test |
| `<leader>tl` | Repeat last run |
| `<leader>ts` | Toggle summary panel |
| `<leader>tS` | Stop test run |
| `<leader>to` | Toggle output panel |
| `<leader>tO` | Open output (enter + auto-close) |

**Commands:**
| Task | Command |
|---|---|
| Smoke test (startup errors) | `nvim --headless "+quitall"` |
| Format all Lua | `stylua init.lua lua lsp` |
| Formatting check | `stylua --check init.lua lua lsp` |
| Sync lockfile after plugin spec changes | `:lua vim.pack.update()` (inside Neovim) |

**Quirks:**
- C/C++ format-on-save is **disabled** (`disable_ft = { c = true, cpp = true }` in `autoformat.lua`).
- Tab size is **4** for Go and Rust (autocmd), **2 spaces** everywhere else.
- `vim-tmux-navigator` is installed in **both** nvim and tmux — the `C-h/j/k/l` bindings are intentionally duplicated.
- `nvim-web-devicons` is **not installed**. `mini.icons` provides a compatibility shim via `mock_nvim_web_devicons()` registered in `package.preload` (see `lua/plugins/ui.lua`).
- Winbar breadcrumbs: `dropbar.nvim` (`Bekaboo/dropbar.nvim`). Context nav: `[;` (go to start), `];` (select next context).
- **Mason uses a custom registry**: `github:Crashdummyy/mason-registry` in `lua/plugins/lspsetup.lua` to support `:MasonInstall roslyn` for C#.
- **AI chat is `opencode.nvim`** (`nickjvandyke/opencode.nvim`), toggled with `<leader>ac`. `<C-a>` in insert mode asks opencode with current context.
- **`<C-h/j/k/l>`** defined in `lua/core/keymaps.lua`, overridden to tmux-aware nav in `plugins/tmux.lua`. Keep both consistent.
- **`<leader>?`** opens a which-key popup of buffer-local keymaps.
- `.zsh`, `.sh`, `.zshenv`, `.zshrc` files are mapped to `sh` filetype in options.
- `fw.pack.add` `load` field: omit/false = deferred, `true` = eager, function = custom load trigger.
- `tokyonight` is configured with `transparent = true`; statusline bg is hardcoded to `#292e42`.

**Lua style (enforced by `.stylua.toml`):**
- 160-column width, 2-space indent, `AutoPreferDouble` quotes, `call_parentheses = "None"`.

**Mason auto-installs:**
- LSPs: `lua_ls`, `ts_ls`, `gopls`, `pyright`, `roslyn`, `rust_analyzer`, `zls`
- Formatters/linters: `stylua`, `goimports`, `gofumpt`, `golangcilint`, `taplo`
- DAPs: `js-debug-adapter`, `delve`, `codelldb`, `netcoredbg`

## Shell (zsh)

- `ZDOTDIR=~/.config/zsh` — zsh config is fully XDG; `.zshenv` sets env vars, `.zshrc` sets behavior.
- `zoxide` is aliased to **`j`**, not `z` (`zoxide init --cmd j zsh`).
- `cat` is aliased to `bat --paging=never`.
- History is at `~/.local/share/zsh/history`.
- Prompt: `oh-my-posh` with config at `~/.config/zsh/omp.conf.json`.
- `direnv` is hooked in `.zshrc`. `thefuck` is aliased via `eval $(thefuck --alias)`.
- `nvm` sourced from `/usr/share/nvm/init-nvm.sh`; `bun` completions from `~/.bun/_bun`.
- `LS_COLORS` generated by `vivid` using `~/.config/zsh/vivid-theme.yml`.
- `FZF_DEFAULT_OPTS` set in `.zshenv` with tokyonight colors.

**Useful shell functions:**
- `yy` — launch yazi and `cd` to the directory on exit.
- `frg` — fzf+ripgrep file search, opens result in `$EDITOR` at the matched line.
- `gdcol` / `gdscol` — `git diff` (unstaged / staged) piped through `bat --diff` with color.
- `td <query>` — open/reattach tmux session at zoxide-resolved directory.
- `tla [name]` — apply tmux layout from `~/.tmux/layouts/`; no arg lists available layouts.
- `dcbr <svc>` — `docker compose build <svc> && docker compose run <svc>`.
- `gpsup` — push and set upstream to `origin/<current-branch>`.

## tmux

- Prefix: **`C-a`** (not `C-b`).
- Splits: `<prefix>\` (horizontal) / `<prefix>-` (vertical).
- Status bar at **top**.
- Theme: `tokyo-night-tmux`. Plugins managed by TPM (`tmux/.tmux/plugins/tpm`).
- `td <query>` / `tla [name]` — see Shell functions above.

## OS / environment

- Arch Linux. Package manager aliases: `yay`, `pacman`, `eos-update`. Zsh plugins sourced from `/usr/share/zsh/plugins/`.
- Desktop stack: i3 + picom + dunst + rofi (AwesomeWM config also present but secondary).
- `$EDITOR`/`$VISUAL` = `nvim`; `$MANPAGER = "nvim +Man!"`.
- `git/.gitconfig` is intentionally **empty** — populated manually after stow.

## Formatting Lua in this repo

Run from `nvim/.config/nvim/`:

```bash
stylua init.lua lua lsp          # format all Lua
stylua --check init.lua lua lsp  # check only
stylua lua/plugins/autoformat.lua   # single file
```

Config is at `nvim/.config/nvim/.stylua.toml`.
