return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = { spelling = true },
    defaults = {
      {
        mode = { "n", "v" },
        { "g", group = "Goto" },
        { "]", group = "Next" },
        { "[", group = "Previos" },
        { "<leader>c", group = "Code" },
        { "<leader>b", group = "Buffer" },
        { "<leader>d", group = "Debug" },
        { "<leader>f", group = "Find" },
        { "<leader>t", group = "Tests" },
        { "<leader>g", group = "Git" },
      },
    },
  },
  config = function(_, opts)
    local wk = require "which-key"
    wk.setup(opts)
    wk.add(opts.defaults)
  end,
}
