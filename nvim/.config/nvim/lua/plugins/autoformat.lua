return {
  "stevearc/conform.nvim",
  lazy = false,
  keys = {
    { "<leader>bf", function() end, mode = "", desc = "Format buffer" },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      local disable_ft = { c = true, cpp = true }
      return {
        timeout_ms = 500,
        lsp_fallback = not disable_ft[vim.bo[bufnr].filetype],
      }
    end,
    formatters_by_ft = {
      lua = { "stylua" },
    },
  },
}
