local M = {}

--- @class KeymapOpts
--- @field buffer? integer|boolean
--- @field remap? boolean
--- @field noremap? boolean
--- @field nowait? boolean
--- @field silent? boolean
--- @field script? boolean
--- @field expr? boolean
--- @field unique? boolean
--- @field callback? function
--- @field replace_keycodes? boolean

--- Creates a key mapping
--- @param mode string|string[] Mode shortname to apply keymaps to
--- @param lhs string Sets a shortcut
--- @param rhs string|function An action to map shortcut to. Can be a function
--- @param desc? string A description of a key mapping
--- @param opts? KeymapOpts Additional keymap options
function M.map(mode, lhs, rhs, desc, opts)
  local o = opts or {}
  --- @cast o vim.keymap.set.Opts
  o.desc = desc

  vim.keymap.set(mode, lhs, rhs, o)
end

--- Creates a mapping in normal mode
--- @param lhs string Sets a shortcut
--- @param rhs string|function An action to map shortcut to. Can be a function
--- @param desc? string A description of a key mapping
--- @param opts? KeymapOpts Additional keymap options
function M.nmap(lhs, rhs, desc, opts)
  M.map("n", lhs, rhs, desc, opts)
end

--- Creates a mapping in insert mode
--- @param lhs string Sets a shortcut
--- @param rhs string|function An action to map shortcut to. Can be a function
--- @param desc? string A description of a key mapping
--- @param opts? KeymapOpts Additional keymap options
function M.imap(lhs, rhs, desc, opts)
  M.map("i", lhs, rhs, desc, opts)
end

--- Creates a mapping in visual mode
--- @param lhs string Sets a shortcut
--- @param rhs string|function An action to map shortcut to. Can be a function
--- @param desc? string A description of a key mapping
--- @param opts? KeymapOpts Additional keymap options
function M.vmap(lhs, rhs, desc, opts)
  M.map("v", lhs, rhs, desc, opts)
end

return M
