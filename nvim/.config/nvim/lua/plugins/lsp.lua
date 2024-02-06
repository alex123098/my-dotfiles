return {
  "neovim/nvim-lspconfig",
  keys = {
    {
      "<leader>cL",
      function()
        vim.lsp.codelens.run()
      end,
      desc = "Run codelens action",
    },
  },
}
