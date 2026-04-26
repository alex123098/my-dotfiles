local k = require "fw.keys"

k.map({ "n", "i" }, "<Esc>", "<cmd>nohlsearch<cr>")

-- buffers manipulation
k.nmap("<S-h>", "<cmd>bp<cr>", "Previous Buffer")
k.nmap("<S-l>", "<cmd>bn<cr>", "Next Buffer")

-- remap j and k to work as expected on wrapped lines
k.map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", "Down", { expr = true, silent = true })
k.map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", "Up", { expr = true, silent = true })

-- windows manipulation
k.nmap("<C-h>", ":wincmd h<cr>", "Move to the window on the left", { silent = true })
k.nmap("<C-j>", ":wincmd j<cr>", "Move to the window on the bottom", { silent = true })
k.nmap("<C-k>", ":wincmd k<cr>", "Move to the window on the top", { silent = true })
k.nmap("<C-l>", ":wincmd l<cr>", "Move to the window on the right", { silent = true })

k.nmap("<C-Up>", "<cmd>resize +2<cr>", "Increase window height")
k.nmap("<C-Down>", "<cmd>resize -2<cr>", "Decrease window height")
k.nmap("<C-Left>", "<cmd>vertical resize -2<cr>", "Decrease window width")
k.nmap("<C-Right>", "<cmd>vertical resize +2<cr>", "Increase window width")

k.nmap("<leader>wd", "<C-W>c", "Close window", { remap = true })

k.nmap("<leader>|", "<C-W>v", "Split window to the right", { remap = true })
k.nmap("<leader>-", "<C-W>s", "Split window to the bottom", { remap = true })

-- clear search with <ESC>
k.map({ "i", "n" }, "<Esc>", "<cmd>noh<cr><esc>", "Escape and Clear hlsearch")

-- escape to normal mode from terminal by 2<Esc>
k.map("t", "<Esc><Esc>", "<C-\\><C-n>", "Enter normal mode")

-- Diagnostics & Quickfixes navigation
local function goto_diag(next, severity)
  local cnt = next and 1 or -1
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    vim.diagnostic.jump { severity = severity, count = cnt, float = true }
  end
end
k.nmap("[q", vim.cmd.cprev, "Previous quickfix")
k.nmap("]q", vim.cmd.cnext, "Next quickfix")
k.nmap("[d", goto_diag(false), "Previous Diagnostics")
k.nmap("]d", goto_diag(true), "Next Diagnostics")
k.nmap("[e", goto_diag(false, "ERROR"), "Previous Error")
k.nmap("]e", goto_diag(true, "ERROR"), "Next Error")
k.nmap("[w", goto_diag(false, "WARN"), "Previous Warning")
k.nmap("]w", goto_diag(true, "WARN"), "Next Warning")

k.nmap("<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")

k.vmap("g/", "<esc>/\\%V", "Search in selected", { silent = false })

-- saner behavior of n and N
k.nmap("n", "'Nn'[v:searchforward].'zv'", "Next search result", { expr = true })
k.map({ "x", "o" }, "n", "'Nn'[v:searchforward]", "Next search result", { expr = true })
k.nmap("N", "'nN'[v:searchforward].'zv'", "Previous search result", { expr = true })
k.map({ "x", "o" }, "N", "'nN'[v:searchforward]", "Previous search result", { expr = true })

-- undo break points to prevent undoing of entire input session
k.imap(",", ",<C-g>u")
k.imap(".", ".<C-g>u")
k.imap(";", ";<C-g>u")

-- move text around
k.nmap("<M-j>", "<cmd>execute 'move .+' . v:count1<cr>==", "Move down")
k.nmap("<M-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", "Move up")
k.imap("<M-j>", "<esc><cmd>m .+1<cr>==gi", "Move down")
k.imap("<M-k>", "<esc><cmd>m .-2<cr>==gi", "Move up")
k.vmap("<M-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", "Move down")
k.vmap("<M-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", "Move up")
k.nmap("<M-l>", ">>", "Indent right")
k.nmap("<M-h>", "<<", "Indent left")
k.vmap("<M-l>", ">gv", "Indent right")
k.vmap("<M-h>", "<gv", "Indent left")
k.imap("<M-l>", "<C-t>", "Indent right")
k.imap("<M-h>", "<C-d>", "Indent left")

-- paste without disrupting the yanked text
k.vmap("p", '"_dP', nil, { noremap = true })