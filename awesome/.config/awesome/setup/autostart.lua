local awful = require("awful")
local function run_once(cmd_arr)
	for _, cmd in ipairs(cmd_arr) do
		awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
	end
end

awful.spawn.with_shell("bright apply")
run_once({ "dbus-update-activation-environment", "--all" })
run_once({ "hsetroot", "-solid", "#000066" })
run_once({ "xcompmgr", "-c", "-C", "-t-5", "-l-5", "-r4.2", "-o.55" })
run_once({ "/usr/lib/xfce-polkit/xfce-polkit" })

-- This function implements the XDG autostart specification
--[[
awful.spawn.with_shell(
    'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
    'xrdb -merge <<< "awesome.started:true";' ..
    -- list each of your autostart commands, followed by ; inside single quotes, followed by ..
    'dex --environment Awesome --autostart --search-paths "$XDG_CONFIG_DIRS/autostart:$XDG_CONFIG_HOME/autostart"' -- https://github.com/jceb/dex
)
--]]
