--- @type LanguageSettings
return {
  packages = {
    { src = "kristijanhusak/vim-dadbod-ui" },
    { src = "tpope/vim-dadbod" },
    { src = "kristijanhusak/vim-dadbod-completion" },
  },
  setup = function()
    vim.g.db_ui_use_nerd_fonts = 1

    -- blink.cmp dadbod source
    local ok, blink = pcall(require, "blink.cmp")
    if ok then
      blink.add_provider("dadbod", {
        name = "Dadbod",
        module = "vim_dadbod_completion.blink",
      })
    end
  end,
}
