local M = {}

--- @class LanguageSettings
--- @field packages? PackSpec[] Additional packages to install
--- @field setup? function Package setup
--- @field lsps? string[] LSP servers to use
--- @field grammars? string[] List of tree-sitter grammars
--- @field name? string Language name
--- @field test_adapters table Configuraion of test adapters

--- Returns a list of language-specific settings
--- @return LanguageSettings[]
function M.languages()
  local langs_path = vim.fn.stdpath "config" .. "/lua/langs/"
  --- @type string[]
  local files = vim.fn.readdir(langs_path, [[v:val =~ '\.lua$']])

  --- @type LanguageSettings[]
  local settings = {}
  for _, file in ipairs(files) do
    local name = file:gsub("%.lua$", "")

    local mod_name = "langs." .. name
    --- @type LanguageSettings
    local lang_settings = require(mod_name)
    if not lang_settings.name then
      lang_settings.name = name
    end

    table.insert(settings, lang_settings)
  end

  return settings
end

--- @class LoadParam
--- @field spec vim.pack.Spec
--- @field path string

--- @class PackSpec:vim.pack.Spec
--- @field load boolean|fun(args: LoadParam)

--- @param src string
--- @return string
local function normalize_source(src)
  if vim.startswith(src, "https://") then
    return src
  end
  return "https://github.com/" .. src
end

--- @param spec string|PackSpec
--- @return string|vim.pack.Spec
local function normalize_spec(spec)
  if type(spec) == "string" then
    return normalize_source(spec)
  end

  local out = vim.deepcopy(spec)
  out.src = normalize_source(spec.src)
  out.load = nil
  return out
end

--- Adds a package(s), normalizing "author/name" shorthands to full GitHub URLs
--- @param pkg (string|PackSpec)|(string|PackSpec)[]
function M.add(pkg)
  --- @type (string|PackSpec)[]
  local specs = vim.islist(pkg) and pkg --[[@as (string|PackSpec)[] ]] or {
    pkg --[[@as string|PackSpec]],
  }
  --- @type (string|vim.pack.Spec)[]
  local no_loads = {}
  --- @type (string|vim.pack.Spec)[]
  local eager_loads = {}
  --- @type (string|PackSpec)[]
  local custom_loads = {}
  for _, spec in ipairs(specs) do
    if not spec.load then
      table.insert(no_loads, normalize_spec(spec) --[[@as string|vim.pack.Spec]])
    elseif type(spec.load) == "function" then
      table.insert(custom_loads, normalize_spec(spec) --[[@as string|vim.pack.Spec]])
    else
      table.insert(eager_loads, normalize_spec(spec))
    end
  end

  if #no_loads > 0 then
    vim.pack.add(no_loads, { load = false })
  end

  if #eager_loads > 0 then
    vim.pack.add(eager_loads, { load = true })
  end

  for _, spec in ipairs(custom_loads) do
    vim.pack.add({ spec }, { load = spec.load })
  end
end

return M