local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local settings = require("settings")

require("awful.hotkeys_popup.keys")
require("setup.error_handler")
require("setup.autostart")
require("components.brightness")
require("components.volume")
require("setup.layouts")


awful.util.terminal = settings.terminal
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

require("setup.menu")
require("setup.screen")
require("setup.keys")
require("setup.rules")
require("setup.signals")
