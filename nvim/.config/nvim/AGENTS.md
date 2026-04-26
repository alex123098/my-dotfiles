# AGENTS.md

Full agent context for this config lives in the dotfiles root:
[`~/.dotfiles/AGENTS.md`](../../../../../AGENTS.md) — see the **Neovim config** section.

## Key constraints

- Do not reintroduce Lazy.nvim, zpack.nvim, or any other plugin manager — `vim.pack` is the deliberate, permanent choice.
- Prefer extending `lua/fw/` over reaching for third-party abstractions.
- No unit/integration test runner exists. The headless smoke test is the canonical validation step: `nvim --headless "+quitall"`.
