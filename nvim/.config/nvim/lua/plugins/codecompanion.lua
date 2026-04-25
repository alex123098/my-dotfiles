local u = require "utils"
return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim", branch = "master" },
    {
      "github/copilot.vim",
      cmd = { "Copilot" },
      init = function()
        vim.g.copilot_no_tab_map = true
        u.map("i", "<C-a>", "<Plug>(copilot-accept-word)", "Accept copilot suggestion", {
          expr = true,
          replace_keycodes = false,
        })
        u.map("i", "<C-s>", "<Plug>(copilot-dismiss)", "Dismiss copilot suggestion")
      end,
    },
  },
  build = "make tiktoken",
  keys = {
    { "<leader>am", "<cmd>CopilotChatModels<cr>", desc = "Open model selection", mode = "n" },
    { "<leader>ac", "<cmd>CopilotChatToggle<cr>", desc = "Toggle chat window", mode = { "n", "v" } },
  },
  opts = {
    temperature = 0.2,
    model = "claude-opus-4.6",
    window = {
      layout = "vertical",
      width = 0.5,
    },
    auto_insert_mode = true,
  },
}