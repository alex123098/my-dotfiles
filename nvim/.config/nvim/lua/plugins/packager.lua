return {
  {
    -- canonical upstream is GitLab; GitHub repo is a mirror
    src = "https://gitlab.com/sairy/zshow.nvim",
    lazy = false,
    init = function()
      vim.g.zshow_opts = {
        backdrop = { enable = true },
        formatting = {
          show_version = true,
          short_sha = true,
        },
      }
    end,
    keys = {
      { "<leader>zp", "<cmd>ZShow<cr>", desc = "Plugin manager" },
    },
  },
}
