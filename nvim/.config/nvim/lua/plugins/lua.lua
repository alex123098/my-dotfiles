return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              enable = true,
              globals = { "vim", "awesome", "client", "root", "network_interfaces", "apps", "tag", "screen", "globalkeys" },
            },
          },
        },
      },
    },
  },
}
