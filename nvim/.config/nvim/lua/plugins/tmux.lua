return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { noremap = true, silent = true, desc = "Move to the window on the left" } },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", { noremap = true, silent = true, desc = "Move to the window on the right" } },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", { noremap = true, silent = true, desc = "Move to the window on the bottom" } },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", { noremap = true, silent = true, desc = "Move to the window on the top" } },
  },
}
