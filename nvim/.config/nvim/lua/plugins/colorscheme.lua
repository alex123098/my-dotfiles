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
  {
    "nvim-neo-tree/neo-tree.nvim",
    init = function()
      if vim.fn.argc(-1) == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        local plugin = require("lazy.core.config").spec.plugins["LazyVim"]
        local o = require("lazy.core.plugin").values(plugin, "opts", false)
        if stat and stat.type == "directory" then
          require("neo-tree")
          vim.defer_fn(function()
            return o.colorscheme and vim.cmd.colorscheme(o.colorscheme) or vim.cmd.colorscheme("tokyonight-night")
          end, 100)
        end
      end
    end,
  },
}
