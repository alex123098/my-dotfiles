--- @type LanguageSettings
return {
  lsps = {
    "stylua",
    "lua_ls",
  },
  grammars = {
    "lua",
    "luadoc",
  },
  packages = {
    { src = "nvim-neotest/neotest-plenary" },
  },
  test_adapters = {
    "neotest-plenary",
  },
  setup = function()
    require("conform").formatters_by_ft.lua = { "stylua" }
  end,
}
