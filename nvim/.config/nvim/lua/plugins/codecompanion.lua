local u = require "utils"
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

    -- remap copilot accept shortcut
    u.map("i", "<C-a>", "<Plug>(copilot-accept-word)", "Accept copilot suggestion", {
      expr = true,
      replace_keycodes = false,
    })
    u.map("i", "<C-s>", "<Plug>(copilot-dismiss)", "Dismiss copilot suggestion")
    vim.g.copilot_no_tab_map = true
  end,
}
