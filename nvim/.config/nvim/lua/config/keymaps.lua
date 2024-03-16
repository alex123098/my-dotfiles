vim.keymap.set("n", "<A-h>", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Toggle horizontal terminal" })
vim.keymap.set("n", "<leader>?", function()
  require("telescope.builtin").live_grep {
    additional_args = { "--hidden" },
    file_ignore_patterns = { ".git" },
  }
end, { desc = "Grep (root dir, include hidden files)" })
