vim.pack.add { "https://github.com/zuqini/zpack.nvim" }

require("zpack").setup {
  spec = {
    { import = "plugins" },
    { import = "langs" },
  },
}
