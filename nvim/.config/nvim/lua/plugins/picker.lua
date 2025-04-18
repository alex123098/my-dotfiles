return {
  {
    "folke/snacks.nvim",
    dependencies = {
      "folke/trouble.nvim",
    },
    opts = {
      picker = {
        actions = {
          trouble_open = function(...)
            return require("trouble.sources.snacks").actions.trouble_open.action(...)
          end,
        },
        win = {
          input = {
            keys = {
              ["<C-t>"] = {
                "trouble_open",
                mode = { "n", "i" },
              },
            },
          },
        },
      },
    },
    keys = {
      {
        "<leader>/",
        function()
          require("snacks").picker.grep()
        end,
        desc = "Live grep",
      },
      {
        "<leader>ff",
        function()
          require("snacks").picker.files()
        end,
        desc = "Find files",
      },
      {
        "<leader>fh",
        function()
          require("snacks").picker.help()
        end,
        desc = "Find help tags",
      },
      {
        "<leader>fk",
        function()
          require("snacks").picker.keymaps()
        end,
        desc = "Keymaps",
      },
      {
        "<leader>fd",
        function()
          require("snacks").picker.diagnostics()
        end,
        desc = "Diagnostics",
      },
      {
        "<leader>fn",
        function()
          require("snacks").picker.notifications()
        end,
        desc = "Notifications",
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        {
          mode = { "n", "v" },
          { "<leader>f", group = "Find" },
        },
      },
    },
  },
}
