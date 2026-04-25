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
    "MoaidHathot/dotnet.nvim",
    ft = "cs",
    cmd = "DotnetUI",
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
