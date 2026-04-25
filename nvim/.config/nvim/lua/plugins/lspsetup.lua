local u = require "utils"

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
          {
            "williamboman/mason.nvim",
            build = ":MasonUpdate",
            config = function()
              require("mason").setup()
            end,
          },
        },
        config = function()
          require("mason-lspconfig").setup()
        end,
      },
      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = {
          "williamboman/mason.nvim",
          "williamboman/mason-lspconfig.nvim",
        },
        opts = {
          ensure_installed = {
            "stylua",
            "lua_ls",
          },
        },
        config = function(_, opts)
          require("mason-tool-installer").setup(opts)
        end,
      },
      { "j-hui/fidget.nvim", opts = {} },
      {
        "folke/lazydev.nvim",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            { path = "snacks.nvim", words = { "Snacks" } },
          },
        },
        ft = { "lua" },
      },
      {
        "aznhe21/actions-preview.nvim",
        event = "VeryLazy",
      },
    },
    config = function()
      require("mason-lspconfig").setup {}
    end,
  },
  {
    src = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    opts = true,
    config = function()
      require("lsp_lines").setup()

      vim.diagnostic.config {
        virtual_text = true,
        virtual_lines = false,
      }

      local function lines_toggle()
        local current = vim.diagnostic.config().virtual_text
        --- @cast current boolean
        vim.diagnostic.config {
          virtual_text = not current,
          virtual_lines = current,
        }
        return current
      end
      u.nmap("<leader>cl", lines_toggle, "Toggle underline diagnostics", { silent = true })
    end,
  },
}
