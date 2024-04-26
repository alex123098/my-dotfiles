return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    config = true,
    build = ":Copilot auth",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
      },
      filetypes = {
        markdown = true,
        yaml = true,
      },
    },
    keys = {
      {
        "<C-Space>",
        function()
          local suggestion = require "copilot.suggestion"
          if suggestion.is_visible() then
            suggestion.accept_line()
          end
        end,
        mode = "i",
      },
    },
  },
}
