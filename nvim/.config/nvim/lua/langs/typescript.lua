--- @type LanguageSettings
return {
  lsps = {
    "js-debug-adapter",
    "ts_ls",
  },
  grammars = {
    "typescript",
    "tsx",
    "javascript",
  },
  packages = {
    { src = "windwp/nvim-ts-autotag" },
  },
  setup = function()
    require("nvim-ts-autotag").setup {}

    local dap = require "dap"
    if not dap.adapters["pwa-node"] then
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            vim.fn.expand "$MASON/packages/js-debug-adapter" .. "/js-debug/src/dapDebugServer.js",
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
}
