local pack = require "fw.pack"

pack.add {
  { src = "saghen/blink.cmp", version = "v1.10.2" },
  "saghen/blink.compat",
  "rafamadriz/friendly-snippets",
}

require("blink.cmp").setup {
  appearance = {
    nerd_font_variant = "mono",
  },

  completion = {
    accept = {
      auto_brackets = { enabled = true },
    },
    menu = {
      draw = { treesitter = { "lsp" } },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
    ghost_text = { enabled = false },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  cmdline = { enabled = false },
  keymap = {
    preset = "default",
    ["<C-l>"] = { "snippet_forward", "fallback" },
    ["<C-h>"] = { "snippet_backward", "fallback" },
  },
}