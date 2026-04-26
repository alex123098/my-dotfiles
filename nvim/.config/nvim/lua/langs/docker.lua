--- @type LanguageSettings
return {
  lsps = {
    "hadolint",
    "dockerls",
    "docker-compose-language-service",
  },
  grammars = {
    "dockerfile",
  },
  setup = function()
    require("lint").linters_by_ft = vim.tbl_extend("force", require("lint").linters_by_ft or {}, {
      dockerfile = { "hadolint" },
    })
  end,
}
