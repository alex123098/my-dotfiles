local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local xoffset = dpi(56)
local yoffset = dpi(300)
local screen = awful.screen.focused()
local icons_dir = gears.filesystem.get_configuration_dir() .. "icons/"

local volume_icon = wibox.widget({
	widget = wibox.widget.imagebox,
})

local volume_control = wibox({
	screen = screen,
	x = screen.geometry.width - xoffset,
	y = (screen.geometry.height - yoffset) / 2,
	width = dpi(48),
	height = yoffset,
	shape = gears.shape.rounded_rect,
	visible = false,
	ontop = true,
})

local volume_bar = wibox.widget({
	widget = wibox.widget.progressbar,
	shape = gears.shape.rounded_bar,
	color = "#354e8c",
	background_color = "#3b3b3b",
	max_value = 100,
	value = 0,
})

volume_control:setup({
	layout = wibox.layout.align.vertical,
	wibox.container.margin(volume_icon, dpi(5), dpi(5), dpi(5), dpi(5)),
	{
		wibox.container.margin(volume_bar, dpi(14), dpi(1), dpi(20), dpi(20)),
		focused_height = yoffset * 0.75,
		direction = "east",
		layout = wibox.container.rotate,
	},
})

local hide_widget_timer = gears.timer({
	timeout = 4,
	autostart = true,
	callback = function()
		volume_control.visible = false
	end,
})

awesome.connect_signal("volume_change", function()
	awful.spawn.easy_async_with_shell(
		"amixer sget Master | grep 'Right:' |  awk -F '[][]' '{print $2}' | sed 's/[^0-9]//g'",
		function(stdout)
			local volume_level = tonumber(stdout)
			volume_level = volume_level or 0
			volume_bar.value = volume_level
			if volume_level > 80 then
				volume_icon.image = icons_dir .. "volume-high.png"
			elseif volume_level > 45 then
				volume_icon.image = icons_dir .. "volume-medium.png"
			elseif volume_level > 0 then
				volume_icon.image = icons_dir .. "volume-low.png"
			else
				volume_icon.image = icons_dir .. "volume-muted.png"
			end
		end,
		false
	)

	if volume_control.visible then
		hide_widget_timer:again()
	else
		volume_control.visible = true
		hide_widget_timer:start()
	end
end)
