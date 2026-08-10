local pack = require "fw.pack"

-- Herdr navigation via aimdevlee/herdr-nvim-nav (socket-based, fast C binary)
pack.add {
  src = "aimdevlee/herdr-nvim-nav",
  load = true,
}

require("herdr-nvim-nav").setup {
  keymaps = {
    left = { "<C-h>" },
    down = { "<C-j>" },
    up = { "<C-k>" },
    right = { "<C-l>" },
  },
}

-- Note: herdr-nvim-nav sets up <C-h/j/k/l> keymaps internally and auto-detects
-- whether to use herdr or tmux navigation based on $HERDR_PANE_ID vs $TMUX
