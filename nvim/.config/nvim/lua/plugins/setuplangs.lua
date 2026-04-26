local pack = require "fw.pack"

local langs = pack.languages()

for _, lang in ipairs(langs) do
  if lang.packages then
    pack.add(lang.packages)
  end

  if lang.setup then
    local ok, err = pcall(lang.setup)
    if not ok then
      vim.notify(string.format("Error setting up language %s: %s", lang.name, err), vim.log.levels.ERROR)
    end
  end
end