local pack = require "fw.pack"
local k = require "fw.keys"

pack.add { "folke/snacks.nvim" }

local snacks = require "snacks"

snacks.setup {
  image = { enabled = true },
  picker = {
    enabled = true,
    layout = "bottom_search",
    layouts = {
      bottom_search = {
        layout = {
          box = "vertical",
          backdrop = false,
          row = -1,
          width = 0,
          height = 0.4,
          border = "top",
          title = " {title} {live} {flags}",
          title_pos = "left",
          {
            box = "horizontal",
            { win = "list", border = "none" },
            { win = "preview", title = "{preview}", width = 0.6, border = "left" },
          },
          { win = "input", height = 1, border = "top" },
        },
      },
    },
    actions = {
      trouble_open = function(...)
        return require("trouble.sources.snacks").actions.trouble_open.action(...)
      end,
    },
    win = {
      input = {
        keys = {
          ["<C-t>"] = {
            "trouble-open",
            mode = { "n", "i" },
          },
        },
      },
    },
  },
  explorer = {},
}

k.nmap("<leader>bsn", function()
  snacks.scratch()
end, "Open scratch buffer")
k.nmap("<leader>bss", function()
  snacks.scratch.select()
end, "Select scratch buffer")
k.nmap("<leader>/", function()
  snacks.picker.grep()
end, "Live grep")
k.nmap("<leader>ff", function()
  snacks.picker.files()
end, "Find files")
k.nmap("<leader>fh", function()
  snacks.picker.help()
end, "Find help tags")
k.nmap("<leader>fk", function()
  snacks.picker.keymaps()
end, "Keymaps")
k.nmap("<leader>fd", function()
  snacks.picker.diagnostics()
end, "Diagnostics")
k.nmap("<leader>fn", function()
  snacks.picker.notifications()
end, "Notifications")
k.nmap("<leader>e", function()
  snacks.explorer()
end, "Open file explorer")
k.nmap("<leader>bd", function()
  snacks.bufdelete()
end, "Close current buffer")
k.nmap("<leader>bad", function()
  snacks.bufdelete.all()
end, "Close all buffers")
k.nmap("<leader>bod", function()
  snacks.bufdelete.other()
end, "Close all buffers but current")
