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

**Entry point:** `init.lua` — sets leader=Space, loads `options`, `keymaps`, `autocmds`, `init-zpack`.

**Plugin manager:** `zpack.nvim` (not lazy.nvim). Plugin specs live in `lua/plugins/` and `lua/langs/`.
- The **same plugin can appear in multiple spec files** — zpack merges specs at startup. This is intentional.
- `netrw` is disabled; `snacks.explorer` is the only file browser.
- `snacks.nvim` is the central hub: picker (replaces Telescope), explorer, dashboard, notifications, image preview.

**Key plugin locations:**
| File | Responsibility |
|---|---|
| `lua/plugins/init.lua` | zpack bootstrap + snacks.nvim core |
| `lua/plugins/lspsetup.lua` | mason + nvim-lspconfig + fidget |
| `lua/plugins/completions.lua` | blink.cmp |
| `lua/plugins/autoformat.lua` | conform.nvim (format-on-save) |
| `lua/plugins/picker.lua` | snacks.picker (fuzzy finder) |
| `lua/langs/*.lua` | per-language LSP/DAP/test/formatter setup |
| `lua/lsp-attach.lua` | all `LspAttach` autocmds (global + per-client); required from `autocmds.lua` |
| `lsp/*.lua` | per-server config via `vim.lsp.config()` — auto-detected by Neovim 0.11+ (running 0.12+) |

**zpack vs lazy.nvim — key behavioral differences:**
- **Default loading**: zpack loads plugins **eagerly** by default. lazy.nvim defaults to lazy loading. Plugins with no `event`/`cmd`/`ft`/`keys` trigger and no `lazy = true` will load at startup.
- **`config`/`init` merge strategy**: both are **OVERRIDE** in zpack — when the same plugin appears in multiple spec files, only the last spec's `config`/`init` runs. In lazy.nvim, multiple `init` functions all run. Consequence: never put `LspAttach` autocmds or other side-effectful logic inside a `{ "neovim/nvim-lspconfig", init = ... }` spec if any other spec file also defines `init` for that plugin. Use a standalone `require` (e.g. `lua/lsp-attach.lua`) instead.
- **`opts` merge strategy**: zpack uses `tbl_deep_extend("force")` for plain tables — **arrays overwrite by index**, not by appending. lazy.nvim `opts` functions receive the accumulated table from all specs. In zpack, use an `opts` function `(_, opts)` and call `vim.list_extend` to append to array fields.
- **`opts_extend`**: lazy.nvim has an explicit `opts_extend` mechanism for merging array fields across specs. zpack has no equivalent — always use `vim.list_extend` inside an `opts` function.
- **`keys` / `event` / `cmd` / `ft`**: these are `LIST_EXTEND` in zpack — safe to declare in multiple spec files for the same plugin.

**Quirks:**
- `snacks.nvim` + `noice.nvim`: `init.lua` saves/restores `vim.notify` around `snacks.setup()` to prevent noice override — don't remove this guard.
- C/C++ format-on-save is **disabled** (`disable_ft = { c = true, cpp = true }` in `autoformat.lua`).
- Tab size is **4** for Go and Rust (autocmd), **2 spaces** everywhere else.
- `lsp_lines.nvim` is sourced from `https://git.sr.ht/~whynothugo/lsp_lines.nvim` (not GitHub).
- `vim-tmux-navigator` is installed in **both** nvim and tmux — the `C-h/j/k/l` bindings are intentionally duplicated.
- `nvim-web-devicons` is **not installed**. `mini.icons` provides a compatibility shim via `mock_nvim_web_devicons()` registered in `package.preload` (see `lua/plugins/ui.lua`). Any plugin that `require("nvim-web-devicons")` will transparently get `mini.icons` instead — do not add `nvim-web-devicons` as a dependency.
- Winbar breadcrumbs are provided by `dropbar.nvim` (`Bekaboo/dropbar.nvim`). Peek/pick the winbar with `<leader>;`.

**Lua style (enforced by `.stylua.toml`):**
- 160-column width, 2-space indent, `AutoPreferDouble` quotes, `call_parentheses = "None"`.

**Mason auto-installs:**
- LSPs: `lua_ls`, `ts_ls`, `gopls`, `pyright`, `omnisharp`, `rust_analyzer`, `zls`
- Formatters/linters: `stylua`, `goimports`, `gofumpt`, `golangcilint`, `taplo`
- DAPs: `js-debug-adapter`, `delve`, `codelldb`, `netcoredbg`

## Shell (zsh)

- `ZDOTDIR=~/.config/zsh` — zsh config is fully XDG; `.zshenv` sets env vars, `.zshrc` sets behavior.
- `zoxide` is aliased to **`j`**, not `z` (`zoxide init --cmd j zsh`).
- `cat` is aliased to `bat --paging=never`.
- History is at `~/.local/share/zsh/history`.

## tmux

- Prefix: **`C-a`** (not `C-b`).
- Splits: `<prefix>\` (horizontal) / `<prefix>-` (vertical).
- Layouts in `tmux/.tmux/layouts/`; apply with `tla <name>`.
- `td <query>`: open/reattach a tmux session at the zoxide-resolved directory.

## OS / environment

- Arch Linux. Package manager aliases: `yay`, `pacman`, `eos-update`. Zsh plugins sourced from `/usr/share/zsh/plugins/`.
- Desktop stack: i3 + picom + dunst + rofi (AwesomeWM config also present but secondary).
- `$EDITOR`/`$VISUAL` = `nvim`; `$MANPAGER = "nvim +Man!"`.
- `git/.gitconfig` is intentionally **empty** — populated manually after stow.

## Formatting Lua in this repo

```bash
stylua lua/           # format all Lua under nvim config
stylua lua/plugins/autoformat.lua   # single file
```

Config is at `nvim/.config/nvim/.stylua.toml`.
