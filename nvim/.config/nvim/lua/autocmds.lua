local function group(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Highlight when yank
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = group "hl-yank",
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Autoreload buffer contents on focus
vim.api.nvim_create_autocmd({
  "FocusGained",
  "TermClose",
  "TermLeave",
}, {
  desc = "Autoreload buffer content",
  group = group "bufreload",
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd "checktime"
    end
  end,
})

-- autoresize windows on parent resize
vim.api.nvim_create_autocmd("VimResized", {
  desc = "Resize windows on parent resize",
  group = group "resize_children",
  callback = function()
    local cur_tab = vim.fn.tabpagenr()
    vim.cmd "tabdo wincmd ="
    vim.cmd("tabnext " .. cur_tab)
  end,
})

-- close some buffers with q
vim.api.nvim_create_autocmd("FileType", {
  desc = "Close utilitary windows with q",
  group = group "close_with_q",
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
vim.api.nvim_create_autocmd("FileType", {
  group = group "man_unlist",
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- set conceallevel to normal for json files
vim.api.nvim_create_autocmd("FileType", {
  group = group "json_conceal",
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- create all intermediate dirs in path when saving a file
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group "auto_create_dir",
  callback = function(event)
    if event.match:match "^%w%w+:[\\/][\\/]" then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- set tab to 4 symbols for some file types
vim.api.nvim_create_autocmd("FileType", {
  group = group "custom",
  pattern = { "go", "rust" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})
