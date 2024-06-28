return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} },
      { "folke/neodev.nvim", opts = {} },
      {
        "aznhe21/actions-preview.nvim",
        event = "VeryLazy",
      },
    },
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              codeLens = { enable = true },
              diagnostics = { disable = { "missing-fields" } },
            },
          },
        },
      },
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local function map(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", require("telescope.builtin").lsp_definitions, "Goto definition")
          map("gr", require("telescope.builtin").lsp_references, "Goto references")
          map("gI", require("telescope.builtin").lsp_implementations, "Goto implementation")
          map("<leader>cD", require("telescope.builtin").lsp_type_definitions, "Type definition")
          map("<leader>fs", require("telescope.builtin").lsp_document_symbols, "Find symbols in current document")
          map("<leader>fS", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Find symbols in workspace")
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", require("actions-preview").code_actions, "Code action")
          map("<leader>cL", vim.lsp.codelens.run, "Codelens action")
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("gD", vim.lsp.buf.declaration, "Goto declaration")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
              callback = function(ev)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = "lsp-highlight", buffer = ev.buf }
              end,
            })
          end

          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, "Toggle inlay hints")
          end
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      local servers = opts.servers
      require("mason-lspconfig").setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            if opts.setup[server_name] then
              if opts.setup[server_name](server) then
                return
              end
            end
            require("lspconfig")[server_name].setup(server)
          end,
        },
      }
    end,
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = true,
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    opts = true,
    config = function()
      require("lsp_lines").setup()

      vim.diagnostic.config {
        virtual_text = true,
        virtual_lines = false,
      }

      local function lines_toggle()
        local current = vim.diagnostic.config().virtual_text
        vim.diagnostic.config {
          virtual_text = not current,
          virtual_lines = current,
        }
        return current
      end
      vim.keymap.set("n", "<leader>cl", lines_toggle, { desc = "Toggle underline diagnostics", silent = true })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    opts = {
      ensure_installed = {
        "stylua",
        "lua_ls",
      },
    },
  },
}
