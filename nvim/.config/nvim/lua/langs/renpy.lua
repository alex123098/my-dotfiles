return {
  {
    "inzoiniac/renpy-syntax.nvim",
    config = function()
      require("renpy-syntax").setup()
    end,
  },
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          renpy = { "renpy" },
        },
      },
    },
  },
}