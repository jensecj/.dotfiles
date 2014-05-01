local base = require("wibox.layout.base")

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
