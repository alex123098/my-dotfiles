return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = { spelling = true },
    defaults = {
      mode = { "n", "v" },
      ["g"] = { name = "Goto" },
      ["]"] = { name = "Next" },
      ["["] = { name = "Previos" },
      ["<leader>c"] = { name = "Code" },
      ["<leader>b"] = { name = "Buffer" },
    },
  },
  config = function(_, opts)
    local wk = require "which-key"
    wk.setup(opts)
    wk.register(opts.defaults)
  end,
}
