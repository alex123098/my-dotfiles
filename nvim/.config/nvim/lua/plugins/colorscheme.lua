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
    lazy = false,
    opts = scheme_opts,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
