local pack = require "fw.pack"

pack.add { src = "rmagatti/auto-session", load = true }

require("auto-session").setup {
  log_level = "error",
  auto_restore = true,
  suppress_dirs = { "~/", "/" },
}
