
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local xoffset = dpi(56)
local yoffset = dpi(300)
local screen = awful.screen.focused()
local icons_dir = gears.filesystem.get_configuration_dir() .. "components/brightness/icons/"

local brightness_icon = wibox.widget({
	widget = wibox.widget.imagebox,
  image = icons_dir .. "bright.svg"
})

local brightness_control = wibox({
	screen = screen,
	x = xoffset,
	y = (screen.geometry.height - yoffset) / 2,
	width = dpi(48),
	height = yoffset,
	shape = gears.shape.rounded_rect,
	visible = false,
	ontop = true,
})

local brightness_bar = wibox.widget({
	widget = wibox.widget.progressbar,
	shape = gears.shape.rounded_bar,
	color = "#354e8c",
	background_color = "#3b3b3b",
	max_value = 100,
	value = 0,
})

brightness_control:setup({
	layout = wibox.layout.align.vertical,
	wibox.container.margin(brightness_icon, dpi(5), dpi(5), dpi(5), dpi(5)),
	{
		wibox.container.margin(brightness_bar, dpi(14), dpi(1), dpi(20), dpi(20)),
		focused_height = yoffset * 0.75,
		direction = "east",
		layout = wibox.container.rotate,
	},
})

local hide_widget_timer = gears.timer({
	timeout = 4,
	autostart = true,
	callback = function()
		brightness_control.visible = false
	end,
})

awesome.connect_signal("brightness_changed", function()
	awful.spawn.easy_async_with_shell(
		"bright",
		function(stdout)
			local brightness_level = tonumber(stdout)
      brightness_level = brightness_level or 0
			brightness_bar.value = brightness_level * 100
		end,
		false
	)

	if brightness_control.visible then
		hide_widget_timer:again()
	else
		brightness_control.visible = true
		hide_widget_timer:start()
	end
end)
