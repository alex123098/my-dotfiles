--- @type LanguageSettings
return {
  lsps = {
    "jsonls",
    "jsonlint",
  },
  grammars = {
    "json",
    "json5",
  },
  packages = {
    { src = "b0o/SchemaStore.nvim" },
  },
}