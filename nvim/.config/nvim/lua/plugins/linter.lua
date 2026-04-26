local pack = require "fw.pack"
local cmd = require "fw.cmds"

pack.add { "mfussenegger/nvim-lint" }

cmd.autocmd({ "BufReadPre", "BufNewFile" }, {
  group = cmd.augroup "lint-attach",
  callback = function(args)
    cmd.autocmd({
      "BufReadPost",
      "BufWritePost",
      "InsertLeave",
    }, {
      buffer = args.buf,
      group = cmd.augroup "lint",
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
})