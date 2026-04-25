local function has_plugin(name)
  return require("zpack").get_plugin(name) ~= nil
end

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      image = { enabled = true },
    },
    keys = {
      {
        "<leader>bsn",
        function()
          require("snacks").scratch()
        end,
        desc = "Open scratch buffer",
      },
      {
        "<leader>bss",
        function()
          require("snacks").scratch.select()
        end,
        desc = "Select scratch buffer",
      },
    },
    config = function(_, opts)
      local old_notify = vim.notify
      require("snacks").setup(opts)

      if has_plugin "noice.nvim" then
        vim.notify = old_notify
      end
    end,
  },
}