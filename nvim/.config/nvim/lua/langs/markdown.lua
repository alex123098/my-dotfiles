--- @type LanguageSettings
return {
  lsps = {
    "markdownlint",
    "marksman",
  },
  grammars = {
    "markdown",
    "markdown_inline",
  },
  packages = {
    { src = "MeanderingProgrammer/render-markdown.nvim" },
  },
  setup = function()
    require("lint").linters_by_ft = vim.tbl_extend("force", require("lint").linters_by_ft or {}, {
      markdown = { "markdownlint" },
    })

    require("render-markdown").setup {}
  end,
}
