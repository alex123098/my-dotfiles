local u = require "utils"

-- Global LSP keymaps and document highlighting, applied to every LSP client
u.autocmd("LspAttach", {
  group = u.augroup "lsp-attach",
  callback = function(event)
    local function map(keys, func, desc)
      u.nmap(keys, func, "LSP: " .. desc, { buffer = event.buf })
    end
    local picker = require("snacks").picker

    map("gd", picker.lsp_definitions, "Goto definition")
    map("gr", picker.lsp_references, "Goto references")
    map("gI", picker.lsp_implementations, "Goto implementation")
    map("<leader>cD", picker.lsp_type_definitions, "Type definition")
    map("<leader>fs", picker.lsp_symbols, "Find symbols in current document")
    map("<leader>fS", picker.lsp_workspace_symbols, "Find symbols in workspace")
    map("<leader>cr", vim.lsp.buf.rename, "Rename")
    map("<leader>ca", require("actions-preview").code_actions, "Code action")
    map("<leader>cL", vim.lsp.codelens.run, "Codelens action")
    map("K", vim.lsp.buf.hover, "Hover Documentation")
    map("gD", vim.lsp.buf.declaration, "Goto declaration")

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      local highlight_augroup = u.augroupnc "lsp-highlight"
      u.autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      u.autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      u.autocmd("LspDetach", {
        group = u.augroup "lsp-detach",
        callback = function(ev)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = "lsp-highlight", buffer = ev.buf }
        end,
      })
    end

    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
      map("<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = 0 })
      end, "Toggle inlay hints")
    end
  end,
})

-- gopls: back-fill semanticTokensProvider if gopls doesn't report it
u.autocmd("LspAttach", {
  group = u.augroup "go-specifics",
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client or client.name ~= "gopls" then
      return
    end
    if not client.server_capabilities.semanticTokensProvider then
      local tokens = client.config.capabilities.textDocument.semanticTokens
      if tokens then
        client.server_capabilities.semanticTokensProvider = {
          full = true,
          legend = {
            tokenTypes = tokens.tokenTypes,
            tokenModifiers = tokens.tokenModifiers,
          },
          range = true,
        }
      end
    end
  end,
})

-- clangd: set up clangd_extensions and switch source/header keymap
u.autocmd("LspAttach", {
  group = u.augroup "clangd-specifics",
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client or client.name ~= "clangd" then
      return
    end
    require("clangd_extensions").setup { inlay_hints = { inline = false }, server = client.config }
    vim.keymap.set("n", "<leader>cR", "<cmd>ClangdSwitchSourceHeader<cr>", { buffer = event.buf, desc = "Switch source/header" })
  end,
})

-- omnisharp: override gd to use omnisharp_extended for decompilation support
u.autocmd("LspAttach", {
  group = u.augroup "omnisharp-specifics",
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client or client.name ~= "omnisharp" then
      return
    end
    vim.keymap.set("n", "gd", function()
      require("omnisharp_extended").lsp_definitions()
    end, { buffer = event.buf, desc = "Goto definition" })
  end,
})

-- ts_ls: organize and remove unused imports
u.autocmd("LspAttach", {
  group = u.augroup "ts_ls-specifics",
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client or client.name ~= "ts_ls" then
      return
    end
    vim.keymap.set("n", "<leader>co", function()
      vim.lsp.buf.code_action {
        apply = true,
        context = {
          ---@diagnostic disable-next-line: assign-type-mismatch
          only = { "source.organizeImports.ts" },
          diagnostics = {},
        },
      }
    end, { buffer = event.buf, desc = "Organize imports" })
    vim.keymap.set("n", "<leader>cR", function()
      vim.lsp.buf.code_action {
        apply = true,
        context = {
          ---@diagnostic disable-next-line: assign-type-mismatch
          only = { "source.removeUnused.ts" },
          diagnostics = {},
        },
      }
    end, { buffer = event.buf, desc = "Remove unused imports" })
  end,
})

-- taplo: show crate popup on K in Cargo.toml, fall back to hover otherwise
u.autocmd("LspAttach", {
  group = u.augroup "taplo-specifics",
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client or client.name ~= "taplo" then
      return
    end
    vim.keymap.set("n", "K", function()
      if vim.fn.expand "%:t" == "Cargo.toml" and require("crates").popup_available() then
        require("crates").show_popup()
      else
        vim.lsp.buf.hover()
      end
    end, { buffer = event.buf, desc = "Show crate documentation" })
  end,
})
