--- @type LanguageSettings
return {
  lsps = {
    "netcoredbg",
    "roslyn",
  },
  grammars = {
    "c_sharp",
  },
  packages = {
    { src = "seblyng/roslyn.nvim" },
    { src = "MoaidHathot/dotnet.nvim" },
    { src = "Issafalcon/neotest-dotnet" },
  },
  test_adapters = {
    "neotest-dotnet",
  },
  setup = function()
    -- packadd ensures roslyn.nvim is loaded from opt/ (deferred plugin)
    vim.cmd.packadd "roslyn.nvim"

    require("roslyn").setup {
      -- Enable broad search to find solution files in parent directories
      broad_search = true,
      -- Don't silence notifications so we can see what's happening
      silent = false,
      -- File watching: let roslyn handle it for better project tracking
      filewatching = "roslyn",
      extensions = {
        razor = {
          enabled = false,
        },
      },
    }

    require("dotnet").setup {
      auto_bootstrap = false,
    }

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
            program = function()
              return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
            end,
            cwd = "${workspaceFolder}",
          },
        }
      end
    end
  end,
}