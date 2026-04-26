local pack = require "fw.pack"
local cmd = require "fw.cmds"

pack.add {
  { src = "nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
  "nvim-treesitter/nvim-treesitter-context",
}

local langs = pack.languages()
--- @type string[]
local grammars = {
  "html",
  "c",
  "vim",
  "vimdoc",
  "regex",
  "diff",
}

for _, lang in ipairs(langs) do
  if lang.grammars then
    vim.list_extend(grammars, lang.grammars)
  end
end

require("nvim-treesitter.install").prefer_git = true
-- New API: setup() only accepts install_dir; parser installation is imperative
require("nvim-treesitter").install(grammars)

require("treesitter-context").setup {
  mode = "cursor",
  max_lines = 5,
  multiline_threshold = 1,
  separator = "─",
}

-- auto-enable syntax highlight and treesitter indentation
cmd.autocmd("FileType", {
  group = cmd.augroup "ts-highlight",
  callback = function(args)
    local buf = args.buf
    local ft = vim.bo[buf].filetype
    local lang = vim.treesitter.language.get_lang(ft)

    if lang and vim.treesitter.query.get(lang, "highlights") then
      vim.treesitter.start(buf, lang)
    end

    if lang and vim.treesitter.query.get(lang, "indents") then
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})