return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {},
      linters = {},
    },
    config = function(_, opts)
      local lint = require "lint"
      for name, linter in pairs(opts.linters) do
        if type(linter) == "table" and type(lint.linters[name]) == "table" then
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft
      local augrp = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd(opts.events, {
        group = augrp,
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
