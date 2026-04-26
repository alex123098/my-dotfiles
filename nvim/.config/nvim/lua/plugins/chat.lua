local pack = require "fw.pack"
local k = require "fw.keys"

pack.add "nickjvandyke/opencode.nvim"

vim.o.autoread = true -- required for opencode.nvim buffer reload on edits

---@type opencode.Opts
vim.g.opencode_opts = {}

k.map({ "n", "v" }, "<leader>ac", function() require("opencode").toggle() end, "Toggle opencode")
k.imap("<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, "Ask opencode")
