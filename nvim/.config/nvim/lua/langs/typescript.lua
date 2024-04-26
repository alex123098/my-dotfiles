return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "typescript", "tsx" })
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tsserver = {
          keys = {
            {
              "<leader>co",
              function()
                vim.lsp.buf.code_action {
                  apply = true,
                  context = {
                    ---@diagnostic disable-next-line: assign-type-mismatch
                    only = { "source.organizeImports.ts" },
                    diagnostics = {},
                  },
                }
              end,
              desc = "Organize imports",
            },
            {
              "<leader>cR",
              function()
                vim.lsp.buf.code_action {
                  apply = true,
                  context = {
                    ---@diagnostic disable-next-line: assign-type-mismatch
                    only = { "source.removeUnused.ts" },
                    diagnostics = {},
                  },
                }
              end,
              desc = "Remove unused imports",
            },
          },
          settings = {
            completions = {
              completeFunctionCalls = true,
            },
          },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, { "js-debug-adapter", "tsserver" })
      end,
    },
    opts = function()
      local dap = require "dap"
      if not dap.adapters["pwa-node"] then
        dap.adapters["pwa-node"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = {
              require("mason-registry").get_package("js-debug-adapter"):get_install_path() .. "/js-debug/src/dapDebugServer.js",
              "${port}",
            },
          },
        }
      end
      for _, lang in ipairs { "typescript", "javascript", "typescriptreact", "javascriptreact" } do
        if not dap.configurations[lang] then
          dap.configurations[lang] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = "${workspaceFolder}",
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach to process",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
            },
          }
        end
      end
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    opts = {},
  },
}
