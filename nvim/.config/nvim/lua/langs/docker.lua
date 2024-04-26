return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "dockerfile" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "hadolint", "dockerls", "docker-compose-language-service" })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = { dockerfile = { "hadolint" } },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        dockerls = {},
        docker_compose_language_service = {},
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "lpoto/telescope-docker.nvim",
        opts = {},
        config = function()
          require("telescope").load_extension "docker"
        end,
        keys = {
          { "<leader>fD", "<cmd>Telescope docker<cr>", desc = "Docker containers" },
        },
      },
    },
  },
}
