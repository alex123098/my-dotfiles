local pack = require "fw.pack"
local k = require "fw.keys"

pack.add { "lewis6991/gitsigns.nvim" }

require("gitsigns").setup {
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
  },
  on_attach = function(bufnr)
    local gitsigns = require "gitsigns"

    local function map(l, r, desc)
      k.nmap(l, r, desc, { buffer = bufnr })
    end

    map("]c", function()
      if vim.wo.diff then
        vim.cmd.normal { "]c", bang = true }
      else
        gitsigns.nav_hunk "next"
      end
    end, "Next git change")

    map("[c", function()
      if vim.wo.diff then
        vim.cmd.normal { "[c", bang = true }
      else
        gitsigns.nav_hunk "prev"
      end
    end, "Previous git change")

    map("<leader>gb", gitsigns.blame_line, "Blame current line")
    map("<leader>gB", gitsigns.blame, "Blame file")
    map("<leader>gd", gitsigns.diffthis, "Diff against index")
    map("<leader>gD", function()
      gitsigns.diffthis "@"
    end, "Diff against last commit")
  end,
}
