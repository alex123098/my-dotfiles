-------------------------------------------------
-- Logout Menu Widget for Awesome Window Manager
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/logout-menu-widget

-- @author Pavel Makhov
-- @copyright 2020 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local widget_dir = gears.filesystem.get_configuration_dir() .. "components/logout-widget/"
local icons_dir = widget_dir .. "icons/"

local logout_menu_widget = wibox.widget({
	{
		{
			image = icons_dir .. "power_w.svg",
			resize = true,
			widget = wibox.widget.imagebox,
		},
		margins = 4,
		layout = wibox.container.margin,
	},
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 4)
	end,
	widget = wibox.container.background,
})

local popup = awful.popup({
	ontop = true,
	visible = false,
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, 4)
	end,
	border_width = 1,
	border_color = beautiful.menu_bg_focus,
	maximum_width = 400,
	offset = { y = 5 },
	widget = {},
})

local function worker()
	local rows = { layout = wibox.layout.fixed.vertical }
	local font = beautiful.font
	local menu_items = require("components.logout-widget.menu")

	for _, item in ipairs(menu_items) do
		local row = wibox.widget({
			{
				{
					{
						image = icons_dir .. item.icon_name,
						resize = false,
						widget = wibox.widget.imagebox,
					},
					{
						text = item.name,
						font = font,
						widget = wibox.widget.textbox,
					},
					spacing = 12,
					layout = wibox.layout.fixed.horizontal,
				},
				margins = 8,
				layout = wibox.container.margin,
			},
			bg = beautiful.menu_bg_normal,
			widget = wibox.container.background,
		})

		row:connect_signal("mouse::enter", function(c)
			c:set_bg(beautiful.menu_bg_focus)
      c:set_fg(beautiful.menu_fg_focus)
		end)
		row:connect_signal("mouse::leave", function(c)
			c:set_bg(beautiful.menu_bg_normal)
      c:set_fg(beautiful.meni_fg_normal)
		end)

		row:buttons(awful.util.table.join(awful.button({}, 1, function()
			popup.visible = not popup.visible
			item.command()
		end)))

		table.insert(rows, row)
	end
	popup:setup(rows)

	logout_menu_widget:buttons(awful.util.table.join(awful.button({}, 1, function()
		if popup.visible then
			popup.visible = not popup.visible
		else
			popup:move_next_to(mouse.current_widget_geometry)
			logout_menu_widget:set_bg(beautiful.menu_bg_focus)
		end
	end)))

	return logout_menu_widget
end

return worker
