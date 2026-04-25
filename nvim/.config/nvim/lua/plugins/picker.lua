return {
  {
    "folke/snacks.nvim",
    dependencies = {
      "folke/trouble.nvim",
    },
    opts = {
      picker = {
        layout = "bottom_search",
        layouts = {
          bottom_search = {
            layout = {
              box = "vertical",
              backdrop = false,
              row = -1,
              width = 0,
              height = 0.4,
              border = "top",
              title = " {title} {live} {flags}",
              title_pos = "left",
              {
                box = "horizontal",
                { win = "list", border = "none" },
                { win = "preview", title = "{preview}", width = 0.6, border = "left" },
              },
              { win = "input", height = 1, border = "top" },
            },
          },
        },
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