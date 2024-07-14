return {
  {
    "nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "go",
        "gomod",
        "gowork",
        "gosum",
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = true,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = false,
                rangeVariableTypes = true,
              },
              analyses = {
                fieldalignment = true,
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-node_modules", "-.vscode-test" },
              semanticTokens = true,
            },
          },
        },
      },
      setup = {
        gopls = function()
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(event)
              local client = vim.lsp.get_client_by_id(event.data.client_id)
              if not client or client.name ~= "gopls" then
                return
              end
              if not client.server_capabilities.semanticTokensProvider then
                local tokens = client.config.capabilities.textDocument.semanticTokens
                if tokens then
                  client.server_capabilities.semanticTokensProvider = {
                    full = true,
                    legend = {
                      tokenTypes = tokens.tokenTypes,
                      tokenModifiers = tokens.tokenModifiers,
                    },
                    range = true,
                  }
                end
              end
            end,
          })
        end,
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "gopls", "goimports", "gofumpt", "delve" })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofumpt" },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-go",
    },
    opts = {
      adapters = {
        ["neotest-go"] = { recursive_run = true },
      },
    },
  },
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function(_, opts)
      -- override the "debug test" keybinding because neotest-go lacks integration with dap
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "go",
        group = vim.api.nvim_create_augroup("go-keymap", { clear = true }),
        callback = function(event)
          vim.keymap.set("n", "<leader>td", function()
            require("dap-go").debug_test()
          end, { buffer = event.buf })
        end,
      })

      require("go").setup(opts)
    end,
    event = "CmdLineEnter",
    ft = { "go", "gomod" },
    build = function()
      require("go.install").update_all()
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      if type(opts.linters_by_ft) == "table" then
        vim.list_extend(opts.linters_by_ft, { go = { "golangcilint" } })
      end
    end,
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "leoluz/nvim-dap-go", config = true },
    },
  },
}
