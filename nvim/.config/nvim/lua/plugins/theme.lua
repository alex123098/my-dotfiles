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
    "nvim-tree/nvim-web-devicons",
    dependencies = { "DaikyXendo/nvim-material-icon" },
    config = function()
      require("nvim-web-devicons").setup {
        override = require("nvim-material-icon").get_icons(),
      }
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
}
