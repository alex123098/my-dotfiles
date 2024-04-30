vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.showmode = false

vim.opt.mouse = "a"

vim.opt.clipboard = "unnamedplus"

vim.opt.breakindent = true

vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"

vim.opt.updatetime = 250

vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.opt.inccommand = "split"

vim.opt.cursorline = true

vim.opt.scrolloff = 8

vim.opt.hlsearch = true
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.o.wrap = false

vim.filetype.add {
  extension = {
    zsh = "sh",
    sh = "sh",
  },
  filename = {
    [".zshenv"] = "sh",
    [".zshrc"] = "sh",
  },
}
