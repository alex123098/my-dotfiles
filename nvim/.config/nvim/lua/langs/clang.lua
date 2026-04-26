--- @type LanguageSettings
return {
  lsps = {
    "clangd",
    "codelldb",
  },
  grammars = {
    "c",
    "cpp",
  },
  packages = {
    { src = "p00f/clangd_extensions.nvim" },
  },
  setup = function()
    require("clangd_extensions").setup {
      inlay_hints = { inline = false },
    }

    local dap = require "dap"
    if not dap.adapters["codelldb"] then
      dap.adapters["codelldb"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "codelldb",
          args = { "--port", "${port}" },
        },
      }
    end
    for _, lang in ipairs { "c", "cpp" } do
      dap.configurations[lang] = {
        {
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
        },
        {
          type = "codelldb",
          request = "attach",
          name = "Attach to process",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
      }
    end
  end,
}
