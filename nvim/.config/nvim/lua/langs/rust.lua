return {
  {
    "nvim-cmp",
    dependencies = { "Saecki/crates.nvim" },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources = vim.list_extend(opts.sources, { { name = "crates" } })
    end,
  },
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        cmp = { enabled = true },
        crates = {
          enabled = true,
          max_results = 5,
          min_chars = 3,
        },
      },
      popup = {
        border = "rounded",
      },
    },
    config = function()
      require("crates").setup {}

      -- setup Cargo.toml specific keymaps
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("CargoTomlKeymaps", { clear = true }),
        pattern = { "Cargo.toml" },
        callback = function(e)
          local buf = e.buf
          local function mapn(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc, silent = true, noremap = true })
          end
          mapn("<leader>cp", function()
            require("crates").show_crate_popup()
          end, "Crate details")
          mapn("<leader>cl", function()
            require("crates").show_dependencies_popup()
          end, "Crate dependencies")
          mapn("<leader>cf", function()
            require("crates").show_features_popup()
          end, "Crate features")
          mapn("<leader>co", function()
            require("crates").open_repository()
          end, "Open crate repository")
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "ron", "rust", "toml" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "codelldb", "rust-analyzer", "taplo" })
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^4",
    ft = { "rust" },
    opts = {
      server = {
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<leader>cR", function()
            vim.cmd.RustLsp "codeAction"
          end, { desc = "Code Action", buffer = bufnr })
          vim.keymap.set("n", "<leader>dr", function()
            vim.cmd.RustLsp "debuggables"
          end, { desc = "Rust debuggables", buffer = bufnr })
        end,
        default_settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              runBuildScripts = true,
            },
            checkOnSave = {
              allFeatures = true,
              command = "clippy",
              extraArgs = { "--no-deps" },
            },
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      vim.g.rustaceanvim = vim.tbl_extend("keep", vim.g.rustaceanvim or {}, opts or {})
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {},
        taplo = {
          keys = {
            {
              "K",
              function()
                if vim.fn.expand "%:t" == "Cargo.toml" and require("crates").popup_available() then
                  require("crates").show_popup()
                else
                  vim.lsp.buf.hover()
                end
              end,
              desc = "Show crate documentation",
            },
          },
        },
      },
      setup = {
        rust_analyzer = function()
          return true
        end,
      },
    },
  },
  {
    "nvim-neotest/neotest",
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      vim.list_extend(opts.adapters, { require "rustaceanvim.neotest" })
    end,
  },
}
