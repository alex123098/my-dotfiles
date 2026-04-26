local cmd = require "fw.cmds"
local icons = require "mini.icons"
local colors = require("tokyonight.colors").setup()
local colutil = require "tokyonight.util"
local M   = {}

--- @param group string
--- @return string
local function sl_hl(group)
    return "%#" .. group .. "#"
end

--- @param group string
--- @return vim.api.keyset.get_hl_info
local function get_hl(group)
    return vim.api.nvim_get_hl(0, {name = group, link = false, create = false})
end

--- @param glyph string
--- @param hl string
local function hl_icon(glyph, hl)
    return sl_hl(hl) .. glyph .. sl_hl("StatusLine")
end

local function set_hl_groups()
    local dimfg = colutil.blend_fg(get_hl("LineNr").fg, 0.1, colors.fg_sidebar)
    --- @type table<string, vim.api.keyset.highlight>
    local statusline_groups = {
        StatusLineModeNormal = {fg = get_hl("StatusLine").fg, bg = colors.blue7},
        StatusLineModePending = { fg = get_hl("StatusLine").bg, bg = get_hl("Comment").fg },
		StatusLineModeVisual = { fg = get_hl("StatusLine").bg, bg = get_hl("SpecialKey").fg },
		StatusLineModeInsert = { fg = get_hl("StatusLine").bg, bg = get_hl("diffAdded").fg },
		StatusLineModeCommand = { fg = get_hl("StatusLine").bg, bg = get_hl("Number").fg },
		StatusLineModeReplace = { fg = get_hl("StatusLine").bg, bg = get_hl("Constant").fg },
		StatusLineModeOther = { link = "StatusLine" },
		StatusLineBold = { bold = true },
		StatusLineDim = { fg = dimfg },
		StatusLineDimItalic = { fg = dimfg, italic = true },
		StatusLineInverted = { link = "StatusLineModeNormal" },
    }

    for group, opts in pairs(statusline_groups) do
        vim.api.nvim_set_hl(0, group, opts)
    end
end

set_hl_groups()

--- @return number
local function sl_winid()
    return vim.g.statusline_winid or 0
end

--- @return number
local function sl_bufnr()
    return vim.api.nvim_win_get_buf(sl_winid())
end

---@return string
local mode_component = function()
	-- Note that: \19 = ^S and \22 = ^V.
	-- stylua: ignore start
	local mode_settings = {
		["n"]     = { name = "NORMAL",     hl = "Normal" },
		["no"]    = { name = "OP-PENDING", hl = "Pending" },
		["nov"]   = { name = "OP-PENDING", hl = "Pending" },
		["noV"]   = { name = "OP-PENDING", hl = "Pending" },
		["no\22"] = { name = "OP-PENDING", hl = "Pending" },
		["niI"]   = { name = "NORMAL",     hl = "Normal" },
		["niR"]   = { name = "NORMAL",     hl = "Normal" },
		["niV"]   = { name = "NORMAL",     hl = "Normal" },
		["nt"]    = { name = "NORMAL",     hl = "Normal" },
		["ntT"]   = { name = "NORMAL",     hl = "Normal" },
		["v"]     = { name = "VISUAL",     hl = "Visual" },
		["vs"]    = { name = "VISUAL",     hl = "Visual" },
		["V"]     = { name = "V-LINE",     hl = "Visual" },
		["Vs"]    = { name = "V-LINE",     hl = "Visual" },
		["\22"]   = { name = "V-BLOCK",    hl = "Visual" },
		["\22s"]  = { name = "V-BLOCK",    hl = "Visual" },
		["s"]     = { name = "SELECT",     hl = "Insert" },
		["S"]     = { name = "S-LINE",     hl = "Normal" },
		["\19"]   = { name = "S-BLOCK",    hl = "Normal" },
		["i"]     = { name = "INSERT",     hl = "Insert" },
		["ic"]    = { name = "INSERT",     hl = "Insert" },
		["ix"]    = { name = "INSERT",     hl = "Insert" },
		["R"]     = { name = "REPLACE",    hl = "Replace" },
		["Rc"]    = { name = "REPLACE",    hl = "Replace" },
		["Rx"]    = { name = "REPLACE",    hl = "Replace" },
		["Rv"]    = { name = "V-REPLACE",  hl = "Replace" },
		["Rvc"]   = { name = "V-REPLACE",  hl = "Replace" },
		["Rvx"]   = { name = "V-REPLACE",  hl = "Replace" },
		["c"]     = { name = "COMMAND",    hl = "Command" },
		["cv"]    = { name = "EX",         hl = "Command" },
		["ce"]    = { name = "EX",         hl = "Command" },
		["r"]     = { name = "REPLACE",    hl = "Normal" },
		["rm"]    = { name = "MORE",       hl = "Normal" },
		["r?"]    = { name = "CONFIRM",    hl = "Normal" },
		["!"]     = { name = "SHELL",      hl = "Normal" },
		["t"]     = { name = "TERMINAL",   hl = "Command" },
	}
	-- stylua: ignore end

	local settings = mode_settings[vim.api.nvim_get_mode().mode] or {}
	local mode = settings.name or "UNKNOWN"
	local hl = settings.hl or "Other"

	return sl_hl("StatusLineMode" .. hl) .. " " .. mode .. " "
end

cmd.autocmd("User", {
    group = cmd.augroup "sl_gitsigns",
    pattern = "GitSignsUpdate",
    callback = function ()
        vim.api.nvim__redraw({statusline = true})
    end
})

--- @return string?
local function git_component()
    local head = vim.b.gitsigns_head
    if not head or head == "" then
        return
    end

    local icon, hl, _ = icons.get("filetype", "git")
    local component = hl_icon(icon, hl) .. " " .. sl_hl("StatusLine") .. head

    local hunks_cnt = #(require("gitsigns").get_hunks(sl_bufnr()) or {})
    if hunks_cnt > 0 then
        local sfx = hunks_cnt == 1 and "" or "s"
        component = component .. sl_hl("StatusLineDimItalic") .. string.format(" (%d hunk%s)", hunks_cnt, sfx)
    end

    return component
end

local function dap_component()
    if not package.loaded["dap"] or require("dap").status() == "" then
        return
    end

    local icon, _, _ = icons.get("filetype", "dapui_console")
    return string.format("%%#%s#%s %s", "Special", icon, require("dap").status())
end

local lsp_status = {
    --- @type vim.lsp.Client?
    client = nil,
    kind = nil,
    title = nil
}
cmd.autocmd("LspProgress", {
    group = cmd.augroup "statusline_lsp",
    pattern = { "begin", "end" },
    callback = function(args)
        if not args.data then
            return
        end

        lsp_status = {
            client = vim.lsp.get_client_by_id(args.data.client_id),
            kind = args.data.params.value.kind,
            title = args.data.params.value.title,
        }

        if lsp_status.kind == "end" then
            lsp_status.title = nil
            vim.defer_fn(function() vim.api.nvim__redraw { statusline = true } end, 3000)
        else
            vim.api.nvim__redraw { statusline = true }
        end
    end,
})

--- @return string
local function buf_ft()
    local bufnr = sl_bufnr()
    return vim.bo[bufnr].filetype
end

--- @return string?
local function lsp_component()
    -- if no client is attached or client has just been detached, skip
    if not lsp_status.client or not lsp_status.title then
        return
    end

    -- if insert mode, don't refresh anything
    if vim.startswith(vim.api.nvim_get_mode().mode, "i") then
        return
    end

    local cur_icon, hl, _ = icons.get("filetype", buf_ft())

    return hl_icon(cur_icon, hl)
        .. " " .. sl_hl("StatusLineDim")
        .. lsp_status.client.name .. ": "
        .. sl_hl("StatusLineDimItalic")
        .. lsp_status.title
end

--- @return string, number
local function diag_component()
   return vim.diagnostic.status(sl_bufnr()):gsub("%w+:", " %0", 1):gsub("(:%d+)%%", "%1 %%")
end

--- @return string?
local function filetype_component()
    local buf = sl_bufnr()
    local buftype = vim.bo[buf].buftype
    local ft = buf_ft()
    local path = vim.api.nvim_buf_get_name(buf)
    local name = vim.fn.fnamemodify(path, ":t")

    if ft == "" or path == "" then
        return
    end

    local icon, hl, _ = icons.get("filetype", ft)
    local display_name = name == "" and path or name

    if buftype == "terminal" then
        icon, hl, _ = icons.get("filetype", "terminfo")
    end

    return sl_hl(hl) .. icon .. " " .. sl_hl("StatusLineBold") .. display_name
end

--- @return string?
local function modified_component()
    if vim.bo[sl_bufnr()].modified then
        return sl_hl("StatusLineModified") .. "[+]"
    end
end

--- @return string
local function encoding_component()
    local enc = vim.opt.fileencoding:get()
    return enc
end

--- @return string
local function pos_component()
    return sl_hl("StatusLineInverted") .. string.format(" %2d:%-2d ", vim.fn.line("."), vim.fn.virtcol("."))
end

--- @return string
function M.render()
    local is_active = sl_winid() == vim.fn.win_getid()

    if not is_active then
        local file = filetype_component()
        return file and " " .. file or ""
    end

    local components = {
        mode_component(),
        filetype_component(),
        encoding_component(),
        modified_component(),
        " ",
        git_component(),
        "%=",
        dap_component() or lsp_component(),
        diag_component(),
        pos_component(),
    }

    return table.concat(vim.iter(components):flatten():totable(), sl_hl("StatusLine") .. " ")
end

return M