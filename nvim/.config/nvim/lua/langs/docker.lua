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
        config = function()
          require("telescope").load_extension "docker"
        end,
        keys = {
          { "<leader>fDc", "<cmd>Telescope docker containers<cr>", desc = "Docker containers" },
          { "<leader>fDC", "<cmd>Telescope docker compose<cr>", desc = "Docker compose" },
          { "<leader>fDi", "<cmd>Telescope docker images<cr>", desc = "Docker images" },
          { "<leader>fDv", "<cmd>Telescope docker volumes<cr>", desc = "Docker volumes" },
          { "<leader>fDf", "<cmd>Telescope docker files<cr>", desc = "Docker files" },
        },
      },
    },
    opts = {
      extensions = {
        docker = {
          machine_binary = false,
        },
      },
    },
  },
}
