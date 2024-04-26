return {
  {
    "hedyhli/outline.nvim",
    keys = {
      { "<leader>cs", "<cmd>Outline<cr>", desc = "Symbols outline" },
    },
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    config = function(_, opts)
      require("outline").setup(opts)
    end,
  },
}
