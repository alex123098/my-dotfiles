local awful = require("awful")
local gears = require("gears")

local widget_dir = gears.filesystem.get_configuration_dir() .. "components/logout-widget/"

local onlogout = function()
  awesome.quit()
end
local onlock = function()
  awful.spawn.with_shell("sh " .. widget_dir .. "lockscreen.sh")
end
local onreboot = function()
  awful.spawn.with_shell("reboot")
end
local onsuspend = function()
  awful.spawn.with_shell("systemctl suspend")
end
local onpoweroff = function()
  awful.spawn.with_shell("shutdown now")
end

return {
  { name = "Log out", icon_name = "log-out.svg", command = onlogout },
  { name = "Lock", icon_name = "lock.svg", command = onlock },
  { name = "Reboot", icon_name = "refresh-cw.svg", command = onreboot },
  { name = "Suspend", icon_name = "moon.svg", command = onsuspend },
  { name = "Power off", icon_name = "power.svg", command = onpoweroff },
}
