return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects" },
      { "nvim-treesitter/nvim-treesitter-context" },
    },
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "c",
        "html",
        "lua",
        "luadoc",
        "vim",
        "vimdoc",
        "regex",
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "ruby" },
      },
      indent = {
        enable = true,
        disable = { "ruby" },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.install").prefer_git = true
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    enabled = true,
    event = "BufReadPre",
    keys = {
      {
        "[h",
        function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end,
        silent = true,
        desc = "Jump to context header",
      },
    },
    opts = {
      mode = "cursor",
      max_lines = 5,
      multiline_threshold = 1,
      separator = "─",
    },
  },
}
