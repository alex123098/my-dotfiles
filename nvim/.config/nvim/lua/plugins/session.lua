return {
  {
    "rmagatti/auto-session",
    config = function()
      require("auto-session").setup {
        log_level = "error",
        auto_restore_enabled = true,
        auto_session_suppress_dirs = { "~/", "~/Downloads", "~/Documents", "/" },
      }
    end,
  },
}
