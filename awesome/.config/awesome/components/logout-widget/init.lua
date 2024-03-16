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

local function worker(user_args)
	local rows = { layout = wibox.layout.fixed.vertical }

	local args = user_args or {}

	local font = args.font or beautiful.font

	local onlogout = args.onlogout or function()
		awesome.quit()
	end
	local onlock = args.onlock
		or function()
			awful.spawn.with_shell("sh " .. widget_dir .. "lockscreen.sh")
		end
	local onreboot = args.onreboot or function()
		awful.spawn.with_shell("reboot")
	end
	local onsuspend = args.onsuspend or function()
		awful.spawn.with_shell("systemctl suspend")
	end
	local onpoweroff = args.onpoweroff or function()
		awful.spawn.with_shell("shutdown now")
	end

	local menu_items = {
		{ name = "Log out", icon_name = "log-out.svg", command = onlogout },
		{ name = "Lock", icon_name = "lock.svg", command = onlock },
		{ name = "Reboot", icon_name = "refresh-cw.svg", command = onreboot },
		{ name = "Suspend", icon_name = "moon.svg", command = onsuspend },
		{ name = "Power off", icon_name = "power.svg", command = onpoweroff },
	}

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
