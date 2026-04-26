--- @type LanguageSettings
return {
  lsps = {
    "codelldb",
    "rust-analyzer",
    "taplo",
  },
  grammars = {
    "ron",
    "rust",
    "toml",
  },
  packages = {
    { src = "Saecki/crates.nvim" },
    { src = "mrcjkb/rustaceanvim" },
  },
  test_adapters = {
    "rustaceanvim.neotest",
  },
  setup = function()
    require("crates").setup {
      completion = {
        crates = {
          enabled = true,
          max_results = 5,
          min_chars = 3,
        },
      },
      popup = {
        border = "rounded",
      },
    }

    -- Cargo.toml keymaps
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

    vim.g.rustaceanvim = vim.tbl_extend("keep", vim.g.rustaceanvim or {}, {
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
    })
  end,
}
