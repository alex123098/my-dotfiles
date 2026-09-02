local pack = require "fw.pack"
local k = require "fw.keys"

pack.add { "stevearc/conform.nvim" }

local conform = require "conform"

local enabled = true

k.nmap("<leader>bnf", function()
  enabled = not enabled
  if enabled then
    vim.notify "Autoformat on save: enabled"
  else
    vim.notify "Autoformat on save: disabled"
  end
end)

conform.setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local disable_ft = { c = true, cpp = true }
    return enabled and {
      timeout_ms = 500,
      lsp_fallback = not disable_ft[vim.bo[bufnr].filetype],
    } or nil
  end,
}