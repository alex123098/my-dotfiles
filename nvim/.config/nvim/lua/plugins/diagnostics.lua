local pack = require "fw.pack"
local k = require "fw.keys"

pack.add { "folke/trouble.nvim" }

require("trouble").setup()

k.nmap("<leader>cs", "<cmd>Trouble symbols toggle<cr>", "Symbols outline")
k.nmap("<leader>xq", "<cmd>Trouble qflist toggle<cr>", "Quickfix list")
k.nmap("<leader>xl", "<cmd>Trouble loclist toggle<cr>", "Locations list")
k.nmap("<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Diagnostics messages")
k.nmap("<leader>ct", "<cmd>Trouble lsp toggle<cr>", "Symbols references and definitions")