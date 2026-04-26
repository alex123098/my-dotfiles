local pack = require "fw.pack"
local cmd = require "fw.cmds"
local k = require "fw.keys"

pack.add {
  src = "christoomey/vim-tmux-navigator",
  load = function(args)
    if args.spec.name ~= "vim-tmux-navigator" then
      return
    end

    cmd.stub({
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    }, function()
      vim.cmd.packadd "vim-tmux-navigator"
    end)
  end,
}

k.nmap("<C-h>", "<cmd>TmuxNavigateLeft<cr>", "Move to the window on the left", { noremap = true, silent = true })
k.nmap("<C-l>", "<cmd>TmuxNavigateRight<cr>", "Move to the window on the right", { noremap = true, silent = true })
k.nmap("<C-j>", "<cmd>TmuxNavigateDown<cr>", "Move to the window on the bottom", { noremap = true, silent = true })
k.nmap("<C-k>", "<cmd>TmuxNavigateUp<cr>", "Move to the window on the top", { noremap = true, silent = true })
