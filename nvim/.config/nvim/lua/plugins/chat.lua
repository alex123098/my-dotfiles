local pack = require "fw.pack"
local k = require "fw.keys"

pack.add "kurochenko/pi.nvim"

vim.o.autoread = true -- auto-reload buffers when pi edits files on disk

require("pi").setup({
  terminal = {
    position = "right",
    size = 0.4,
    continue_session = true, -- resume previous pi session
  },
  keymaps = {
    toggle = false, -- we define explicit keymaps below
    ask = false,
    select = "<leader>ax", -- action picker (explain, review, fix, etc.)
    prompt_this = "<leader>ap", -- send code context ref to pi's editor
    abort = "<leader>aq", -- abort pi's current operation
  },
})

-- <leader>ac normal mode: toggle the pi panel (like opencode's toggle)
k.map("n", "<leader>ac", function()
  require("pi").toggle()
end, "Toggle pi panel")

-- <leader>ac visual mode: ask about selection with @this context
k.map("v", "<leader>ac", function()
  require("pi").ask("@this: ")
end, "Ask pi about selection")

-- <M-a> insert mode: ask with @this context and submit immediately
-- (not <C-a> because tmux uses <C-a> as its prefix)
k.imap("<M-a>", function()
  require("pi").ask("@this: ", { submit = true })
end, "Ask pi")
