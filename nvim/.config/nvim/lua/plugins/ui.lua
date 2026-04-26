local pack = require "fw.pack"
local k = require "fw.keys"

pack.add {
  "folke/tokyonight.nvim",
  "echasnovski/mini.icons",
  "echasnovski/mini.animate",
  "MunifTanjim/nui.nvim",
  "folke/noice.nvim",
  "echasnovski/mini.tabline",
}

require("tokyonight").setup {
  transparent = true,
  styles = {
    floats = "transparent",
    sidebars = "transparent",
  },
  on_colors = function(c)
    c.bg_statusline = "#292e42"
  end,
  on_highlights = function(hl, c)
    hl.StatusLine = { fg = c.fg_sidebar, bg = c.bg_statusline }
  end,
}

vim.cmd.colorscheme "tokyonight-night"
vim.cmd.hi "Comment gui=none"

require("mini.icons").setup {
  file = {
    [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
    ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
  },
  filetype = {
    dotenv = { glyph = "", hl = "MiniIconsYellow" },
  },
}
require("mini.icons").mock_nvim_web_devicons()

local mouse_scrolled = false
for _, scroll in ipairs { "Up", "Down" } do
  local key = "<ScrollWheel" .. scroll .. ">"
  k.map({ "", "i" }, key, function()
    mouse_scrolled = true
    return key
  end, nil, { expr = true })
end

local animate = require "mini.animate"
animate.setup {
  open = { enable = false },
  close = { enable = false },
  resize = {
    timing = animate.gen_timing.linear { duration = 100, unit = "total" },
  },
  scroll = {
    timing = animate.gen_timing.linear { duration = 150, unit = "total" },
    subscroll = animate.gen_subscroll.equal {
      predicate = function(total_scroll)
        if mouse_scrolled then
          mouse_scrolled = false
          return false
        end
        return total_scroll > 1
      end,
    },
  },
}

-- set statusline
vim.opt.statusline = "%!v:lua.require'plugins.statusline'.render()"

require("noice").setup {
  cmdline = {
    enabled = true,
    view = "cmdline",
  },
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  routes = {
    filter = {
      event = "msg_show",
      any = {
        { find = "%d+L, %d+B" },
        { find = "; after #%d+" },
        { find = "; before #%d+" },
      },
      view = "mini",
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = true,
  },
}

local cmd = require "fw.cmds"
cmd.autocmd("VimEnter", {
  group = cmd.augroup "tabline-setup",
  callback = function()
    vim.cmd.packadd "mini.tabline"
    require("mini.tabline").setup()
  end,
})

