local gap_size = 10

local ipairs = ipairs
local math = math

local gaps = {}

-- @param screen The screen to arrange.
gaps.name = "gaps"
function gaps.arrange(p)
   local wa = p.workarea
   local cls = p.clients

   if #cls > 0 then
      local rows, cols = 0, 0
      if #cls == 2 then
         rows, cols = 1, 2
      else
         rows = math.ceil(math.sqrt(#cls))
         cols = math.ceil(#cls / rows)
      end

      for k, c in ipairs(cls) do
         k = k - 1
         local g = {}

         local row, col = 0, 0
         row = k % rows
         col = math.floor(k / rows)

         local lrows, lcols = 0, 0
         if k >= rows * cols - rows then
            lrows = #cls - (rows * cols - rows)
            lcols = cols
         else
            lrows = rows
            lcols = cols
         end

         if row == lrows - 1 then
            g.height = wa.height - math.ceil(wa.height / lrows) * row
            g.y = wa.height - g.height
         else
            g.height = math.ceil(wa.height / lrows)
            g.y = g.height * row
         end

         if col == lcols - 1 then
            g.width = wa.width - math.ceil(wa.width / lcols) * col
            g.x = wa.width - g.width
         else
            g.width = math.ceil(wa.width / lcols)
            g.x = g.width * col
         end

         g.height = g.height - c.border_width * 2 - 2 * gap_size -- bottom
         g.width = g.width - c.border_width * 2 - 2 * gap_size -- right
         g.y = g.y + wa.y + gap_size -- top
         g.x = g.x + wa.x + gap_size -- left

         c:geometry(g)
      end
   end
end
