return {
  { "Hoffs/omnisharp-extended-lsp.nvim", lazy = true },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "c_sharp" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "netcoredbg", "omnisharp" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = {
          handlers = {
            ["textDocument/definition"] = function(...)
              return require("omnisharp_extended").handler(...)
            end,
          },
          keys = {
            {
              "gd",
              function()
                require("omnisharp_extended").telescope_lsp_definitions()
              end,
              desc = "Goto definition",
            },
          },
          enable_roslyn_analyzers = true,
          organize_imports_on_format = true,
          enable_import_completion = true,
          enable_decompilation_support = true,
        },
      },
    },
  },
  {
    "MoaidHathot/dotnet.nvim",
    ft = "cs",
    cmd = "DotnetUI",
    keys = {
      { "<leader>cn", desc = ".NET" },
      { "<leader>cni", "<cmd>DotnetUI new_item<cr>", desc = "New item", silent = true },
      { "<leader>cnf", "<cmd>DotnetUI file bootstrap", desc = "New *.cs file", silent = true },
      { "<leader>cnra", "<cmd>DotnetUI project reference add<cr>", desc = "Add project reference", silent = true },
      { "<leader>cnrr", "<cmd>DotnetUI project reference remove<cr>", desc = "Remove project reference", silent = true },
      { "<leader>cnpa", "<cmd>DotnetUI project package add<cr>", desc = "Add package reference", silent = true },
      { "<leader>cnpr", "<cmd>DotnetUI project package remove<cr>", desc = "Remove package reference", silent = true },
    },
    opts = {
      auto_bootstrap = false,
    },
  },
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require "dap"
      if not dap.adapters["netcoredbg"] then
        dap.adapters["netcoredbg"] = {
          type = "executable",
          command = vim.fn.exepath "netcoredbg",
          args = { "--interpreter=vscode" },
        }
      end
      for _, lang in ipairs { "cs", "fsharp" } do
        if not dap.configurations[lang] then
          dap.configurations[lang] = {
            {
              type = "netcoredbg",
              name = "Launch file",
              request = "launch",
              ---@diagnostic disable-next-line: redundant-parameter
              program = function()
                return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
              end,
              cwd = "${workspaceFolder}",
            },
          }
        end
      end
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = { "Issafalcon/neotest-dotnet" },
    opts = {
      adapters = {
        ["neotest-dotnet"] = {},
      },
    },
  },
}
