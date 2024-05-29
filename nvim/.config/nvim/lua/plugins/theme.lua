local scheme_opts = {}
if not vim.g.neovide then
  scheme_opts = {
    transparent = true,
    styles = {
      floats = "transparent",
      sidebars = "transparent",
    },
  }
end
return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = scheme_opts,
    init = function()
      vim.cmd.colorscheme "tokyonight-night"
      vim.cmd.hi "Comment gui=none"
    end,
  },
  {
    "DaikyXendo/nvim-material-icon",
    opts = {
      color_icons = true,
      default = true,
    },
    config = function(_, opts)
      local devicons = require "nvim-web-devicons"
      devicons.setup(opts)

      -- Fix for plugins like barbecue that rely on the default icon
      devicons.get_default_icon = function()
        return {
          icon = "󰈙",
          color = "#6d8086",
          cterm_color = "66",
          name = "Default",
        }
      end
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
}
