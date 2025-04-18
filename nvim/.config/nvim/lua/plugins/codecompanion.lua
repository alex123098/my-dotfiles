return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "github/copilot.vim",
  },

  opts = {
    strategies = {
      chat = { adapter = "copilot" },
      inline = { adapter = "copilot" },
      agent = { adapter = "copilot" },
    },
  },
  keys = {
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "Open CodeCompanion actions", mode = { "n", "v" } },
    { "<leader>ac", "<cmd>CodeCompanionChat<cr>", desc = "Open CodeCompanion chat", mode = { "n", "v" } },
    { "ga", "<cmd>CodeCompanionAdd<cr>", desc = "Add selection to CodeCompanion" },
  },
  init = function()
    vim.cmd.cabbrev [[cc CodeCompanion]]
  end,
}