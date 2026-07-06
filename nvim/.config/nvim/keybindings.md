# Neovim Keybindings Reference

> Auto-generated from `nvim/.config/nvim` configuration files.

---

## Table of Contents

- [General Navigation](#general-navigation)
- [Buffers](#buffers)
- [Windows & Splits](#windows--splits)
- [Search & Motion](#search--motion)
- [Diagnostics & Quickfix](#diagnostics--quickfix)
- [Text Manipulation](#text-manipulation)
- [LSP Features](#lsp-features)
- [Pickers & Explorer (Snacks)](#pickers--explorer-snacks)
- [Git (Gitsigns)](#git-gitsigns)
- [Debugging (DAP)](#debugging-dap)
- [Testing (Neotest)](#testing-neotest)
- [Trouble (Diagnostics UI)](#trouble-diagnostics-ui)
- [Editor Enhancements](#editor-enhancements)
- [Completions (Blink)](#completions-blink)
- [AI Chat (Pi)](#ai-chat-pi)
- [Formatting](#formatting)
- [Language-Specific](#language-specific)
  - [Go](#go)
  - [Rust](#rust)
- [Special Buffers](#special-buffers)
- [Autocmd Behaviors](#autocmd-behaviors)

---

## General Navigation

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `<Esc>` | `n`, `i` | Clear search highlight (`:nohlsearch`) | `core/keymaps.lua:3` |
| `<Esc>` | `i`, `n` | Escape and also clear hlsearch (`:noh`) | `core/keymaps.lua:30` |
| `<Esc><Esc>` | `t` | Exit terminal mode to normal mode | `core/keymaps.lua:33` |
| `j` | `n`, `x` | Cursor down (respects wrapped lines) | `core/keymaps.lua:10` |
| `k` | `n`, `x` | Cursor up (respects wrapped lines) | `core/keymaps.lua:11` |
| `n` | `n` | Next search result (smart direction + `zv`) | `core/keymaps.lua:57` |
| `n` | `x`, `o` | Next search result (smart direction) | `core/keymaps.lua:58` |
| `N` | `n` | Previous search result (smart direction + `zv`) | `core/keymaps.lua:59` |
| `N` | `x`, `o` | Previous search result (smart direction) | `core/keymaps.lua:60` |

**Notes:**
- `j`/`k` use `expr` to map to `gj`/`gk` on wrapped lines when no count is given.
- `n`/`N` invert direction smartly based on `v:searchforward` and center with `zv`.

---

## Buffers

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `<S-h>` | `n` | Previous buffer (`:bprevious`) | `core/keymaps.lua:6` |
| `<S-l>` | `n` | Next buffer (`:bnext`) | `core/keymaps.lua:7` |
| `<leader>bd` | `n` | Close current buffer (`snacks.bufdelete()`) | `plugins/snacks.lua:75` |
| `<leader>bad` | `n` | Close all buffers | `plugins/snacks.lua:78` |
| `<leader>bod` | `n` | Close all buffers except current | `plugins/snacks.lua:81` |
| `<leader>bsn` | `n` | Open new scratch buffer | `plugins/snacks.lua:48` |
| `<leader>bss` | `n` | Select from existing scratch buffers | `plugins/snacks.lua:51` |

---

## Windows & Splits

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `<C-h>` | `n` | Move to window on the left | `core/keymaps.lua:14` |
| `<C-j>` | `n` | Move to window on the bottom | `core/keymaps.lua:15` |
| `<C-k>` | `n` | Move to window on the top | `core/keymaps.lua:16` |
| `<C-l>` | `n` | Move to window on the right | `core/keymaps.lua:17` |
| `<C-Up>` | `n` | Increase window height (+2) | `core/keymaps.lua:19` |
| `<C-Down>` | `n` | Decrease window height (-2) | `core/keymaps.lua:20` |
| `<C-Left>` | `n` | Decrease window width (-2) | `core/keymaps.lua:21` |
| `<C-Right>` | `n` | Increase window width (+2) | `core/keymaps.lua:22` |
| `<leader>wd` | `n` | Close window (`<C-W>c`) | `core/keymaps.lua:24` |
| <code>&lt;leader&gt;\|</code> | `n` | Split window to the right (`<C-W>v`) | `core/keymaps.lua:26` |
| `<leader>-` | `n` | Split window to the bottom (`<C-W>s`) | `core/keymaps.lua:27` |

**Note:** `<C-h/j/k/l>` are **overridden** by tmux-aware navigation in `plugins/tmux.lua`:

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `<C-h>` | `n` | `:TmuxNavigateLeft` | `plugins/tmux.lua:23` |
| `<C-l>` | `n` | `:TmuxNavigateRight` | `plugins/tmux.lua:24` |
| `<C-j>` | `n` | `:TmuxNavigateDown` | `plugins/tmux.lua:25` |
| `<C-k>` | `n` | `:TmuxNavigateUp` | `plugins/tmux.lua:26` |

---

## Search & Motion

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `g/` | `v` | Search within visual selection | `core/keymaps.lua:54` |
| `[;` | `n` | Go to start of current context (dropbar) | `plugins/editor.lua:49` |
| `];` | `n` | Go to next context (dropbar) | `plugins/editor.lua:50` |

---

## Diagnostics & Quickfix

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `[d` | `n` | Previous diagnostic | `core/keymaps.lua:45` |
| `]d` | `n` | Next diagnostic | `core/keymaps.lua:46` |
| `[e` | `n` | Previous error | `core/keymaps.lua:47` |
| `]e` | `n` | Next error | `core/keymaps.lua:48` |
| `[w` | `n` | Previous warning | `core/keymaps.lua:49` |
| `]w` | `n` | Next warning | `core/keymaps.lua:50` |
| `<leader>cd` | `n` | Show line diagnostics (float) | `core/keymaps.lua:52` |
| `[q` | `n` | Previous quickfix item | `core/keymaps.lua:43` |
| `]q` | `n` | Next quickfix item | `core/keymaps.lua:44` |

---

## Text Manipulation

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `<M-j>` | `n` | Move line down | `core/keymaps.lua:68` |
| `<M-k>` | `n` | Move line up | `core/keymaps.lua:69` |
| `<M-j>` | `i` | Move current line down | `core/keymaps.lua:70` |
| `<M-k>` | `i` | Move current line up | `core/keymaps.lua:71` |
| `<M-j>` | `v` | Move selected lines down | `core/keymaps.lua:72` |
| `<M-k>` | `v` | Move selected lines up | `core/keymaps.lua:73` |
| `<M-l>` | `n` | Indent right (`>>`) | `core/keymaps.lua:74` |
| `<M-h>` | `n` | Indent left (`<<`) | `core/keymaps.lua:75` |
| `<M-l>` | `v` | Indent right (`>gv`) | `core/keymaps.lua:76` |
| `<M-h>` | `v` | Indent left (`<gv`) | `core/keymaps.lua:77` |
| `<M-l>` | `i` | Indent right (`<C-t>`) | `core/keymaps.lua:78` |
| `<M-h>` | `i` | Indent left (`<C-d>`) | `core/keymaps.lua:79` |
| `p` | `v` | Paste without clobbering yank register | `core/keymaps.lua:82` |
| `,` | `i` | Undo break point on `,` | `core/keymaps.lua:63` |
| `.` | `i` | Undo break point on `.` | `core/keymaps.lua:64` |
| `;` | `i` | Undo break point on `;` | `core/keymaps.lua:65` |

### Surround (Mini)

Provided by `mini.surround` (in `plugins/editor.lua`):

| Key | Mode | Action |
|-----|------|--------|
| `sa` | `n` | Add surround |
| `sd` | `n` | Delete surround |
| `sf` | `n` | Find surround (to the right) |
| `sF` | `n` | Find surround (to the left) |
| `sh` | `n` | Highlight surround |
| `sr` | `n` | Replace surround |
| `sn` | `n` | Update `n_lines` |

---

## LSP Features

All buffer-local, attached on `LspAttach`:

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `gd` | `n` | Go to definition | `plugins/lspsetup.lua:77` |
| `gD` | `n` | Go to declaration | `plugins/lspsetup.lua:87` |
| `gr` | `n` | Go to references | `plugins/lspsetup.lua:78` |
| `gI` | `n` | Go to implementation | `plugins/lspsetup.lua:79` |
| `K` | `n` | Hover documentation | `plugins/lspsetup.lua:86` |
| `<leader>cD` | `n` | Go to type definition | `plugins/lspsetup.lua:80` |
| `<leader>cr` | `n` | Rename symbol | `plugins/lspsetup.lua:83` |
| `<leader>ca` | `n` | Code action (actions-preview) | `plugins/lspsetup.lua:84` |
| `<leader>cL` | `n` | CodeLens action | `plugins/lspsetup.lua:85` |
| `<leader>fs` | `n` | Find symbols in current document | `plugins/lspsetup.lua:81` |
| `<leader>fS` | `n` | Find symbols in workspace | `plugins/lspsetup.lua:82` |
| `<leader>cl` | `n` | Toggle between virtual text / virtual lines diagnostics | `plugins/lspsetup.lua:88` |
| `<leader>th` | `n` | Toggle inlay hints | `plugins/lspsetup.lua:105` |

---

## Pickers & Explorer (Snacks)

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `<leader>ff` | `n` | Find files | `plugins/snacks.lua:57` |
| `<leader>/` | `n` | Live grep | `plugins/snacks.lua:54` |
| `<leader>fh` | `n` | Search help tags | `plugins/snacks.lua:60` |
| `<leader>fk` | `n` | Search keymaps | `plugins/snacks.lua:63` |
| `<leader>fd` | `n` | Search diagnostics | `plugins/snacks.lua:66` |
| `<leader>fn` | `n` | View notifications history | `plugins/snacks.lua:69` |
| `<leader>e` | `n` | Open file explorer | `plugins/snacks.lua:72` |
| `<leader>gg` | `n` | Open lazygit | `plugins/snacks.lua:84` |
| `<C-t>` | `n`, `i` | Trouble-open from picker input | `plugins/snacks.lua:41` |

---

## Git (Gitsigns)

All buffer-local, attached by `gitsigns.on_attach`:

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `]c` | `n` | Next git change (hunk) | `plugins/git.lua:20` |
| `[c` | `n` | Previous git change (hunk) | `plugins/git.lua:28` |
| `<leader>gb` | `n` | Git blame current line | `plugins/git.lua:31` |
| `<leader>gB` | `n` | Git blame whole file | `plugins/git.lua:32` |
| `<leader>gd` | `n` | Git diff against index (staged) | `plugins/git.lua:33` |
| `<leader>gD` | `n` | Git diff against last commit (`@`) | `plugins/git.lua:34` |

**Note:** `]c`/`[c` fall back to native diff navigation (`]c`/`[c`) when diff mode is active.

---

## Debugging (DAP)

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `<F5>` | `n` | Start / Continue debugging | `plugins/debug.lua:47` |
| `<C-F5>` | `n` | Start with arguments (prompts for args) | `plugins/debug.lua:49` |
| `<F10>` | `n` | Step over | `plugins/debug.lua:55` |
| `<F11>` | `n` | Step into | `plugins/debug.lua:52` |
| `<S-F10>` | `n` | Step out | `plugins/debug.lua:61` |
| `<C-F10>` | `n` | Run to cursor | `plugins/debug.lua:58` |
| `<leader>db` | `n` | Toggle breakpoint | `plugins/debug.lua:64` |
| `<leader>dB` | `n` | Set conditional breakpoint (prompts for condition) | `plugins/debug.lua:67` |
| `<leader>dt` | `n` | Terminate debugging session | `plugins/debug.lua:71` |
| `<leader>dr` | `n` | Toggle REPL | `plugins/debug.lua:73` |

DAP UI automatically opens on debug start and closes on termination.

---

## Testing (Neotest)

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `<leader>tt` | `n` | Run tests in current file | `plugins/testing.lua:59` |
| `<leader>tT` | `n` | Run all tests in current working directory | `plugins/testing.lua:62` |
| `<leader>tr` | `n` | Run nearest test (under cursor) | `plugins/testing.lua:65` |
| `<leader>tl` | `n` | Repeat last test run | `plugins/testing.lua:68` |
| `<leader>ts` | `n` | Toggle test summary panel | `plugins/testing.lua:71` |
| `<leader>tS` | `n` | Stop current test run | `plugins/testing.lua:74` |
| `<leader>to` | `n` | Toggle test output panel | `plugins/testing.lua:77` |
| `<leader>tO` | `n` | Open test output (enter mode, auto-close) | `plugins/testing.lua:80` |

---

## Trouble (Diagnostics UI)

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `<leader>xx` | `n` | Toggle diagnostics list | `plugins/diagnostics.lua:12` |
| `<leader>xq` | `n` | Toggle quickfix list | `plugins/diagnostics.lua:10` |
| `<leader>xl` | `n` | Toggle location list | `plugins/diagnostics.lua:11` |
| `<leader>cs` | `n` | Toggle document symbols outline | `plugins/diagnostics.lua:9` |
| `<leader>ct` | `n` | Toggle LSP references and definitions | `plugins/diagnostics.lua:13` |

---

## Editor Enhancements

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `<leader>ft` | `n` | Search TODOs / FIXMEs / BUGs | `plugins/editor.lua:90` |
| `<leader>?` | `n` | Show buffer-local keymaps (which-key) | `plugins/editor.lua:96` |

---

## Completions (Blink)

Blink internal keymap overrides (not `vim.keymap.set`):

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `<C-l>` | `i`, `c` | Snippet forward / fallback | `plugins/completions.lua:36` |
| `<C-h>` | `i`, `c` | Snippet backward / fallback | `plugins/completions.lua:37` |

Blink uses the `"default"` preset for all other completion keymaps (Tab, Enter, etc.).

---

## AI Chat (Pi)

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `<leader>ac` | `n` | Toggle Pi panel | `plugins/chat.lua:27` |
| `<leader>ac` | `v` | Ask Pi about selection (`@this:` context) | `plugins/chat.lua:31` |
| `<M-a>` | `i` | Ask Pi with `@this:` context (auto-submit) | `plugins/chat.lua:35` |
| `<leader>ax` | `n` | Pi action picker (explain, review, fix, etc.) | `plugins/chat.lua:20` |
| `<leader>ap` | `n` | Send code context ref to Pi's editor | `plugins/chat.lua:21` |
| `<leader>aq` | `n` | Abort Pi's current operation | `plugins/chat.lua:22` |

---

## Formatting

| Key | Mode | Action | Source |
|-----|------|--------|--------|
| `<leader>bf` | `n` | Format current buffer | `plugins/autoformat.lua:17` |

Format-on-save is also enabled (via conform.nvim) for all filetypes except C and C++.

---

## Language-Specific

### Go

| Key | Mode | Action | Scope | Source |
|-----|------|--------|-------|--------|
| `<leader>td` | `n` | Debug nearest test | `go` filetype | `langs/go.lua:46` |

### Rust

| Key | Mode | Action | Scope | Source |
|-----|------|--------|-------|--------|
| `<leader>cp` | `n` | Show crate details popup | `Cargo.toml` | `langs/rust.lua:43` |
| `<leader>cl` | `n` | Show crate dependencies popup | `Cargo.toml` | `langs/rust.lua:46` |
| `<leader>cf` | `n` | Show crate features popup | `Cargo.toml` | `langs/rust.lua:49` |
| `<leader>co` | `n` | Open crate repository | `Cargo.toml` | `langs/rust.lua:52` |
| `<leader>cR` | `n` | Rust code action | Rust buffers | `langs/rust.lua:61` |
| `<leader>dr` | `n` | Rust debuggables | Rust buffers | `langs/rust.lua:64` |

---

## Special Buffers

| Key | Mode | Action | Scope | Source |
|-----|------|--------|-------|--------|
| `q` | `n` | Close window (`:close`) | Utility buffers only | `core/autocmds.lua:57` |

Buffers where `q` closes: `PlenaryTestPopup`, `help`, `lspinfo`, `notify`, `qf`, `query`, `tsplayground`, `neotest-output`, `checkhealth`, `neotest-summary`, `neotest-output-panel`.

---

## Autocmd Behaviors

These aren't keybindings but affect editing behavior:

| Event | Effect |
|-------|--------|
| `TextYankPost` | Highlight yanked text |
| `FocusGained`, `TermClose`, `TermLeave` | Auto-reload buffer from disk (`:checktime`) |
| `VimResized` | Auto-resize window layout (`:wincmd =`) |
| `InsertEnter` | Disable relative line numbers |
| `InsertLeave` | Enable relative line numbers |
| `BufWritePre` | Auto-create intermediate directories in file path |
| `CursorHold`, `CursorHoldI` | Highlight all references to word under cursor (LSP) |
| `CursorMoved`, `CursorMovedI` | Clear LSP highlights |
| `FileType go, rust` | Set `tabstop=4`, `shiftwidth=4` |
| `FileType json, jsonc, json5` | Set `conceallevel=0` |

---

## Legend

| Notation | Meaning |
|----------|---------|
| `<C-...>` | Ctrl key |
| `<M-...>` | Alt (Meta) key |
| `<S-...>` | Shift key |
| `<leader>` | Space (default) |
| `n` | Normal mode |
| `i` | Insert mode |
| `v` | Visual mode |
| `x` | Visual + Select mode |
| `t` | Terminal mode |
| `c` | Command mode |
| `o` | Operator-pending mode |

---

*Generated from `lua/core/keymaps.lua`, `lua/core/autocmds.lua`, `lua/plugins/*.lua`, `lua/langs/*.lua`*
