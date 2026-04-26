local M = {}

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
--- @param event vim.api.keyset.events|vim.api.keyset.events[]
--- @param opts vim.api.keyset.create_autocmd
function M.autocmd(event, opts)
  vim.api.nvim_create_autocmd(event, opts)
end

--- Stubs an autocommand on first invocation of a plugin-provided command. Useful for lazy loading
--- @param name string|string[] Name of custom command
--- @param callback function a callback to register
function M.stub(name, callback)
  local names = type(name) == "table" and name or { name }

  for _, cmd in ipairs(names) do
    --- @cast cmd string
    vim.api.nvim_create_user_command(cmd, function(opts)
      vim.api.nvim_del_user_command(cmd)
      callback()
      vim.cmd(cmd .. " " .. opts.args)
    end, { nargs = "*" })
  end
end

return M
