local u = require "utils"

return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      {
        "kristijanhusak/vim-dadbod-completion",
        ft = { "sql", "mysql", "plsql", "sqlserver", "pgsql", "sqlite" },
        lazy = true,
      },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
  {
    "nvim-cmp",
    dependencies = { "kristijanhusak/vim-dadbod-completion" },
    opts = function(_, _)
      u.autocmd("FileType", {
        group = u.augroup "SQLCmp",
        pattern = { "sql", "mysql", "plsql", "sqlserver", "pgsql", "sqlite" },
        callback = function(_)
          local cmp = require "cmp"
          cmp.setup.buffer {
            sources = {
              { name = "vim-dadbod-completion" },
              { name = "buffer" },
            },
          }
        end,
      })
    end,
    config = function()
      local cmp = require "cmp"

      cmp.setup.filetype({ "sql", "mysql", "plsql", "sqlserver", "pgsql", "sqlite" }, {
        sources = {
          { name = "vim-dadbod-completion" },
          { name = "buffer" },
        },
      })
    end,
  },
}
