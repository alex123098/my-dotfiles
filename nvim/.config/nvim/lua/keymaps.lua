vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- buffers manipulation
vim.keymap.set("n", "<S-h>", "<cmd>bp<cr>", { desc = "Previous Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bn<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bd<cr>", { desc = "Close current buffer" })
vim.keymap.set("n", "<leader>bs", function()
  vim.api.nvim_create_buf(true, true)
end, { desc = "Create scratch buffer" })

-- remap j and k to work as expected on wrapped lines
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- windows manipulation
vim.keymap.set("n", "<C-h>", ":wincmd h<cr>", { silent = true, desc = "Move to the window on the left" })
vim.keymap.set("n", "<C-j>", ":wincmd j<cr>", { silent = true, desc = "Move to the window on the bottom" })
vim.keymap.set("n", "<C-k>", ":wincmd k<cr>", { silent = true, desc = "Move to the window on the top" })
vim.keymap.set("n", "<C-l>", ":wincmd l<cr>", { silent = true, desc = "Move to the window on the right" })

vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

vim.keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Close window", remap = true })

vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split window to the right", remap = true })
vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split window to the bottom", remap = true })

-- clear search with <ESC>
vim.keymap.set({ "i", "n" }, "<Esc>", "<cmd>noh<cr><esc>", { desc = "Escape and Clear hlsearch" })

-- escape to normal mode from terminal by 2<Esc>
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Enter normal mode" })

-- Diagnostics & Quickfixes navigation
local function goto_diag(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go { severity = severity }
  end
end
vim.keymap.set("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix" })
vim.keymap.set("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })

vim.keymap.set("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })
vim.keymap.set("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })

vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
vim.keymap.set("n", "[d", goto_diag(false), { desc = "Previous Diagnostics" })
vim.keymap.set("n", "]d", goto_diag(true), { desc = "Next Diagnostics" })
vim.keymap.set("n", "[e", goto_diag(false, "ERROR"), { desc = "Previous Error" })
vim.keymap.set("n", "]e", goto_diag(true, "ERROR"), { desc = "Next Error" })
vim.keymap.set("n", "[w", goto_diag(false, "WARN"), { desc = "Previous Warning" })
vim.keymap.set("n", "]w", goto_diag(true, "WARN"), { desc = "Next Warning" })

vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Open Lazy menu" })

vim.keymap.set("v", "g/", "<esc>/\\%V", { silent = false, desc = "Search in selected" })
