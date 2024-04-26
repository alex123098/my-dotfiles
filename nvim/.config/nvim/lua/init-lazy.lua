local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
  spec = {
    { import = "plugins" },
    { import = "langs" },
  },
  defaults = { version = false },
  install = { missing = true, colorscheme = { "tokyonight" } },
  checker = { enabled = true },
  performance = {
    cache = { enabled = true },
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchpattern",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "netrw",
        "netrwPlugin",
      },
    },
  },
}
