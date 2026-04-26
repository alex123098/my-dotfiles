local pack = require "fw.pack"
local cmd = require "fw.cmds"
local k = require "fw.keys"

pack.add {
  "Bekaboo/dropbar.nvim",
  "echasnovski/mini.pairs",
  "echasnovski/mini.ai",
  "echasnovski/mini.surround",
  "echasnovski/mini.move",
  "folke/todo-comments.nvim",
  "catgoose/nvim-colorizer.lua",
  "folke/which-key.nvim",
}

require("dropbar").setup {
  -- bar = {
  --   enable = function(buf, win, _)
  --     buf = vim._resolve_bufnr(buf)
  --     if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
  --       return false
  --     end
  --
  --     if vim.fn.win_gettype(win) ~= "" or vim.wo[win].winbar ~= "" or vim.bo[buf].ft == "help" then
  --       -- disabling winbar apparently cleans state of dropbar
  --       vim.wo[win].winbar = nil
  --       return false
  --     end
  --
  --     -- disable dropbar for huge files (over 1Kib)
  --     local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
  --     if stat and stat.size > 1024 * 1024 then
  --       return false
  --     end
  --
  --     return vim.bo[buf].bt == "terminal"
  --       or vim.bo[buf].ft == "markdown"
  --       -- or pcall(vim.treesitter.get_parser, buf)
  --       or not vim.tbl_isempty(vim.lsp.get_clients {
  --         bufnr = buf,
  --         method = "textDocument/documentSymbol",
  --       })
  --   end,
  -- },
}
local barapi = require "dropbar.api"
k.nmap("[;", barapi.goto_context_start, "Go to start of current context")
k.nmap("];", barapi.select_next_context, "Go to next context")

-- setup pairs
vim.schedule(function()
  require("mini.pairs").setup {
    modes = { insert = true, command = true, terminal = false },
    -- skip pairing for certain characters
    skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
    -- disable pairs when inside of string literal
    skip_ts = { "string" },
    -- skip pairing when next symbol is matching pair and pairs are unbalanced
    skip_unbalanced = true,
    -- handle code regions inside of markdown
    markdown = true,
  }

  require("mini.ai").setup { n_lines = 500 }
  require("mini.move").setup()

  require("mini.surround").setup {
    mappings = {
      add = "sa",
      delete = "sd",
      find = "sf",
      find_left = "sF",
      highlight = "sh",
      replace = "sr",
      update_n_lines = "sn",

      suffix_last = "l",
      suffix_next = "n",
    },
  }

  require("colorizer").setup()
end)

cmd.autocmd("VimEnter", {
  group = cmd.augroup "todoc-setup",
  callback = function()
    require("todo-comments").setup()

    k.nmap("<leader>ft", function()
      --- @diagnostic disable-next-line: undefined-field
      require("snacks").picker.todo_comments { keywords = { "todo", "fix", "fixme", "bug", "TODO", "FIX", "FIXME", "BUG" } }
    end, "ToDos")
  end,
})

-- show buffer-local keymaps in which-key
require("which-key").setup {}
k.nmap("<leader>?", function()
  require("which-key").show { global = false }
end, "Buffer keymaps (which-key)")
