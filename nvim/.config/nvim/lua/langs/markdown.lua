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

    -- Mute MD013 (line length) warning for markdown files
    require("lint").linters.markdownlint.args = { "--stdin", "--disable", "MD013" }

    require("render-markdown").setup {}
  end,
}
