local hotkeys_popup = require("awful.hotkeys_popup")
local awful = require("awful")
local settings = require("settings")
local freedesktop = require("freedesktop")
local beautiful = require("beautiful")

-- Create a launcher widget and a main menu
local myawesomemenu = {
	{
		"Hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "Manual", string.format("%s -e man awesome", settings.terminal) },
	{ "Edit config", string.format("%s -e %s %s", settings.terminal, settings.editor, awesome.conffile) },
	{ "Restart", awesome.restart },
	{
		"Quit",
		function()
			awesome.quit()
		end,
	},
}
local sessionmenu = {}
local widget_menu = require("components.logout-widget.menu")
for _, item in ipairs(widget_menu) do
  table.insert(sessionmenu, { item.name, item.command })
end

awful.util.mymainmenu = freedesktop.menu.build({
	before = {
		{ "Awesome", myawesomemenu, beautiful.awesome_icon },
	},
	after = {
    { "Session", sessionmenu },
		{ "Open terminal", settings.terminal },
	},
})

local menubar = require("menubar")
menubar.utils.terminal = settings.terminal
