return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable "make" == 1
        end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-tree/nvim-web-devicons", enabled = true },
      {
        "folke/which-key.nvim",
        opts = {
          defaults = {
            ["<leader>f"] = { name = "Find" },
          },
        },
      },
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-q>"] = false,
            ["<M-q>"] = false,
            ["<C-t>"] = function(buf)
              local actions = require "telescope.actions"
              actions.smart_send_to_qflist(buf)
              actions.open_qflist(buf)
            end,
          },
        },
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")

      local bi = require "telescope.builtin"
      vim.keymap.set("n", "<leader>/", bi.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>ff", bi.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fh", bi.help_tags, { desc = "Find help tag" })
      vim.keymap.set("n", "<leader>fk", bi.keymaps, { desc = "Keymaps" })
      vim.keymap.set("n", "<leader>fw", bi.grep_string, { desc = "Find current word" })
      vim.keymap.set("n", "<leader>fd", bi.diagnostics, { desc = "Open recent diagnostics" })
      vim.keymap.set("n", "<leader>f/", function()
        bi.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = "Search in current buffer" })
    end,
  },
}
