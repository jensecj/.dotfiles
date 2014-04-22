local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")


-- clock widget
mytextclock = awful.widget.textclock("%d/%m/%y - %H:%M", 30)


-- battery widget
mybattery = wibox.widget.textbox()
updatebattery = function()
   fh = assert(io.popen("acpi | awk '{print $3; print $4}' | tr -d %,", "r"))
   batstat = fh:read("*l")
   batval = fh:read("*l")
   fh:close()

   if batstat == "Charging" then
      mybattery:set_text(batval .. "C")
   else
      mybattery:set_text(batval .. "%")
   end
end

mybattery:set_text("battery | ")
mybatterytimer = timer({ timeout = 60 })
mybatterytimer:connect_signal("timeout", updatebattery)
updatebattery()
mybatterytimer:start()


-- ram usage widget
myram = wibox.widget.textbox()
updateram = function ()
   fh = assert(io.popen("free -m | sed -n 3p | awk '{print $3}'''", "r"))
   value = fh:read("*l")
   fh:close()

   myram:set_text(value .. "MB")
end

myramtimer = timer({ timeout = 5 })
myramtimer:connect_signal("timeout", updateram)
updateram()
myramtimer:start()


-- cpu usage widget
mycpu = wibox.widget.textbox()
updatecpu = function ()
   fh = assert(io.popen("vmstat 1 2 | sed -n 4p | awk '{print $15}'", "r"))
   value = fh:read("*l")
   fh:close()

   actual = 100 - tonumber(value)

   mycpu:set_text(actual .. "%")
end

mycputimer = timer({ timeout = 3 })
mycputimer:connect_signal("timeout", updatecpu)
updatecpu()
mycputimer:start()


-- hdd usage widget
myhdd = wibox.widget.textbox()
updatehdd = function ()
   fh = assert(io.popen("df | sed -n 2p | awk '{print $5}'", "r"))
   usage = fh:read("*l")
   fh:close()

   myhdd:set_text(usage)
end

myhddtimer = timer({ timeout = 300 })
myhddtimer:connect_signal("timeout", updatehdd)
updatehdd()
myhddtimer:start()


-- wifi strength widget
mywifi = wibox.widget.textbox()
updatewifi = function ()
   fh = assert(io.popen("cat /proc/net/wireless | sed -n 3p | awk '{print $3}' | tr -d .", "r"))
   status = fh:read("*l")
   fh:close()

   if status == "" then
      mywifi:set_text("offline")
   else
      mywifi:set_text(status)
   end
end

mywifitimer = timer({ timeout = 3 })
mywifitimer:connect_signal("timeout", updatewifi)
updatewifi()
mywifitimer:start()


-- volume widget
myvolume = wibox.widget.textbox()
updatevolume = function()
   fh = assert(io.popen("amixer -c 1 sget Master | sed -n 5p | awk '{print $4; print $6}' | tr -d []%", "r"))
   value = fh:read("*l")
   status = fh:read("*l")
   fh:close()

   if status == "on" then
      myvolume:set_text(value .. "%")
   else
      myvolume:set_text(value .. "M")
   end
end

updatevolume()
