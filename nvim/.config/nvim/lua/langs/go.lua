--- @type LanguageSettings
return {
  lsps = {
    "gopls",
    "goimports",
    "gofumpt",
    "delve",
  },
  grammars = {
    "go",
    "gomod",
    "gowork",
    "gosum",
  },
  packages = {
    { src = "ray-x/go.nvim" },
    { src = "ray-x/guihua.lua" },
    { src = "leoluz/nvim-dap-go" },
    { src = "fredrikaverpil/neotest-golang", version = vim.version.range "*", load = true },
  },
  test_adapters = {
    ["neotest-golang"] = {
      recursive_run = true,
      dap_go_enabled = true,
      runner = "gotestsum",
      testify_enabled = true,
    },
  },
  setup = function()
    require("conform").formatters_by_ft.go = { "goimports", "gofumpt" }

    require("lint").linters_by_ft = vim.tbl_extend("force", require("lint").linters_by_ft or {}, {
      go = { "golangcilint" },
    })

    require("dap-go").setup()

    require("go").setup()

    -- override "debug test" keymap because neotest-go lacks dap integration
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "go",
      group = vim.api.nvim_create_augroup("go-keymap", { clear = true }),
      callback = function(event)
        vim.keymap.set("n", "<leader>td", function()
          require("dap-go").debug_test()
        end, { buffer = event.buf, desc = "Debug nearest test" })
      end,
    })
  end,
}