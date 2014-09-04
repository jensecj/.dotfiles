local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local vicious = require("vicious")
local base = require("wibox.layout.base")

-- use a sane icon size for notifications
naughty.config.presets.normal.icon_size = 50
naughty.config.presets.low.icon_size = 50
naughty.config.presets.critical.icon_size = 50

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
editor = "em"
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

-- Wraps a widget into a dark colored background
dark_background = function (widget)
   return wibox.widget.background(widget, "#313131")
end

wrap_widget = function (left, widget, right)
   local layout wrapper = wibox.layout.fixed.horizontal()
   wrapper:add(left)
   wrapper:add(widget)
   wrapper:add(right)

   return wrapper
end

-- frequencies for widget updates
local timedate_widget_freq = 31
local battery_widget_freq  = 37
local volume_widget_freq   = 2
local harddisk_widget_freq = 59
local wifi_widget_freq     = 5
local ram_widget_freq      = 7
local cpu_widget_freq      = 3

-- datetime widget
local timedate_widget = awful.widget.textclock("%d/%m/%y - %H:%M", timedate_widget_freq)

-- battery widget
local battery_widget = wibox.widget.textbox()
local battery_warned = false
local battery_warn_level_low = 10
local battery_warn_level_high = 99
vicious.register(battery_widget, vicious.widgets.bat,
                 function(widget, args)
                    if args[2] <= battery_warn_level_low and not battery_warned then
                       naughty.notify({ text = "Low battery!", bg = "#D95D5D", timeout = 30, height = 50 })
                       battery_warned = true
                    elseif args[2] >= battery_warn_level_high and not battery_warned then
                       naughty.notify({ text = "Full battery!", bg = "#D95D5D", timeout = 30, height = 50 })
                       battery_warned = true
                    elseif args[2] > battery_warn_level_low and battery_warned
                    then battery_warned = false
                    end
                    return args[2] .. args[1]
                 end
                 , battery_widget_freq, "BAT0")

-- volume widget
local volume_widget = wibox.widget.textbox()
vicious.register(volume_widget, vicious.widgets.volume,
                 function(widget, args)
                    local label = { ["♫"] = "", ["♩"] = "M" }
                    return args[1] .. label[args[2]]
                 end, volume_widget_freq, "Master -c 1")

-- hdd usage widget
local harddisk_widget = wibox.widget.textbox()
vicious.register(harddisk_widget, vicious.widgets.fs, "${/ used_p}", harddisk_widget_freq)

-- wifi strength widget
local wifi_widget = wibox.widget.textbox()
vicious.register(wifi_widget, vicious.widgets.wifi, "${linp}", wifi_widget_freq, "wlp3s0")

-- ram usage widget
local ram_widget = wibox.widget.textbox()
vicious.register(ram_widget, vicious.widgets.mem, "$1", ram_widget_freq)

-- cpu usage widget
local cpu_widget = wibox.widget.textbox()
vicious.register(cpu_widget, vicious.widgets.cpu,
                 function (widget, args)
                    if args[1] < 10 then
                       return "0" .. args[1]
                    else
                       return args[1]
                    end
                 end, cpu_widget_freq)

-- simple widget separator
local separator_widget = wibox.widget.textbox()
separator_widget:set_text(" ")

-- arrow separators, notation is from left to right,
-- ld means going from light to dark, and vice versa
local arrow_left = wibox.widget.imagebox()
arrow_left:set_image(beautiful.arrow_left)

local arrow_left_dl = wibox.widget.imagebox()
arrow_left_dl:set_image(beautiful.arrow_left_dl)

local arrow_left_ld = wibox.widget.imagebox()
arrow_left_ld:set_image(beautiful.arrow_left_ld)

local arrow_right = wibox.widget.imagebox()
arrow_right:set_image(beautiful.arrow_right)

local arrow_right_dl = wibox.widget.imagebox()
arrow_right_dl:set_image(beautiful.arrow_right_dl)

local arrow_right_ld = wibox.widget.imagebox()
arrow_right_ld:set_image(beautiful.arrow_right_ld)

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mytaglist = {}
mytasklist = {}

for s = 1, screen.count() do
   -- Create a promptbox for each screen
   mypromptbox[s] = awful.widget.prompt()

   -- Create a taglist widget
   mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

   -- Create a tasklist widget
   mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

   -- Create the wibox
   mywibox[s] = awful.wibox({ position = "top", height = "18", screen = s })

   -- Widgets that are aligned to the left
   local left_layout = wibox.layout.fixed.horizontal()
   left_layout:add(mytaglist[s])

   left_layout:add(wrap_widget(
                      arrow_right_ld,
                      dark_background(wrap_widget(
                                         separator_widget,
                                         mypromptbox[s],
                                         separator_widget)),
                      arrow_right_dl))

   -- Widgets that are aligned to the center
   local middle_layout = wibox.layout.fixed.horizontal()

   middle_layout:add(separator_widget)
   middle_layout:add(separator_widget)

   middle_layout:add(wibox.widget.imagebox(beautiful.icon_cpu))
   middle_layout:add(cpu_widget)

   middle_layout:add(separator_widget)

   middle_layout:add(wibox.widget.imagebox(beautiful.icon_ram))
   middle_layout:add(ram_widget)

   middle_layout:add(separator_widget)

   middle_layout:add(wibox.widget.imagebox(beautiful.icon_hdd))
   middle_layout:add(harddisk_widget)

   middle_layout:add(separator_widget)

   middle_layout:add(wibox.widget.imagebox(beautiful.icon_wifi))
   middle_layout:add(wifi_widget)

   middle_layout:add(separator_widget)

   middle_layout:add(wibox.widget.imagebox(beautiful.icon_volume))
   middle_layout:add(volume_widget)

   middle_layout:add(separator_widget)

   middle_layout:add(wibox.widget.imagebox(beautiful.icon_battery))
   middle_layout:add(battery_widget)

   middle_layout:add(separator_widget)
   middle_layout:add(separator_widget)

   -- Widgets that are aligned to the right
   local right_layout = wibox.layout.fixed.horizontal()

   right_layout:add(wrap_widget(
                       arrow_left_ld,
                       dark_background(wrap_widget(
                                          separator_widget,
                                          wibox.widget.systray(),
                                          separator_widget)),
                       arrow_left_dl))

   right_layout:add(wibox.widget.imagebox(beautiful.icon_timedate))
   right_layout:add(timedate_widget)

   -- Now bring it all together
   local layout =  setmetatable({}, {__index = wibox.layout.align.horizontal()})

   -- Create a layout that gives the center widget priority
   function layout:draw(wibox, cr, width, height)
      local size_first = 0
      local size_third = 0
      local size_limit = width

      if self.first then
         local w, h, _ = width, height, nil

         w, _ = base.fit_widget(self.first, w, h)
         size_first = w

         base.draw_widget(wibox, cr, self.first, 0, 0, w, h)
      end

      if self.third and size_first < size_limit then
         local w, h, x, y, _

         w, h = width - size_first, height
         w, _ = base.fit_widget(self.third, w, h)
         x, y = width - w, 0
         size_third = w

         base.draw_widget(wibox, cr, self.third, x, y, w, h)
      end

      if self.second and size_first + size_third < size_limit then
         local x, y, w, h

         w, h = size_limit - size_first - size_third, height
         local real_w, real_h = base.fit_widget(self.second, w, h)
         x, y = width / 2 - real_w / 2, 0
         w = real_w

         base.draw_widget(wibox, cr, self.second, x, y, w, h)
      end
   end

   layout:set_left(left_layout)
   layout:set_middle(wrap_widget(arrow_left_ld, dark_background(middle_layout), arrow_right_dl))
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
   awful.key({                   }, "Print",    function () awful.util.spawn("scrot '%Y-%m-%d_%H-%M-%S_$wx$h.png' -e 'mv $f ~/Dropbox/Screenshots'") end),
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
   awful.key({ modkey, "Shift"   }, "c", function (c) c:kill() end),
   awful.key({ modkey, }, "f", function(c) c.fullscreen = not c.fullscreen end),
   awful.key({ modkey, }, "g", awful.client.floating.toggle),
   awful.key({ modkey,           }, "m",
      function (c)
         local tag = awful.tag.selected()
         for i = 1, #tag:clients() do
            if (c ~= tag:clients()[i]) then
               tag:clients()[i].maximized_horizontal = false
               tag:clients()[i].maximized_vertical = false
            end
         end

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
