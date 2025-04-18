local M = {}
-- set keymap shortcuts

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

--- Creates a mapping in normal mode
--- @param lhs string Sets a shortcut
--- @param rhs string|function An action to map shortcut to. Can be a function
--- @param desc? string A description of a key mapping
--- @param opts? KeymapOpts Additional keymap options
function M.nmap(lhs, rhs, desc, opts)
  M.map("n", lhs, rhs, desc, opts)
end

--- Creates a mapping in normal mode
--- @param mode string|string[] Mode shortname to apply keymaps to
--- @param lhs string Sets a shortcut
--- @param rhs string|function An action to map shortcut to. Can be a function
--- @param desc? string A description of a key mapping
--- @param opts? KeymapOpts Additional keymap options
function M.map(mode, lhs, rhs, desc, opts)
  ---@class descOpts :KeymapOpts
  ---@field desc? string
  opts = opts or {}
  opts.desc = desc
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- autocommands and autogroups

--- Creates an autocommands group with clear = true
--- @param name string
function M.augroup(name)
  vim.api.nvim_create_augroup(name, { clear = true })
end

--- Creates an autocommands group with clear = false
--- @param name string
function M.augroupnc(name)
  vim.api.nvim_create_augroup(name, { clear = false })
end

--- Creates an autocommand
--- @param event string|string[]
--- @param opts vim.api.keyset.create_autocmd
function M.autocmd(event, opts)
  vim.api.nvim_create_autocmd(event, opts)
end

return M
