return {
  {
    "echasnovski/mini.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("mini.ai").setup { n_lines = 500 }
      require("mini.surround").setup()
      if not vim.g.neovide then
        local function create_opts()
          local mouse_scrolled = false
          for _, scroll in ipairs { "Up", "Down" } do
            local key = "<ScrollWheel" .. scroll .. ">"
            vim.keymap.set({ "", "i" }, key, function()
              mouse_scrolled = true
              return key
            end, { expr = true })
          end
          local animate = require "mini.animate"
          return {
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
          }
        end
        require("mini.animate").setup(create_opts())
      end
      require("mini.move").setup {
        mappings = {
          left = "<M-H>",
          right = "<M-L>",
          down = "<M-J>",
          up = "<M-K>",

          line_left = "<M-H>",
          line_right = "<M-L>",
          line_down = "<M-J>",
          line_up = "<M-K>",
        },
      }

      local statusline = require "mini.statusline"
      statusline.setup { use_icons = true }
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return "%21:%-2v"
      end
      require("mini.tabline").setup()
    end,
  },
}
