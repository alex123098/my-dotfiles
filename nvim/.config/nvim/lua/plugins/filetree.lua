return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "DaikyXendo/nvim-material-icon",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Open file explorer" } },
    },
    opts = {
      filesystem = {
        filtered_items = { visible = true },
        window = {
          mappings = {
            ["<leader>e"] = "close_window",
          },
        },
      },
    },
    init = function()
      if vim.fn.argc(-1) == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require "neo-tree"
          vim.defer_fn(function()
            return vim.cmd.colorscheme "tokyonight-night"
          end, 100)
        end
      end
    end,
  },
}
