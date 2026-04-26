--- @type LanguageSettings
return {
  packages = {
    { src = "inzoiniac/renpy-syntax.nvim" },
  },
  setup = function()
    require("renpy-syntax").setup()

    -- add renpy completion source to blink.cmp
    local ok, blink = pcall(require, "blink.cmp")
    if ok then
      blink.add_provider("renpy", {
        per_filetype = { renpy = { "renpy" } },
      })
    end
  end,
}
