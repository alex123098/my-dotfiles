local pack = require "fw.pack"
local k = require "fw.keys"

pack.add {
  "mfussenegger/nvim-dap",
  "rcarriga/nvim-dap-ui",
  "nvim-neotest/nvim-nio",
  "theHamsta/nvim-dap-virtual-text",
  "jay-babu/mason-nvim-dap.nvim",
}

---@param config {args?:string[]|fun():string[]?}
local function get_dbg_args(config)
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
  config = vim.deepcopy(config)
  ---@cast args string[]
  config.args = function()
    local new_args = vim.fn.input("Run with args: ", table.concat(args, " "))
    return vim.split(vim.fn.expand(new_args), " ")
  end
  return config
end

local dap = require "dap"
local dapui = require "dapui"

dapui.setup {
  icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
}

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open {}
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close {}
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close {}
end

require("mason-nvim-dap").setup()
require("nvim-dap-virtual-text").setup {}
vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
vim.fn.sign_define("DapBreakpoint", {
  text = "",
  texthl = "DapBreakpoint",
  linehl = "",
  numhl = "",
})

k.nmap("<F5>", function()
  require("dap").continue()
end, "Debug: Start/Continue")
k.nmap("<C-F5>", function()
  require("dap").continue { before = get_dbg_args }
end, "Debug: Start with args")
k.nmap("<F11>", function()
  require("dap").step_into()
end, "Debug: Step into")
k.nmap("<F10>", function()
  require("dap").step_over()
end, "Debug: Step over")
k.nmap("<C-F10>", function()
  require("dap").run_to_cursor()
end, "Debug: Run to cursor")
k.nmap("<S-F10>", function()
  require("dap").step_out()
end, "Debug: Step out")
k.nmap("<leader>db", function()
  require("dap").toggle_breakpoint()
end, "Toggle breakpoint")
k.nmap("<leader>dB", function()
  dap.set_breakpoint(vim.fn.input "Breakpoint condition: ")
end, "Set conditional breakpoint")
k.nmap("<leader>dt", function()
  require("dap").terminate()
end, "Terminate")
k.nmap("<leader>dr", function()
  require("dap").repl.toggle()
end, "Toggle REPL")