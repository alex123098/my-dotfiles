local u = require "utils"

require "lsp-attach"

-- Highlight when yank
u.autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = u.augroup "hl-yank",
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Autoreload buffer contents on focus
u.autocmd({
  "FocusGained",
  "TermClose",
  "TermLeave",
}, {
  desc = "Autoreload buffer content",
  group = u.augroup "bufreload",
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd "checktime"
    end
  end,
})

-- autoresize windows on parent resize
u.autocmd("VimResized", {
  desc = "Resize windows on parent resize",
  group = u.augroup "resize_children",
  callback = function()
    local cur_tab = vim.fn.tabpagenr()
    vim.cmd "tabdo wincmd ="
    vim.cmd("tabnext " .. cur_tab)
  end,
})

-- close some buffers with q
u.autocmd("FileType", {
  desc = "Close utilitary windows with q",
  group = u.augroup "close_with_q",
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "notify",
    "qf",
    "query",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- do not list man pages in buflist
u.autocmd("FileType", {
  group = u.augroup "man_unlist",
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- set conceallevel to normal for json files
u.autocmd("FileType", {
  group = u.augroup "json_conceal",
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- create all intermediate dirs in path when saving a file
u.autocmd("BufWritePre", {
  group = u.augroup "auto_create_dir",
  callback = function(event)
    if event.match:match "^%w%w+:[\\/][\\/]" then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- set tab to 4 symbols for some file types
u.autocmd("FileType", {
  group = u.augroup "custom",
  pattern = { "go", "rust" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

-- enable treesitter highlighting for any buffer whose filetype has a parser
u.autocmd("FileType", {
  desc = "Start treesitter highlighting when a parser is available",
  group = u.augroup "treesitter_highlight",
  callback = function(event)
    local ok, parser = pcall(vim.treesitter.get_parser, event.buf)
    if ok and parser then
      vim.treesitter.start(event.buf)
    end
  end,
})
