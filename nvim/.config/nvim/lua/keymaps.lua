local u = require "utils"

u.nmap("<Esc>", "<cmd>nohlsearch<cr>")

-- buffers manipulation
u.nmap("<S-h>", "<cmd>bp<cr>", "Previous Buffer")
u.nmap("<S-l>", "<cmd>bn<cr>", "Next Buffer")
u.nmap("<leader>bd", "<cmd>bd<cr>", "Close current buffer")
u.nmap("<leader>bad", "<cmd>bufdo bd<cr>", "Close all buffers")
u.nmap("<leader>bod", "<cmd>%bd|e#<cr>", "Close all buffers, reopen current")

-- remap j and k to work as expected on wrapped lines
u.nmap("j", "gj")
u.nmap("k", "gk")

-- windows manipulation
u.nmap("<C-h>", ":wincmd h<cr>", "Move to the window on the left", { silent = true })
u.nmap("<C-j>", ":wincmd j<cr>", "Move to the window on the bottom", { silent = true })
u.nmap("<C-k>", ":wincmd k<cr>", "Move to the window on the top", { silent = true })
u.nmap("<C-l>", ":wincmd l<cr>", "Move to the window on the right", { silent = true })

u.nmap("<C-Up>", "<cmd>resize +2<cr>", "Increase window height")
u.nmap("<C-Down>", "<cmd>resize -2<cr>", "Decrease window height")
u.nmap("<C-Left>", "<cmd>vertical resize -2<cr>", "Decrease window width")
u.nmap("<C-Right>", "<cmd>vertical resize +2<cr>", "Increase window width")

u.nmap("<leader>wd", "<C-W>c", "Close window", { remap = true })

u.nmap("<leader>|", "<C-W>v", "Split window to the right", { remap = true })
u.nmap("<leader>-", "<C-W>s", "Split window to the bottom", { remap = true })

-- clear search with <ESC>
u.map({ "i", "n" }, "<Esc>", "<cmd>noh<cr><esc>", "Escape and Clear hlsearch")

-- escape to normal mode from terminal by 2<Esc>
u.map("t", "<Esc><Esc>", "<C-\\><C-n>", "Enter normal mode")

-- Diagnostics & Quickfixes navigation
local function goto_diag(next, severity)
  local cnt = next and 1 or -1
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    vim.diagnostic.jump { severity = severity, count = cnt, float = true }
  end
end
u.nmap("[q", vim.cmd.cprev, "Previous quickfix")
u.nmap("]q", vim.cmd.cnext, "Next quickfix")
u.nmap("[d", goto_diag(false), "Previous Diagnostics")
u.nmap("]d", goto_diag(true), "Next Diagnostics")
u.nmap("[e", goto_diag(false, "ERROR"), "Previous Error")
u.nmap("]e", goto_diag(true, "ERROR"), "Next Error")
u.nmap("[w", goto_diag(false, "WARN"), "Previous Warning")
u.nmap("]w", goto_diag(true, "WARN"), "Next Warning")

u.nmap("<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")

u.nmap("<leader>L", "<cmd>Lazy<cr>", "Open Lazy menu")

u.map("v", "g/", "<esc>/\\%V", "Search in selected", { silent = false })
