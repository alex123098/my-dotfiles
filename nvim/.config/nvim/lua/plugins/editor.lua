local u = require "utils"

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      plugins = { spelling = true },
      specs = {
        { "<leader>b", group = "buffer", mode = "n" },
      },
    },
  },

  -- breadcrumbs
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      create_autocmd = false,
    },
    config = function(_, opts)
      require("barbecue").setup(opts)

      u.autocmd({
        "WinScrolled",
        "BufWinEnter",
        "CursorHold",
        "InsertLeave",
      }, {
        group = u.augroup "barbecue_updater",
        callback = function()
          require("barbecue.ui").update()
        end,
      })
    end,
  },

  -- auto append matching closing brackets
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {
      modes = { insert = true, command = true, terminal = false },
      -- skip pairing for certain characters
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- disable pairs when inside of string literal
      skip_ts = { "string" },
      -- skip pairing when next symbol is matching pair and pairs are unbalanced
      skip_unbalanced = true,
      -- handle code regions inside of markdown
      markdown = true,
    },
  },

  -- editor enhancements
  {
    "echasnovski/mini.ai",
    opts = { n_lines = 500 },
  },
  {
    "echasnovski/mini.surround",
    opts = {
      mappings = {
        add = "sa",
        delete = "sd",
        find = "sf",
        find_left = "sF",
        highlight = "sh",
        replace = "sr",
        update_n_lines = "sn",

        suffix_last = "l",
        suffix_next = "n",
      },
    },
  },
  {
    "echasnovski/mini.move",
    opts = {},
  },

  -- TODO comments lookup
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "folke/snacks.nvim",
    },
    opts = {},
    keys = {
      {
        "<leader>ft",
        function()
          ---@diagnostic disable-next-line: undefined-field
          require("snacks").picker.todo_comments { keywords = { "todo", "fix", "fixme", "bug", "TODO", "FIX", "FIXME", "BUG" } }
        end,
        desc = "ToDos",
      },
    },
  },

  -- higlight colors
  {
    "norcalli/nvim-colorizer.lua",
    opts = {},
  },

  -- diagnostics
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {},
    keys = {
      { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols outline" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Locations list" },
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics messages" },
      { "<leader>ct", "<cmd>Trouble lsp toggle<cr>", desc = "Symbols references and definitions" },
    },
  },
}
