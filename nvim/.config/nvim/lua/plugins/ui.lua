local u = require "utils"

return {
  {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    opts = function(_, opts)
      local mouse_scrolled = false
      for _, scroll in ipairs { "Up", "Down" } do
        local key = "<ScrollWheel" .. scroll .. ">"
        u.map({ "", "i" }, key, function()
          mouse_scrolled = true
          return key
        end, nil, { expr = true })
      end

      local animate = require "mini.animate"
      return vim.tbl_deep_extend("force", opts, {
        open = { enable = false },
        close = { enable = false },
        resize = {
          timing = animate.gen_timing.linear { duration = 100, unit = "total" },
        },
        scroll = {
          timing = animate.gen_timing.linear { duration = 150, unit = "total" },
          subscroll = animate.gen_subscroll.equal {
            predicate = function(total_scroll)
              if mouse_scrolled then
                mouse_scrolled = false
                return false
              end
              return total_scroll > 1
            end,
          },
        },
      })
    end,
  },

  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
    },
    -- init = function()
    --   package.preload["nvim-web-devicons"] = function()
    --     require("mini.icons").mock_nvim_web_devicons()
    --     return package.loaded["nvim-web-devicons"]
    --   end
    -- end,
  },

  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        floats = "transparent",
        sidebars = "transparent",
      },
    },
    init = function()
      vim.cmd.colorscheme "tokyonight-night"
      vim.cmd.hi "Comment gui=none"
    end,
  },

  {
    "echasnovski/mini.statusline",
    opts = { use_icons = true },
    config = function(_, opts)
      local statusline = require "mini.statusline"
      statusline.setup(opts)
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return "%21:%-2v"
      end
    end,
  },
  {
    "echasnovski/mini.tabline",
    opts = {},
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline",
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
      },
    },
    config = function(_, opts)
      -- skip messages from lazy installer
      if vim.o.filetype == "lazy" then
        vim.cmd [[messages clear]]
      end
      require("noice").setup(opts)
    end,
  },

  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        enabled = true,
      },
    },
  },
}
