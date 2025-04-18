return {
  "folke/snacks.nvim",
  opts = { explorer = {} },
  keys = {
    { "<leader>e", function() require("snacks").explorer() end, "Open file explorer" },
  },
}
