local k = require "fw.keys"
local cmd = require "fw.cmds"
local packages = require "fw.pack"

packages.add {
  "neovim/nvim-lspconfig",
  "mason-org/mason.nvim",
  "mason-org/mason-lspconfig.nvim",
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  "folke/lazydev.nvim",
  "aznhe21/actions-preview.nvim",
  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
}

local langs = packages.languages()
local lsps = {}
local lang_packages = {}

-- add language-specific packages
for _, lang in ipairs(langs) do
  if lang.packages then
    vim.list_extend(lang_packages, lang.packages)
  end
  if lang.lsps then
    vim.list_extend(lsps, lang.lsps)
  end
end

if #lang_packages > 0 then
  packages.add(lang_packages)
end

require("mason").setup {
  registries = {
    "github:mason-org/mason-registry",
    "github:Crashdummyy/mason-registry",
  },
}
require("mason-lspconfig").setup()
require("mason-tool-installer").setup {
  ensure_installed = lsps,
}

require("lazydev").setup {
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    { path = "snacks.nvim", words = { "Snacks" } },
  },
}

require("actions-preview").setup {}
require("lsp_lines").setup()

cmd.autocmd("LspAttach", {
  group = cmd.augroup "lsp-attach",
  callback = function(event)
    local function map(keys, func, desc)
      k.nmap(keys, func, "LSP: " .. desc, { buffer = event.buf })
    end
    local picker = require("snacks").picker

    vim.diagnostic.config {
      virtual_text = true,
      virtual_lines = false,
    }
    local function lines_toggle()
      local current = vim.diagnostic.config().virtual_text
      --- @cast current boolean
      vim.diagnostic.config {
        virtual_text = not current,
        virtual_lines = current,
      }
      return current
    end

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
    map("<leader>cl", lines_toggle, "Toggle underline diagnostics")

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      local highlight_augroup = cmd.augroupnc "lsp-highlight"
      cmd.autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      cmd.autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      cmd.autocmd("LspDetach", {
        group = cmd.augroup "lsp-detach",
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
