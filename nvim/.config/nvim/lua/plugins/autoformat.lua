local pack = require "fw.pack"
local k = require "fw.keys"

pack.add { "stevearc/conform.nvim" }

local conform = require "conform"

conform.setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local disable_ft = { c = true, cpp = true }
    return {
      timeout_ms = 500,
      lsp_fallback = not disable_ft[vim.bo[bufnr].filetype],
    }
  end,
}

k.nmap("<leader>bf", function()
  conform.format()
end)