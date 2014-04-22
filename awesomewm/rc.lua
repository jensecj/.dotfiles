local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")

if awesome.startup_errors then
   naughty.notify({ preset = naughty.config.presets.critical,
                    title = "Oops, there were errors during startup!",
                    text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal("debug::error", function (err)
                             -- Make sure we don't go into an endless error loop
                             if in_error then return end
                             in_error = true

                             naughty.notify({ preset = naughty.config.presets.critical,
                                              title = "Oops, an error happened!",
                                              text = err })
                             in_error = false
   end)
end

beautiful.init(awful.util.getdir("config") .. "/themes/zenburn/theme.lua")

terminal = "urxvt"
browser = "chromium"
editor = "emacs"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"

local layouts =
   {
      awful.layout.suit.fair,
      awful.layout.suit.tile,
   }

if beautiful.wallpaper then
   for s = 1, screen.count() do
      gears.wallpaper.maximized(beautiful.wallpaper, s, true)
   end
end

tags = {}
for s = 1, screen.count() do
   tags[s] = awful.tag({ 1, 2, 3, 4, 5 }, s, layouts[1])
end

menubar.utils.terminal = terminal

-- clock widget
mytextclock = awful.widget.textclock("%d/%m/%y - %H:%M", 31)

-- battery widget
mybattery = wibox.widget.textbox()
vicious.register(mybattery, vicious.widgets.bat, "$2%", 61, "BAT0")

-- volume widget
myvolume = wibox.widget.textbox()
vicious.register(myvolume, vicious.widgets.volume, "$1 $2", 2, "Master -c 1")

-- hdd usage widget
myhdd = wibox.widget.textbox()
vicious.register(myhdd, vicious.widgets.fs, "${/ used_p}%", 59)

-- wifi strength widget
mywifi = wibox.widget.textbox()
vicious.register(mywifi, vicious.widgets.wifi, "${linp}%", 5, "wlp3s0")

-- ram usage widget
myram = wibox.widget.textbox()
vicious.register(myram, vicious.widgets.mem, "$2 MB", 7)

-- cpu usage widget
mycpu = wibox.widget.textbox()
vicious.register(mycpu, vicious.widgets.cpu, "$1%", 3)

-- simple widget seperator
myseperator = wibox.widget.textbox()
myseperator:set_text(" | ")

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(awful.button({ }, 1, awful.tag.viewonly))
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
         if c == client.focus then
            c.minimized = true
         else
            -- Without this, the following :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() then
               awful.tag.viewonly(c:tags()[1])
            end
            -- This will also un-minimize the client, if needed
            client.focus = c
            c:raise()
         end
end))

for s = 1, screen.count() do
   -- Create a promptbox for each screen
   mypromptbox[s] = awful.widget.prompt()

   -- Create a taglist widget
   mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

   -- Create a tasklist widget
   mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

   -- Create the wibox
   mywibox[s] = awful.wibox({ position = "top", screen = s })

   -- Widgets that are aligned to the left
   local left_layout = wibox.layout.fixed.horizontal()
   left_layout:add(mytaglist[s])
   left_layout:add(mypromptbox[s])
   left_layout:add(myseperator)

   -- Widgets that are aligned to the right
   local right_layout = wibox.layout.fixed.horizontal()
   right_layout:add(myseperator)
   if s == 1 then right_layout:add(wibox.widget.systray()) end

   -- add widgets
   right_layout:add(myseperator)
   right_layout:add(wibox.widget.imagebox(beautiful.icon_cpu))
   right_layout:add(mycpu)

   right_layout:add(myseperator)
   right_layout:add(wibox.widget.imagebox(beautiful.icon_ram))
   right_layout:add(myram)

   right_layout:add(myseperator)
   right_layout:add(wibox.widget.imagebox(beautiful.icon_wifi))
   right_layout:add(mywifi)

   right_layout:add(myseperator)
   right_layout:add(wibox.widget.imagebox(beautiful.icon_hdd))
   right_layout:add(myhdd)

   right_layout:add(myseperator)
   right_layout:add(wibox.widget.imagebox(beautiful.icon_volume))
   right_layout:add(myvolume)

   right_layout:add(myseperator)
   right_layout:add(wibox.widget.imagebox(beautiful.icon_battery))
   right_layout:add(mybattery)

   right_layout:add(myseperator)
   right_layout:add(wibox.widget.imagebox(beautiful.icon_timedate))
   right_layout:add(mytextclock)

   -- Now bring it all together (with the tasklist in the middle)
   local layout = wibox.layout.align.horizontal()
   layout:set_left(left_layout)
   layout:set_middle(mytasklist[s])
   layout:set_right(right_layout)

   mywibox[s]:set_widget(layout)
end

globalkeys = awful.util.table.join(
   awful.key({ modkey,           }, "Left",   awful.tag.viewprev),
   awful.key({ modkey,           }, "Right",  awful.tag.viewnext),

   awful.key({ modkey,           }, "j",
      function ()
         awful.client.focus.byidx( 1)
         if client.focus then client.focus:raise() end
   end),
   awful.key({ modkey,           }, "k",
      function ()
         awful.client.focus.byidx(-1)
         if client.focus then client.focus:raise() end
   end),

   -- Brightness
   awful.key({ }, "XF86MonBrightnessUp",   function () awful.util.spawn("xbacklight +10") end),
   awful.key({ }, "XF86MonBrightnessDown", function () awful.util.spawn("xbacklight -10") end),

   -- Sound
   awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -q -c 1 sset Master 5%+") end),
   awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -q -c 1 sset Master 5%-") end),
   awful.key({ }, "XF86AudioMute", function () awful.util.spawn("amixer -q -c 1 sset Master toggle") end),

   -- Layout manipulation
   awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
   awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
   awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
   awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),

   -- Standard program
   awful.key({ modkey,           }, "Return",    function () awful.util.spawn(terminal) end),
   awful.key({ modkey,           }, "BackSpace", function () awful.util.spawn(browser) end),
   awful.key({ modkey,           }, "Delete",    function () awful.util.spawn(editor) end),
   awful.key({ modkey,           }, "F12",    function () awful.util.spawn(terminal .. " -e htop") end),

   awful.key({ modkey, "Control" }, "r", awesome.restart),
   awful.key({ modkey, "Shift"   }, "q", awesome.quit),

   awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
   awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
   awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
   awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
   awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
   awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
   awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
   awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

   -- Prompt
   awful.key({ modkey }, "r",     function () mypromptbox[mouse.screen]:run() end),

   awful.key({ modkey }, "x",
      function ()
         awful.prompt.run({ prompt = "Run Lua code: " },
            mypromptbox[mouse.screen].widget,
            awful.util.eval, nil,
            awful.util.getdir("cache") .. "/history_eval")
   end)
)

clientkeys = awful.util.table.join(
   awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
   awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
   awful.key({ modkey,           }, "n",
      function (c)
         c.minimized = true
   end),
   awful.key({ modkey,           }, "m",
      function (c)
         c.maximized_horizontal = not c.maximized_horizontal
         c.maximized_vertical   = not c.maximized_vertical
   end)
)

for i = 1, 5 do
   globalkeys = awful.util.table.join(globalkeys,
                                      awful.key({ modkey }, "#" .. i + 9,
                                         function ()
                                            local screen = mouse.screen
                                            local tag = awful.tag.gettags(screen)[i]
                                            if tag then
                                               awful.tag.viewonly(tag)
                                            end
                                      end),
                                      awful.key({ modkey, "Control" }, "#" .. i + 9,
                                         function ()
                                            local screen = mouse.screen
                                            local tag = awful.tag.gettags(screen)[i]
                                            if tag then
                                               awful.tag.viewtoggle(tag)
                                            end
                                      end),
                                      awful.key({ modkey, "Shift" }, "#" .. i + 9,
                                         function ()
                                            if client.focus then
                                               local tag = awful.tag.gettags(client.focus.screen)[i]
                                               if tag then
                                                  awful.client.movetotag(tag)
                                               end
                                            end
   end))
end

root.keys(globalkeys)

clientbuttons = {}
awful.rules.rules = {
   { rule = { },
     properties = { border_width = beautiful.border_width,
                    border_color = beautiful.border_normal,
                    focus = awful.client.focus.filter,
                    keys = clientkeys,
                    buttons = clientbuttons,
                    size_hints_honor = false } }
}

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
                         -- Enable sloppy focus
                         c:connect_signal("mouse::enter", function(c)
                                             if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                                             and awful.client.focus.filter(c) then
                                                client.focus = c
                                             end
                         end)

                         if not startup then
                            -- Put windows in a smart way, only if they does not set an initial position.
                            if not c.size_hints.user_position and not c.size_hints.program_position then
                               awful.placement.no_overlap(c)
                               awful.placement.no_offscreen(c)
                            end
                         end
end)
