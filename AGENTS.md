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

**Entry point:** `init.lua` — sets leader=Space, loads `options`, `keymaps`, `autocmds`, `init-lazy`.

**Plugin manager:** `folke/lazy.nvim`. Plugin specs live in `lua/plugins/` and `lua/langs/`.  
- The **same plugin can appear in multiple spec files** — lazy.nvim merges `opts` tables. This is intentional.
- `netrw` is disabled; `snacks.explorer` is the only file browser.
- `snacks.nvim` is the central hub: picker (replaces Telescope), explorer, dashboard, notifications, image preview.

**Key plugin locations:**
| File | Responsibility |
|---|---|
| `lua/plugins/init.lua` | lazy.nvim bootstrap + snacks.nvim core |
| `lua/plugins/lspsetup.lua` | mason + nvim-lspconfig + fidget |
| `lua/plugins/completions.lua` | blink.cmp |
| `lua/plugins/autoformat.lua` | conform.nvim (format-on-save) |
| `lua/plugins/picker.lua` | snacks.picker (fuzzy finder) |
| `lua/langs/*.lua` | per-language LSP/DAP/test/formatter setup |

**Quirks:**
- `snacks.nvim` + `noice.nvim`: `init.lua` saves/restores `vim.notify` around `snacks.setup()` to prevent noice override — don't remove this guard.
- C/C++ format-on-save is **disabled** (`disable_ft = { c = true, cpp = true }` in `autoformat.lua`).
- Tab size is **4** for Go and Rust (autocmd), **2 spaces** everywhere else.
- `lsp_lines.nvim` is sourced from `https://git.sr.ht/~whynothugo/lsp_lines.nvim` (not GitHub).
- `vim-tmux-navigator` is installed in **both** nvim and tmux — the `C-h/j/k/l` bindings are intentionally duplicated.

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
