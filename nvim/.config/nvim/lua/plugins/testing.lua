local pack = require "fw.pack"
local k = require "fw.keys"

pack.add {
  "nvim-neotest/neotest",
  "andythigpen/nvim-coverage",
}

local oadapters = {}
for _, lang in ipairs(pack.languages()) do
  if lang.test_adapters then
    oadapters = vim.tbl_extend("force", oadapters, lang.test_adapters)
  end
end

local adapters = {}
for name, config in pairs(oadapters) do
  if type(name) == "number" then
    if type(config) == "string" then
      config = require(config)
    end
    adapters[#adapters + 1] = config
  elseif config ~= false then
    local adapter = require(name)
    if type(config) == "table" and not vim.tbl_isempty(config) then
      local meta = getmetatable(adapter)
      if adapter.setup then
        adapter.setup(config)
      elseif adapter.adapter then
        adapter.adapter(config)
        adapter = adapter.adapter
      elseif meta and meta.__call then
        adapter(config)
      else
        error(string.format("Adapter %s does not support setup", name))
      end
    end
    adapters[#adapters + 1] = adapter
  end
end

local neotest = require "neotest"

neotest.setup {
  adapters = adapters,
  status = { virtual_text = true },
  output = { open_on_run = true },
  quickfix = {
    open = function()
      vim.cmd "copen"
    end,
  },
}

require("coverage").setup { auto_reload = true }

k.nmap("<leader>tt", function()
  require("neotest").run.run(vim.fn.expand "%")
end, "Run tests in current file")

k.nmap("<leader>tT", function()
  require("neotest").run.run(vim.uv.cwd())
end, "Run all tests in cwd")

k.nmap("<leader>tr", function()
  require("neotest").run.run()
end, "Run nearest")

k.nmap("<leader>tl", function()
  require("neotest").run.run_last()
end, "Repeat last run")

k.nmap("<leader>ts", function()
  require("neotest").summary.toggle()
end, "Tests summary")

k.nmap("<leader>tS", function()
  require("neotest").run.stop()
end, "Stop test run")

k.nmap("<leader>to", function()
  require("neotest").output_panel.toggle()
end, "Toggle tests output")

k.nmap("<leader>tO", function()
  require("neotest").output.open { enter = true, auto_close = true }
end, "Show tests output")