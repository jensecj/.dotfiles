-- minimal osc based on vanilla mpv osc
-- only ui remaining is the bottombar - which has had most ui elements removed
-- also removed: window controls, seekbar styles, animations, idle, most user options,
-- added: thumbnails via thumbfast

local assdraw = require 'mp.assdraw'
local msg = require 'mp.msg'
local opt = require 'mp.options'
local utils = require 'mp.utils'

--
-- Parameters
--
-- default user option values
-- do not touch, change them in osc.conf
local user_opts = {
   showwindowed = true,        -- show OSC when windowed?
   showfullscreen = true,      -- show OSC when fullscreen?
   scalewindowed = 1,          -- scaling of the controller when windowed
   scalefullscreen = 1,        -- scaling of the controller when fullscreen
   scaleforcedwindow = 2,      -- scaling when rendered on a forced window
   vidscale = true,            -- scale the controller with the video?
   valign = 0.8,               -- vertical alignment, -1 (top) to 1 (bottom)
   halign = 0,                 -- horizontal alignment, -1 (left) to 1 (right)
   barmargin = 0,              -- vertical margin of top/bottombar
   boxalpha = 80,              -- alpha of the background box,
   -- 0 (opaque) to 255 (fully transparent)
   hidetimeout = 500,          -- duration in ms until the OSC hides if no
   -- mouse movement. enforced non-negative for the
   -- user, but internally negative is "always-on".
   deadzonesize = 0.5,         -- size of deadzone, float percentage from 0.0 - 1.0
   minmousemove = 0,           -- minimum amount of pixels the mouse has to move between ticks to make the OSC show up
   -- internal track list management (and some functions that depend on it)
   seekbarkeyframes = true,    -- use keyframes when dragging the seekbar
   title = "${media-title}",   -- string compatible with property-expansion
   -- to be shown as OSC title
   tooltipborder = 1,          -- border of tooltip in bottom/topbar
   tcspace = 100,              -- timecode spacing (compensate font size estimation)
   visibility = "auto",        -- only used at init to set visibility_mode(...)
   boxmaxchars = 80,           -- title crop threshold for box layout
   livemarkers = true,         -- update seekbar chapter markers on duration change
   chapters_osd = true,        -- whether to show chapters OSD on next/prev
   playlist_osd = true,        -- whether to show playlist OSD on next/prev
   chapter_fmt = "%s", -- chapter print format for seekbar-hover. "no" to disable
}

-- read options from config and command-line
opt.read_options(user_opts, "osc", function(list) update_options(list) end)

local osc_param = { -- calculated by osc_init()
   playresy = 0,                           -- canvas size Y
   playresx = 0,                           -- canvas size X
   display_aspect = 1,
   unscaled_y = 0,
   areas = {},
   video_margins = {
      l = 0, r = 0, t = 0, b = 0,         -- left/right/top/bottom
   },
}

local osc_styles = {
   box = "{\\rDefault\\blur0\\bord1\\1c&H000000\\3c&HFFFFFF}",

   timecodes = "{\\blur0\\bord0\\1c&HFFFFFF\\3c&HFFFFFF\\fs27}",
   timepos = "{\\blur0\\bord".. user_opts.tooltipborder .."\\1c&HFFFFFF\\3c&H000000\\fs30}",
   vidtitle = "{\\blur0\\bord0\\1c&HFFFFFF\\3c&HFFFFFF\\fs18\\q2}"
}

-- internal states, do not touch
local state = {
   showtime,                               -- time of last invocation (last mouse move)
   osc_visible = false,
   mouse_down_counter = 0,                 -- used for softrepeat
   active_element = nil,                   -- nil = none, 0 = background, 1+ = see elements[]
   active_event_source = nil,              -- the "button" that issued the current event
   mp_screen_sizeX, mp_screen_sizeY,       -- last screen-resolution, to detect resolution changes to issue reINITs
   initREQ = false,                        -- is a re-init request pending?
   marginsREQ = false,                     -- is a margins update pending?
   last_mouseX, last_mouseY,               -- last mouse position, to detect significant mouse movement
   mouse_in_window = false,
   message_text,
   message_hide_timer,
   fullscreen = false,
   tick_timer = nil,
   tick_last_time = 0,                     -- when the last tick() was run
   hide_timer = nil,
   cache_state = nil,
   enabled = true,
   input_enabled = true,
   showhide_enabled = false,
   dmx_cache = 0,
   using_video_margins = false,
   border = true,
   maximized = false,
   osd = mp.create_osd_overlay("ass-events"),
   chapter_list = {},                      -- sorted by time
}

local thumbfast = {
   width = 0,
   height = 0,
   disabled = false
}

local tick_delay = 0.03

--
-- Helperfunctions
--

function set_osd(res_x, res_y, text)
   if state.osd.res_x == res_x and
      state.osd.res_y == res_y and
      state.osd.data == text then
      return
   end
   state.osd.res_x = res_x
   state.osd.res_y = res_y
   state.osd.data = text
   state.osd.z = 1000
   state.osd:update()
end

local margins_opts = {
   {"l", "video-margin-ratio-left"},
   {"r", "video-margin-ratio-right"},
   {"t", "video-margin-ratio-top"},
   {"b", "video-margin-ratio-bottom"},
}

-- scale factor for translating between real and virtual ASS coordinates
function get_virt_scale_factor()
   local w, h = mp.get_osd_size()
   if w <= 0 or h <= 0 then
      return 0, 0
   end
   return osc_param.playresx / w, osc_param.playresy / h
end

-- return mouse position in virtual ASS coordinates (playresx/y)
function get_virt_mouse_pos()
   if state.mouse_in_window then
      local sx, sy = get_virt_scale_factor()
      local x, y = mp.get_mouse_pos()
      return x * sx, y * sy
   else
      return -1, -1
   end
end

function set_virt_mouse_area(x0, y0, x1, y1, name)
   local sx, sy = get_virt_scale_factor()
   mp.set_mouse_area(x0 / sx, y0 / sy, x1 / sx, y1 / sy, name)
end

function scale_value(x0, x1, y0, y1, val)
   local m = (y1 - y0) / (x1 - x0)
   local b = y0 - (m * x0)
   return (m * val) + b
end

-- returns hitbox spanning coordinates (top left, bottom right corner)
-- according to alignment
function get_hitbox_coords(x, y, an, w, h)

   local alignments = {
      [1] = function () return x, y-h, x+w, y end,
      [2] = function () return x-(w/2), y-h, x+(w/2), y end,
      [3] = function () return x-w, y-h, x, y end,

      [4] = function () return x, y-(h/2), x+w, y+(h/2) end,
      [5] = function () return x-(w/2), y-(h/2), x+(w/2), y+(h/2) end,
      [6] = function () return x-w, y-(h/2), x, y+(h/2) end,

      [7] = function () return x, y, x+w, y+h end,
      [8] = function () return x-(w/2), y, x+(w/2), y+h end,
      [9] = function () return x-w, y, x, y+h end,
   }

   return alignments[an]()
end

function get_hitbox_coords_geo(geometry)
   return get_hitbox_coords(geometry.x, geometry.y, geometry.an,
                            geometry.w, geometry.h)
end

function get_element_hitbox(element)
   return element.hitbox.x1, element.hitbox.y1,
      element.hitbox.x2, element.hitbox.y2
end

function mouse_hit(element)
   return mouse_hit_coords(get_element_hitbox(element))
end

function mouse_hit_coords(bX1, bY1, bX2, bY2)
   local mX, mY = get_virt_mouse_pos()
   return (mX >= bX1 and mX <= bX2 and mY >= bY1 and mY <= bY2)
end

function limit_range(min, max, val)
   if val > max then
      val = max
   elseif val < min then
      val = min
   end
   return val
end

-- translate value into element coordinates
function get_slider_ele_pos_for(element, val)

   local ele_pos = scale_value(
      element.slider.min.value, element.slider.max.value,
      element.slider.min.ele_pos, element.slider.max.ele_pos,
      val)

   return limit_range(
      element.slider.min.ele_pos, element.slider.max.ele_pos,
      ele_pos)
end

-- translates global (mouse) coordinates to value
function get_slider_value_at(element, glob_pos)

   local val = scale_value(
      element.slider.min.glob_pos, element.slider.max.glob_pos,
      element.slider.min.value, element.slider.max.value,
      glob_pos)

   return limit_range(
      element.slider.min.value, element.slider.max.value,
      val)
end

-- get value at current mouse position
function get_slider_value(element)
   return get_slider_value_at(element, get_virt_mouse_pos())
end

-- align:  -1 .. +1
-- frame:  size of the containing area
-- obj:    size of the object that should be positioned inside the area
-- margin: min. distance from object to frame (as long as -1 <= align <= +1)
function get_align(align, frame, obj, margin)
   return (frame / 2) + (((frame / 2) - margin - (obj / 2)) * align)
end

-- multiplies two alpha values, formular can probably be improved
function mult_alpha(alphaA, alphaB)
   return 255 - (((1-(alphaA/255)) * (1-(alphaB/255))) * 255)
end

function add_area(name, x1, y1, x2, y2)
   -- create area if needed
   if (osc_param.areas[name] == nil) then
      osc_param.areas[name] = {}
   end
   table.insert(osc_param.areas[name], {x1=x1, y1=y1, x2=x2, y2=y2})
end

function ass_append_alpha(ass, alpha, modifier)
   local ar = {}

   for ai, av in pairs(alpha) do
      av = mult_alpha(av, modifier)
      ar[ai] = av
   end

   ass:append(string.format("{\\1a&H%X&\\2a&H%X&\\3a&H%X&\\4a&H%X&}",
                            ar[1], ar[2], ar[3], ar[4]))
end

function ass_draw_rr_h_cw(ass, x0, y0, x1, y1, r1, r2)
   ass:round_rect_cw(x0, y0, x1, y1, r1, r2)
end

function ass_draw_rr_h_ccw(ass, x0, y0, x1, y1, r1, r2)
   ass:round_rect_ccw(x0, y0, x1, y1, r1, r2)
end


--
-- Tracklist Management
--

local nicetypes = {video = "Video", audio = "Audio", sub = "Subtitle"}

-- updates the OSC internal playlists, should be run each time the track-layout changes
function update_tracklist()
   local tracktable = mp.get_property_native("track-list", {})

   -- by osc_id
   tracks_osc = {}
   tracks_osc.video, tracks_osc.audio, tracks_osc.sub = {}, {}, {}
   -- by mpv_id
   tracks_mpv = {}
   tracks_mpv.video, tracks_mpv.audio, tracks_mpv.sub = {}, {}, {}
   for n = 1, #tracktable do
      if not (tracktable[n].type == "unknown") then
         local type = tracktable[n].type
         local mpv_id = tonumber(tracktable[n].id)

         -- by osc_id
         table.insert(tracks_osc[type], tracktable[n])

         -- by mpv_id
         tracks_mpv[type][mpv_id] = tracktable[n]
         tracks_mpv[type][mpv_id].osc_id = #tracks_osc[type]
      end
   end
end

-- return a nice list of tracks of the given type (video, audio, sub)
function get_tracklist(type)
   local msg = "Available " .. nicetypes[type] .. " Tracks: "
   if not tracks_osc or #tracks_osc[type] == 0 then
      msg = msg .. "none"
   else
      for n = 1, #tracks_osc[type] do
         local track = tracks_osc[type][n]
         local lang, title, selected = "unknown", "", "○"
         if not(track.lang == nil) then lang = track.lang end
         if not(track.title == nil) then title = track.title end
         if (track.id == tonumber(mp.get_property(type))) then
            selected = "●"
         end
         msg = msg.."\n"..selected.." "..n..": ["..lang.."] "..title
      end
   end
   return msg
end

-- relatively change the track of given <type> by <next> tracks
--(+1 -> next, -1 -> previous)
function set_track(type, next)
   local current_track_mpv, current_track_osc
   if (mp.get_property(type) == "no") then
      current_track_osc = 0
   else
      current_track_mpv = tonumber(mp.get_property(type))
      current_track_osc = tracks_mpv[type][current_track_mpv].osc_id
   end
   local new_track_osc = (current_track_osc + next) % (#tracks_osc[type] + 1)
   local new_track_mpv
   if new_track_osc == 0 then
      new_track_mpv = "no"
   else
      new_track_mpv = tracks_osc[type][new_track_osc].id
   end

   mp.commandv("set", type, new_track_mpv)

   if (new_track_osc == 0) then
      show_message(nicetypes[type] .. " Track: none")
   else
      show_message(nicetypes[type]  .. " Track: "
                   .. new_track_osc .. "/" .. #tracks_osc[type]
                   .. " [".. (tracks_osc[type][new_track_osc].lang or "unknown") .."] "
                   .. (tracks_osc[type][new_track_osc].title or ""))
   end
end

-- get the currently selected track of <type>, OSC-style counted
function get_track(type)
   local track = mp.get_property(type)
   if track ~= "no" and track ~= nil then
      local tr = tracks_mpv[type][tonumber(track)]
      if tr then
         return tr.osc_id
      end
   end
   return 0
end

--
-- Element Management
--

local elements = {}

function prepare_elements()

   -- remove elements without layout or invisble
   local elements2 = {}
   for n, element in pairs(elements) do
      if not (element.layout == nil) and (element.visible) then
         table.insert(elements2, element)
      end
   end
   elements = elements2

   function elem_compare (a, b)
      return a.layout.layer < b.layout.layer
   end

   table.sort(elements, elem_compare)


   for _,element in pairs(elements) do

      local elem_geo = element.layout.geometry

      -- Calculate the hitbox
      local bX1, bY1, bX2, bY2 = get_hitbox_coords_geo(elem_geo)
      element.hitbox = {x1 = bX1, y1 = bY1, x2 = bX2, y2 = bY2}

      local style_ass = assdraw.ass_new()

      -- prepare static elements
      style_ass:append("{}") -- hack to troll new_event into inserting a \n
      style_ass:new_event()
      style_ass:pos(elem_geo.x, elem_geo.y)
      style_ass:an(elem_geo.an)
      style_ass:append(element.layout.style)

      element.style_ass = style_ass

      local static_ass = assdraw.ass_new()


      if (element.type == "box") then
         --draw box
         static_ass:draw_start()
         ass_draw_rr_h_cw(static_ass, 0, 0, elem_geo.w, elem_geo.h,
                          element.layout.box.radius)
         static_ass:draw_stop()

      elseif (element.type == "slider") then
         --draw static slider parts

         local r1 = 0
         local r2 = 0
         local slider_lo = element.layout.slider
         -- offset between element outline and drag-area
         local foV = slider_lo.border + slider_lo.gap

         -- calculate positions of min and max points
         element.slider.min.ele_pos =
            slider_lo.border + slider_lo.gap
         element.slider.max.ele_pos =
            elem_geo.w - (slider_lo.border + slider_lo.gap)

         element.slider.min.glob_pos =
            element.hitbox.x1 + element.slider.min.ele_pos
         element.slider.max.glob_pos =
            element.hitbox.x1 + element.slider.max.ele_pos

         -- -- --

         static_ass:draw_start()

         -- the box
         ass_draw_rr_h_cw(static_ass, 0, 0, elem_geo.w, elem_geo.h, r1)

         -- the "hole"
         ass_draw_rr_h_ccw(static_ass, slider_lo.border, slider_lo.border,
                           elem_geo.w - slider_lo.border, elem_geo.h - slider_lo.border,
                           r2)

         -- marker nibbles
         if not (element.slider.markerF == nil) and (slider_lo.gap > 0) then
            local markers = element.slider.markerF()
            for _,marker in pairs(markers) do
               if (marker > element.slider.min.value) and
                  (marker < element.slider.max.value) then

                  local s = get_slider_ele_pos_for(element, marker)

                  if (slider_lo.gap > 1) then -- draw triangles

                     local a = slider_lo.gap / 0.5 --0.866

                     --top
                     if (slider_lo.nibbles_top) then
                        static_ass:move_to(s - (a/2), slider_lo.border)
                        static_ass:line_to(s + (a/2), slider_lo.border)
                        static_ass:line_to(s, foV)
                     end

                     --bottom
                     if (slider_lo.nibbles_bottom) then
                        static_ass:move_to(s - (a/2),
                                           elem_geo.h - slider_lo.border)
                        static_ass:line_to(s,
                                           elem_geo.h - foV)
                        static_ass:line_to(s + (a/2),
                                           elem_geo.h - slider_lo.border)
                     end

                  else -- draw 2x1px nibbles

                     --top
                     if (slider_lo.nibbles_top) then
                        static_ass:rect_cw(s - 1, slider_lo.border,
                                           s + 1, slider_lo.border + slider_lo.gap);
                     end

                     --bottom
                     if (slider_lo.nibbles_bottom) then
                        static_ass:rect_cw(s - 1,
                                           elem_geo.h -slider_lo.border -slider_lo.gap,
                                           s + 1, elem_geo.h - slider_lo.border);
                     end
                  end
               end
            end
         end
      end

      element.static_ass = static_ass


      -- if the element is supposed to be disabled,
      -- style it accordingly and kill the eventresponders
      if not (element.enabled) then
         element.layout.alpha[1] = 136
         element.eventresponder = nil
      end
   end
end


--
-- Element Rendering
--

-- returns nil or a chapter element from the native property chapter-list
function get_chapter(possec)
   local cl = state.chapter_list  -- sorted, get latest before possec, if any

   for n=#cl,1,-1 do
      if possec >= cl[n].time then
         return cl[n]
      end
   end
end

function render_elements(master_ass)

   -- when the slider is dragged or hovered and we have a target chapter name
   -- then we use it instead of the normal title. we calculate it before the
   -- render iterations because the title may be rendered before the slider.
   state.forced_title = nil
   local se, ae = state.slider_element, elements[state.active_element]
   if user_opts.chapter_fmt ~= "no" and se and (ae == se or (not ae and mouse_hit(se))) then
      local dur = mp.get_property_number("duration", 0)
      if dur > 0 then
         local possec = get_slider_value(se) * dur / 100 -- of mouse pos
         local ch = get_chapter(possec)
         if ch and ch.title and ch.title ~= "" then
            state.forced_title = string.format(user_opts.chapter_fmt, ch.title)
         end
      end
   end

   for n=1, #elements do
      local element = elements[n]

      local style_ass = assdraw.ass_new()
      style_ass:merge(element.style_ass)
      ass_append_alpha(style_ass, element.layout.alpha, 0)

      if element.eventresponder and (state.active_element == n) then

         -- run render event functions
         if not (element.eventresponder.render == nil) then
            element.eventresponder.render(element)
         end

      end

      local elem_ass = assdraw.ass_new()

      elem_ass:merge(style_ass)

      if not (element.type == "button") then
         elem_ass:merge(element.static_ass)
      end

      if (element.type == "slider") then

         local slider_lo = element.layout.slider
         local elem_geo = element.layout.geometry
         local s_min = element.slider.min.value
         local s_max = element.slider.max.value

         -- draw pos marker
         local foH, xp
         local pos = element.slider.posF()
         local foV = slider_lo.border + slider_lo.gap
         local innerH = elem_geo.h - (2 * foV)
         local seekRanges = element.slider.seekRangesF()
         local seekRangeLineHeight = innerH / 5

         foH = slider_lo.border + slider_lo.gap

         if pos then
            xp = get_slider_ele_pos_for(element, pos)

            elem_ass:rect_cw(foH, foV, xp, elem_geo.h - foV)
         end

         if seekRanges then
            for _,range in pairs(seekRanges) do
               local pstart = get_slider_ele_pos_for(element, range["start"])
               local pend = get_slider_ele_pos_for(element, range["end"])

               -- stype = bar, rtype = inverted
               elem_ass:rect_ccw(pstart, (elem_geo.h / 2) - 1, pend, (elem_geo.h / 2) + 1)
            end
         end

         elem_ass:draw_stop()

         -- add tooltip
         if not (element.slider.tooltipF == nil) then

            if mouse_hit(element) then
               local sliderpos = get_slider_value(element)
               local tooltiplabel = element.slider.tooltipF(sliderpos)

               local an = slider_lo.tooltip_an

               local ty

               if (an == 2) then
                  ty = element.hitbox.y1 - slider_lo.border
               else
                  ty = element.hitbox.y1 + elem_geo.h/2
               end

               local tx = get_virt_mouse_pos()
               local thumb_tx = tx
               if (slider_lo.adjust_tooltip) then
                  if (an == 2) then
                     if (sliderpos < (s_min + 3)) then
                        an = an - 1
                     elseif (sliderpos > (s_max - 3)) then
                        an = an + 1
                     end
                  elseif (sliderpos > (s_max-s_min)/2) then
                     an = an + 1
                     tx = tx - 5
                  else
                     an = an - 1
                     tx = tx + 10
                  end
               end

               -- tooltip label
               elem_ass:new_event()
               elem_ass:pos(tx, ty)
               elem_ass:an(an)
               elem_ass:append(slider_lo.tooltip_style)
               ass_append_alpha(elem_ass, slider_lo.alpha, 0)
               elem_ass:append(tooltiplabel)

               -- thumbnail
               if not thumbfast.disabled and thumbfast.width ~= 0 and thumbfast.height ~= 0 then
                  local osd_w = mp.get_property_number("osd-width")
                  if osd_w then
                     local r_w, r_h = get_virt_scale_factor()

                     local tooltip_font_size = 12
                     local thumb_ty = element.hitbox.y1 - 8

                     local thumb_pad = 2
                     local thumb_margin_x = 20 / r_w
                     local thumb_margin_y = (4 + user_opts.tooltipborder) / r_h + thumb_pad
                     local thumb_x = math.min(osd_w - thumbfast.width - thumb_margin_x, math.max(thumb_margin_x, thumb_tx / r_w - thumbfast.width / 2))
                     local thumb_y = thumb_ty / r_h - thumbfast.height - tooltip_font_size / r_h - thumb_margin_y or thumb_ty / r_h + thumb_margin_y

                     thumb_x = math.floor(thumb_x + 0.5)
                     thumb_y = math.floor(thumb_y + 0.5)

                     elem_ass:new_event()
                     elem_ass:pos(thumb_x * r_w, thumb_y * r_h)
                     elem_ass:append(osc_styles.timepos)
                     elem_ass:append("{\\1a&H20&}")
                     elem_ass:draw_start()
                     elem_ass:rect_cw(-thumb_pad * r_w, -thumb_pad * r_h, (thumbfast.width + thumb_pad) * r_w, (thumbfast.height + thumb_pad) * r_h)
                     elem_ass:draw_stop()

                     mp.commandv("script-message-to", "thumbfast", "thumb",
                                 mp.get_property_number("duration", 0) * (sliderpos / 100),
                                 thumb_x,
                                 thumb_y
                     )
                  end
               end
            else
               if thumbfast.width ~= 0 and thumbfast.height ~= 0 then
                  mp.commandv("script-message-to", "thumbfast", "clear")
               end
            end
         end

      elseif (element.type == "button") then

         local buttontext
         if type(element.content) == "function" then
            buttontext = element.content() -- function objects
         elseif not (element.content == nil) then
            buttontext = element.content -- text objects
         end

         local maxchars = element.layout.button.maxchars
         if not (maxchars == nil) and (#buttontext > maxchars) then
            local max_ratio = 1.25  -- up to 25% more chars while shrinking
            local limit = math.max(0, math.floor(maxchars * max_ratio) - 3)
            if (#buttontext > limit) then
               while (#buttontext > limit) do
                  buttontext = buttontext:gsub(".[\128-\191]*$", "")
               end
               buttontext = buttontext .. "..."
            end
            local _, nchars2 = buttontext:gsub(".[\128-\191]*", "")
            local stretch = (maxchars/#buttontext)*100
            buttontext = string.format("{\\fscx%f}",
                                       (maxchars/#buttontext)*100) .. buttontext
         end

         elem_ass:append(buttontext)
      end

      master_ass:merge(elem_ass)
   end
end

--
-- Message display
--

-- pos is 1 based
function limited_list(prop, pos)
   local proplist = mp.get_property_native(prop, {})
   local count = #proplist
   if count == 0 then
      return count, proplist
   end

   local fs = tonumber(mp.get_property('options/osd-font-size'))
   local max = math.ceil(osc_param.unscaled_y*0.75 / fs)
   if max % 2 == 0 then
      max = max - 1
   end
   local delta = math.ceil(max / 2) - 1
   local begi = math.max(math.min(pos - delta, count - max + 1), 1)
   local endi = math.min(begi + max - 1, count)

   local reslist = {}
   for i=begi, endi do
      local item = proplist[i]
      item.current = (i == pos) and true or nil
      table.insert(reslist, item)
   end
   return count, reslist
end

function get_playlist()
   local pos = mp.get_property_number('playlist-pos', 0) + 1
   local count, limlist = limited_list('playlist', pos)
   if count == 0 then
      return 'Empty playlist.'
   end

   local message = string.format('Playlist [%d/%d]:\n', pos, count)
   for i, v in ipairs(limlist) do
      local title = v.title
      local _, filename = utils.split_path(v.filename)
      if title == nil then
         title = filename
      end
      message = string.format('%s %s %s\n', message,
                              (v.current and '●' or '○'), title)
   end
   return message
end

function get_chapterlist()
   local pos = mp.get_property_number('chapter', 0) + 1
   local count, limlist = limited_list('chapter-list', pos)
   if count == 0 then
      return 'No chapters.'
   end

   local message = string.format('Chapters [%d/%d]:\n', pos, count)
   for i, v in ipairs(limlist) do
      local time = mp.format_time(v.time)
      local title = v.title
      if title == nil then
         title = string.format('Chapter %02d', i)
      end
      message = string.format('%s[%s] %s %s\n', message, time,
                              (v.current and '●' or '○'), title)
   end
   return message
end

function show_message(text, duration)

   --print("text: "..text.."   duration: " .. duration)
   if duration == nil then
      duration = tonumber(mp.get_property("options/osd-duration")) / 1000
   elseif not type(duration) == "number" then
      print("duration: " .. duration)
   end

   -- cut the text short, otherwise the following functions
   -- may slow down massively on huge input
   text = string.sub(text, 0, 4000)

   -- replace actual linebreaks with ASS linebreaks
   text = string.gsub(text, "\n", "\\N")

   state.message_text = text

   if not state.message_hide_timer then
      state.message_hide_timer = mp.add_timeout(0, request_tick)
   end
   state.message_hide_timer:kill()
   state.message_hide_timer.timeout = duration
   state.message_hide_timer:resume()
   request_tick()
end

function render_message(ass)
   if state.message_hide_timer and state.message_hide_timer:is_enabled() and
      state.message_text
   then
      local _, lines = string.gsub(state.message_text, "\\N", "")

      local fontsize = tonumber(mp.get_property("options/osd-font-size"))
      local outline = tonumber(mp.get_property("options/osd-border-size"))
      local maxlines = math.ceil(osc_param.unscaled_y*0.75 / fontsize)
      local counterscale = osc_param.playresy / osc_param.unscaled_y

      fontsize = fontsize * counterscale / math.max(0.65 + math.min(lines/maxlines, 1), 1)
      outline = outline * counterscale / math.max(0.75 + math.min(lines/maxlines, 1)/2, 1)

      local style = "{\\bord" .. outline .. "\\fs" .. fontsize .. "}"


      ass:new_event()
      ass:append(style .. state.message_text)
   else
      state.message_text = nil
   end
end

--
-- Initialisation and Layout
--

function new_element(name, type)
   elements[name] = {}
   elements[name].type = type

   -- add default stuff
   elements[name].eventresponder = {}
   elements[name].visible = true
   elements[name].enabled = true
   elements[name].softrepeat = false
   elements[name].styledown = (type == "button")
   elements[name].state = {}

   if (type == "slider") then
      elements[name].slider = {min = {value = 0}, max = {value = 100}}
   end


   return elements[name]
end

function add_layout(name)
   if not (elements[name] == nil) then
      -- new layout
      elements[name].layout = {}

      -- set layout defaults
      elements[name].layout.layer = 50
      elements[name].layout.alpha = {[1] = 0, [2] = 255, [3] = 255, [4] = 255}

      if (elements[name].type == "button") then
         elements[name].layout.button = {
            maxchars = nil,
         }
      elseif (elements[name].type == "slider") then
         -- slider defaults
         elements[name].layout.slider = {
            border = 1,
            gap = 1,
            nibbles_top = true,
            nibbles_bottom = true,
            stype = "slider",
            adjust_tooltip = true,
            tooltip_style = "",
            tooltip_an = 2,
            alpha = {[1] = 0, [2] = 255, [3] = 88, [4] = 255},
         }
      elseif (elements[name].type == "box") then
         elements[name].layout.box = {radius = 0}
      end

      return elements[name].layout
   else
      msg.error("Can't add_layout to element \""..name.."\", doesn't exist.")
   end
end

--
-- Layout
--

function osc_layout()
   local osc_geo = {
      x = -2,
      y,
      an = 7,
      w,
      h = 56,
   }

   local padX = 9
   local padY = 3
   local buttonW = 27
   local tcW = 110
   if user_opts.tcspace >= 50 and user_opts.tcspace <= 200 then
      -- adjust our hardcoded font size estimation
      tcW = tcW * user_opts.tcspace / 100
   end

   local tsW = 90
   local minW = (buttonW + padX)*5 + (tcW + padX)*4 + (tsW + padX)*2

   local padwc_l = 0
   local padwc_r = 0

   if ((osc_param.display_aspect > 0) and (osc_param.playresx < minW)) then
      osc_param.playresy = minW / osc_param.display_aspect
      osc_param.playresx = osc_param.playresy * osc_param.display_aspect
   end

   osc_geo.y = -1 * (54 + user_opts.barmargin)
   osc_geo.w = osc_param.playresx + 4
   osc_geo.y = osc_geo.y + osc_param.playresy

   local line1 = osc_geo.y + (9 + padY)
   local line2 = osc_geo.y + (36 + padY)

   osc_param.areas = {}

   add_area("input", get_hitbox_coords(osc_geo.x, osc_geo.y, osc_geo.an,
                                       osc_geo.w, osc_geo.h))

   local sh_area_y0, sh_area_y1

   -- deadzone above OSC
   sh_area_y0 = get_align(-1 + (2*user_opts.deadzonesize),
                          osc_geo.y - (osc_geo.h / 2), 0, 0)
   sh_area_y1 = osc_param.playresy - user_opts.barmargin

   add_area("showhide", 0, sh_area_y0, osc_param.playresx, sh_area_y1)

   local lo, geo

   -- Background bar
   new_element("bgbox", "box")
   lo = add_layout("bgbox")

   lo.geometry = osc_geo
   lo.layer = 10
   lo.style = osc_styles.box
   lo.alpha[1] = user_opts.boxalpha

   geo = { x = osc_geo.x + padX, y = line1,
           an = 4, w = 18, h = 18 - padY }

   local t_l = geo.x

   -- Cache
   geo = { x = osc_geo.x + osc_geo.w - padX, y = geo.y,
           an = 6, w = 150, h = geo.h }
   lo = add_layout("cache")
   lo.geometry = geo
   lo.style = osc_styles.vidtitle

   local t_r = geo.x - geo.w - padX*2

   -- Title
   geo = { x = t_l, y = geo.y, an = 4,
           w = t_r - t_l, h = geo.h }
   lo = add_layout("title")
   lo.geometry = geo
   lo.style = string.format("%s{\\clip(%f,%f,%f,%f)}",
                            osc_styles.vidtitle,
                            geo.x, geo.y-geo.h, geo.w, geo.y+geo.h)


   geo = { x = osc_geo.x, y = line2, an = 4,
           w = buttonW, h = 30 - padY*2}

   -- Left timecode
   geo = { x = geo.x + tcW, y = geo.y, an = 6,
           w = tcW, h = geo.h }
   lo = add_layout("tc_left")
   lo.geometry = geo
   lo.style = osc_styles.timecodes

   local sb_l = geo.x + padX

   geo = { x = osc_geo.x + osc_geo.w - buttonW - padX - padwc_r, y = geo.y, an = 4,
           w = buttonW, h = geo.h }

   -- Right timecode
   geo = { x = geo.x - tcW + 20, y = geo.y, an = geo.an,
           w = tcW, h = geo.h }
   lo = add_layout("tc_right")
   lo.geometry = geo
   lo.style = osc_styles.timecodes

   local sb_r = geo.x - padX

   -- Seekbar
   geo = { x = sb_l, y = geo.y, an = geo.an,
           w = math.max(0, sb_r - sb_l), h = geo.h }
   new_element("bgbar1", "box")
   lo = add_layout("bgbar1")
   lo.geometry = geo
   lo.layer = 15
   lo.style = osc_styles.timecodes
   lo.alpha[1] =
      math.min(255, user_opts.boxalpha + (255 - user_opts.boxalpha)*0.8)


   lo = add_layout("seekbar")
   lo.geometry = geo
   lo.style = osc_styles.timecodes
   lo.slider.border = 0
   lo.slider.gap = 2
   lo.slider.tooltip_style = osc_styles.timepos
   lo.slider.tooltip_an = 5
   lo.slider.stype = "bar"
   lo.slider.rtype = "inverted"

   osc_param.video_margins.b = osc_geo.h / osc_param.playresy
end


-- Validate string type user options
function validate_user_opts()
end

function update_options(list)
   validate_user_opts()
   request_tick()
   visibility_mode(user_opts.visibility, true)
   update_duration_watch()
   request_init()
end

-- OSC INIT
function osc_init()
   msg.debug("osc_init")

   -- set canvas resolution according to display aspect and scaling setting
   local baseResY = 720
   local display_w, display_h, display_aspect = mp.get_osd_size()
   local scale = 1

   if (mp.get_property("video") == "no") then -- dummy/forced window
      scale = user_opts.scaleforcedwindow
   elseif state.fullscreen then
      scale = user_opts.scalefullscreen
   else
      scale = user_opts.scalewindowed
   end

   if user_opts.vidscale then
      osc_param.unscaled_y = baseResY
   else
      osc_param.unscaled_y = display_h
   end
   osc_param.playresy = osc_param.unscaled_y / scale
   if (display_aspect > 0) then
      osc_param.display_aspect = display_aspect
   end
   osc_param.playresx = osc_param.playresy * osc_param.display_aspect

   -- stop seeking with the slider to prevent skipping files
   state.active_element = nil

   osc_param.video_margins = {l = 0, r = 0, t = 0, b = 0}

   elements = {}

   -- some often needed stuff
   local pl_count = mp.get_property_number("playlist-count", 0)
   local have_pl = (pl_count > 1)
   local pl_pos = mp.get_property_number("playlist-pos", 0) + 1
   local have_ch = (mp.get_property_number("chapters", 0) > 0)
   local loop = mp.get_property("loop-playlist", "no")

   local ne

   -- title
   ne = new_element("title", "button")
   ne.content = function ()
      local title = state.forced_title or
         mp.command_native({"expand-text", user_opts.title})
      -- escape ASS, and strip newlines and trailing slashes
      title = title:gsub("\\n", " "):gsub("\\$", ""):gsub("{","\\{")
      return not (title == "") and title or "mpv"
   end

   --
   update_tracklist()

   --seekbar
   ne = new_element("seekbar", "slider")
   ne.enabled = not (mp.get_property("percent-pos") == nil)
   state.slider_element = ne.enabled and ne or nil  -- used for forced_title
   ne.slider.markerF = function ()
      local duration = mp.get_property_number("duration", nil)
      if not (duration == nil) then
         local chapters = mp.get_property_native("chapter-list", {})
         local markers = {}
         for n = 1, #chapters do
            markers[n] = (chapters[n].time / duration * 100)
         end
         return markers
      else
         return {}
      end
   end
   ne.slider.posF =
      function () return mp.get_property_number("percent-pos", nil) end
   ne.slider.tooltipF = function (pos)
      local duration = mp.get_property_number("duration", nil)
      if not ((duration == nil) or (pos == nil)) then
         possec = duration * (pos / 100)
         return mp.format_time(possec)
      else
         return ""
      end
   end
   ne.slider.seekRangesF = function()
      local cache_state = state.cache_state
      if not cache_state then
         return nil
      end
      local duration = mp.get_property_number("duration", nil)
      if (duration == nil) or duration <= 0 then
         return nil
      end
      local ranges = cache_state["seekable-ranges"]
      if #ranges == 0 then
         return nil
      end
      local nranges = {}
      for _, range in pairs(ranges) do
         nranges[#nranges + 1] = {
            ["start"] = 100 * range["start"] / duration,
            ["end"] = 100 * range["end"] / duration,
         }
      end
      return nranges
   end
   ne.eventresponder["mouse_move"] = --keyframe seeking when mouse is dragged
      function (element)
         -- mouse move events may pile up during seeking and may still get
         -- sent when the user is done seeking, so we need to throw away
         -- identical seeks
         local seekto = get_slider_value(element)
         if (element.state.lastseek == nil) or
            (not (element.state.lastseek == seekto)) then
            local flags = "absolute-percent"
            if not user_opts.seekbarkeyframes then
               flags = flags .. "+exact"
            end
            mp.commandv("seek", seekto, flags)
            element.state.lastseek = seekto
         end

      end
   ne.eventresponder["mbtn_left_down"] = --exact seeks on single clicks
      function (element) mp.commandv("seek", get_slider_value(element),
                                     "absolute-percent", "exact") end
   ne.eventresponder["reset"] =
      function (element) element.state.lastseek = nil end


   -- tc_left (current pos)
   ne = new_element("tc_left", "button")
   ne.content = function ()
      return (mp.get_property_osd("playback-time"))
   end

   -- tc_right (total/remaining time)
   ne = new_element("tc_right", "button")
   ne.visible = (mp.get_property_number("duration", 0) > 0)
   ne.content = function ()
      local minus = "-"
      return (minus..mp.get_property_osd("playtime-remaining"))
   end

   -- cache
   ne = new_element("cache", "button")
   ne.content = function ()
      local cache_state = state.cache_state
      if not (cache_state and cache_state["seekable-ranges"] and
              #cache_state["seekable-ranges"] > 0) then
         -- probably not a network stream
         return ""
      end
      local dmx_cache = cache_state and cache_state["cache-duration"]
      local thresh = math.min(state.dmx_cache * 0.05, 5)  -- 5% or 5s
      if dmx_cache and math.abs(dmx_cache - state.dmx_cache) >= thresh then
         state.dmx_cache = dmx_cache
      else
         dmx_cache = state.dmx_cache
      end

      local min = math.floor(dmx_cache / 60)
      local sec = math.floor(dmx_cache % 60) -- don't round e.g. 59.9 to 60
      local hrs = math.floor(min / 60)
      if hrs > 0 then
         min = math.floor(min % 60)
      end

      local remaining = mp.get_property_native("playtime-remaining")
      if dmx_cache and remaining and dmx_cache >= remaining then
         return ""
      end

      return "cached " .. (hrs > 0 and string.format("%sh %2sm %2ss", hrs, min, sec) or
                           min > 0 and string.format("%2sm %2ss", min, sec) or
                           string.format("%2ss", sec))
   end

   -- load layout
   osc_layout()

   --do something with the elements
   prepare_elements()

   update_margins()
end

function reset_margins()
   if state.using_video_margins then
      for _, opt in ipairs(margins_opts) do
         mp.set_property_number(opt[2], 0.0)
      end
      state.using_video_margins = false
   end
end

function update_margins()
   local margins = osc_param.video_margins

   -- Don't use margins if it's visible only temporarily.
   if (not state.osc_visible) or (get_hidetimeout() >= 0) or
      (state.fullscreen and not user_opts.showfullscreen) or
      (not state.fullscreen and not user_opts.showwindowed)
   then
      margins = {l = 0, r = 0, t = 0, b = 0}
   end

   reset_margins()

   utils.shared_script_property_set("osc-margins",
                                    string.format("%f,%f,%f,%f", margins.l, margins.r, margins.t, margins.b))
end

function shutdown()
   reset_margins()
   utils.shared_script_property_set("osc-margins", nil)
end

--
-- Other important stuff
--


function show_osc()
   -- show when disabled can happen (e.g. mouse_move) due to async/delayed unbinding
   if not state.enabled then return end

   msg.trace("show_osc")
   --remember last time of invocation (mouse move)
   state.showtime = mp.get_time()

   osc_visible(true)
end

function hide_osc()
   msg.trace("hide_osc")
   if not state.enabled then
      -- typically hide happens at render() from tick(), but now tick() is
      -- no-op and won't render again to remove the osc, so do that manually.
      state.osc_visible = false
      render_wipe()
   else
      osc_visible(false)
   end
end

function osc_visible(visible)
   if state.osc_visible ~= visible then
      state.osc_visible = visible
      update_margins()
   end
   request_tick()
end

function pause_state(name, enabled)
   state.paused = enabled
   request_tick()
end

function cache_state(name, st)
   state.cache_state = st
   request_tick()
end

-- Request that tick() is called (which typically re-renders the OSC).
-- The tick is then either executed immediately, or rate-limited if it was
-- called a small time ago.
function request_tick()
   if state.tick_timer == nil then
      state.tick_timer = mp.add_timeout(0, tick)
   end

   if not state.tick_timer:is_enabled() then
      local now = mp.get_time()
      local timeout = tick_delay - (now - state.tick_last_time)
      if timeout < 0 then
         timeout = 0
      end
      state.tick_timer.timeout = timeout
      state.tick_timer:resume()
   end
end

function mouse_leave()
   if get_hidetimeout() >= 0 then
      hide_osc()
   end
   -- reset mouse position
   state.last_mouseX, state.last_mouseY = nil, nil
   state.mouse_in_window = false
end

function request_init()
   state.initREQ = true
   request_tick()
end

-- Like request_init(), but also request an immediate update
function request_init_resize()
   request_init()
   -- ensure immediate update
   state.tick_timer:kill()
   state.tick_timer.timeout = 0
   state.tick_timer:resume()
end

function render_wipe()
   msg.trace("render_wipe()")
   state.osd.data = "" -- allows set_osd to immediately update on enable
   state.osd:remove()
end

function render()
   msg.trace("rendering")
   local current_screen_sizeX, current_screen_sizeY, aspect = mp.get_osd_size()
   local mouseX, mouseY = get_virt_mouse_pos()
   local now = mp.get_time()

   -- check if display changed, if so request reinit
   if not (state.mp_screen_sizeX == current_screen_sizeX
           and state.mp_screen_sizeY == current_screen_sizeY) then

      request_init_resize()

      state.mp_screen_sizeX = current_screen_sizeX
      state.mp_screen_sizeY = current_screen_sizeY
   end

   -- init management
   if state.active_element then
      -- mouse is held down on some element - keep ticking and igore initReq
      -- till it's released, or else the mouse-up (click) will misbehave or
      -- get ignored. that's because osc_init() recreates the osc elements,
      -- but mouse handling depends on the elements staying unmodified
      -- between mouse-down and mouse-up (using the index active_element).
      request_tick()
   elseif state.initREQ then
      osc_init()
      state.initREQ = false

      -- store initial mouse position
      if (state.last_mouseX == nil or state.last_mouseY == nil)
         and not (mouseX == nil or mouseY == nil) then

         state.last_mouseX, state.last_mouseY = mouseX, mouseY
      end
   end

   --mouse show/hide area
   for k,cords in pairs(osc_param.areas["showhide"]) do
      set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, "showhide")
   end
   if osc_param.areas["showhide_wc"] then
      for k,cords in pairs(osc_param.areas["showhide_wc"]) do
         set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, "showhide_wc")
      end
   else
      set_virt_mouse_area(0, 0, 0, 0, "showhide_wc")
   end
   do_enable_keybindings()

   --mouse input area
   local mouse_over_osc = false

   for _,cords in ipairs(osc_param.areas["input"]) do
      if state.osc_visible then -- activate only when OSC is actually visible
         set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, "input")
      end
      if state.osc_visible ~= state.input_enabled then
         if state.osc_visible then
            mp.enable_key_bindings("input")
         else
            mp.disable_key_bindings("input")
         end
         state.input_enabled = state.osc_visible
      end

      if (mouse_hit_coords(cords.x1, cords.y1, cords.x2, cords.y2)) then
         mouse_over_osc = true
      end
   end

   -- autohide
   if not (state.showtime == nil) and (get_hidetimeout() >= 0) then
      local timeout = state.showtime + (get_hidetimeout()/1000) - now
      if timeout <= 0 then
         if (state.active_element == nil) and not (mouse_over_osc) then
            hide_osc()
         end
      else
         -- the timer is only used to recheck the state and to possibly run
         -- the code above again
         if not state.hide_timer then
            state.hide_timer = mp.add_timeout(0, tick)
         end
         state.hide_timer.timeout = timeout
         -- re-arm
         state.hide_timer:kill()
         state.hide_timer:resume()
      end
   end


   -- actual rendering
   local ass = assdraw.ass_new()

   -- Messages
   render_message(ass)

   -- actual OSC
   if state.osc_visible then
      render_elements(ass)
   end

   -- submit
   set_osd(osc_param.playresy * osc_param.display_aspect,
           osc_param.playresy, ass.text)
end

--
-- Eventhandling
--

local function element_has_action(element, action)
   return element and element.eventresponder and
      element.eventresponder[action]
end

function process_event(source, what)
   local action = string.format("%s%s", source,
                                what and ("_" .. what) or "")

   if what == "down" or what == "press" then

      for n = 1, #elements do

         if mouse_hit(elements[n]) and
            elements[n].eventresponder and
            (elements[n].eventresponder[source .. "_up"] or
             elements[n].eventresponder[action]) then

            if what == "down" then
               state.active_element = n
               state.active_event_source = source
            end
            -- fire the down or press event if the element has one
            if element_has_action(elements[n], action) then
               elements[n].eventresponder[action](elements[n])
            end

         end
      end

   elseif what == "up" then

      if elements[state.active_element] then
         local n = state.active_element

         if n == 0 then
            --click on background (does not work)
         elseif element_has_action(elements[n], action) and
            mouse_hit(elements[n]) then

            elements[n].eventresponder[action](elements[n])
         end

         --reset active element
         if element_has_action(elements[n], "reset") then
            elements[n].eventresponder["reset"](elements[n])
         end

      end
      state.active_element = nil
      state.mouse_down_counter = 0

   elseif source == "mouse_move" then

      state.mouse_in_window = true

      local mouseX, mouseY = get_virt_mouse_pos()
      if (user_opts.minmousemove == 0) or
         (not ((state.last_mouseX == nil) or (state.last_mouseY == nil)) and
          ((math.abs(mouseX - state.last_mouseX) >= user_opts.minmousemove)
             or (math.abs(mouseY - state.last_mouseY) >= user_opts.minmousemove)
          )
      ) then
         show_osc()
      end
      state.last_mouseX, state.last_mouseY = mouseX, mouseY

      local n = state.active_element
      if element_has_action(elements[n], action) then
         elements[n].eventresponder[action](elements[n])
      end
   end

   -- ensure rendering after any (mouse) event - icons could change etc
   request_tick()
end

-- called by mpv on every frame
function tick()
   if state.marginsREQ == true then
      update_margins()
      state.marginsREQ = false
   end

   if (not state.enabled) then return end

   if (state.fullscreen and user_opts.showfullscreen)
      or (not state.fullscreen and user_opts.showwindowed) then

      -- render the OSC
      render()
   else
      -- Flush OSD
      render_wipe()
   end

   state.tick_last_time = mp.get_time()
end

function do_enable_keybindings()
   if state.enabled then
      if not state.showhide_enabled then
         mp.enable_key_bindings("showhide", "allow-vo-dragging+allow-hide-cursor")
         mp.enable_key_bindings("showhide_wc", "allow-vo-dragging+allow-hide-cursor")
      end
      state.showhide_enabled = true
   end
end

function enable_osc(enable)
   state.enabled = enable
   if enable then
      do_enable_keybindings()
   else
      hide_osc() -- acts immediately when state.enabled == false
      if state.showhide_enabled then
         mp.disable_key_bindings("showhide")
         mp.disable_key_bindings("showhide_wc")
      end
      state.showhide_enabled = false
   end
end

-- duration is observed for the sole purpose of updating chapter markers
-- positions. live streams with chapters are very rare, and the update is also
-- expensive (with request_init), so it's only observed when we have chapters
-- and the user didn't disable the livemarkers option (update_duration_watch).
function on_duration() request_init() end

local duration_watched = false
function update_duration_watch()
   local want_watch = user_opts.livemarkers and
      (mp.get_property_number("chapters", 0) or 0) > 0 and
      true or false  -- ensure it's a boolean

   if (want_watch ~= duration_watched) then
      if want_watch then
         mp.observe_property("duration", nil, on_duration)
      else
         mp.unobserve_property(on_duration)
      end
      duration_watched = want_watch
   end
end

validate_user_opts()
update_duration_watch()

mp.register_event("shutdown", shutdown)
mp.register_event("start-file", request_init)
mp.observe_property("osc", "bool", function(name, value)
                       if value == true then
                          mp.set_property("osc", "no")
                       end
end)
mp.observe_property("track-list", nil, request_init)
mp.observe_property("playlist", nil, request_init)
mp.observe_property("chapter-list", "native", function(_, list)
                       list = list or {}  -- safety, shouldn't return nil
                       table.sort(list, function(a, b) return a.time < b.time end)
                       state.chapter_list = list
                       update_duration_watch()
                       request_init()
end)

mp.register_script_message("osc-message", show_message)
mp.register_script_message("osc-chapterlist", function(dur)
                              show_message(get_chapterlist(), dur)
end)
mp.register_script_message("osc-playlist", function(dur)
                              show_message(get_playlist(), dur)
end)
mp.register_script_message("osc-tracklist", function(dur)
                              local msg = {}
                              for k,v in pairs(nicetypes) do
                                 table.insert(msg, get_tracklist(k))
                              end
                              show_message(table.concat(msg, '\n\n'), dur)
end)

mp.observe_property("fullscreen", "bool",
                    function(name, val)
                       state.fullscreen = val
                       state.marginsREQ = true
                       request_init_resize()
                    end
)
mp.observe_property("border", "bool",
                    function(name, val)
                       state.border = val
                       request_init_resize()
                    end
)
mp.observe_property("window-maximized", "bool",
                    function(name, val)
                       state.maximized = val
                       request_init_resize()
                    end
)

mp.observe_property("pause", "bool", pause_state)
mp.observe_property("demuxer-cache-state", "native", cache_state)
mp.observe_property("vo-configured", "bool", function(name, val)
                       request_tick()
end)
mp.observe_property("playback-time", "number", function(name, val)
                       request_tick()
end)
mp.observe_property("osd-dimensions", "native", function(name, val)
                       -- (we could use the value instead of re-querying it all the time, but then
                       --  we might have to worry about property update ordering)
                       request_init_resize()
end)

-- mouse show/hide bindings
mp.set_key_bindings({
      {"mouse_move",              function(e) process_event("mouse_move", nil) end},
      {"mouse_leave",             mouse_leave},
                    }, "showhide", "force")
mp.set_key_bindings({
      {"mouse_move",              function(e) process_event("mouse_move", nil) end},
      {"mouse_leave",             mouse_leave},
                    }, "showhide_wc", "force")
do_enable_keybindings()

--mouse input bindings
mp.set_key_bindings({
      {"mbtn_left",           function(e) process_event("mbtn_left", "up") end,
       function(e) process_event("mbtn_left", "down")  end},
      {"shift+mbtn_left",     function(e) process_event("shift+mbtn_left", "up") end,
       function(e) process_event("shift+mbtn_left", "down")  end},
      {"mbtn_right",          function(e) process_event("mbtn_right", "up") end,
       function(e) process_event("mbtn_right", "down")  end},
      -- alias to shift_mbtn_left for single-handed mouse use
      {"mbtn_mid",            function(e) process_event("shift+mbtn_left", "up") end,
       function(e) process_event("shift+mbtn_left", "down")  end},
      {"wheel_up",            function(e) process_event("wheel_up", "press") end},
      {"wheel_down",          function(e) process_event("wheel_down", "press") end},
      {"mbtn_left_dbl",       "ignore"},
      {"shift+mbtn_left_dbl", "ignore"},
      {"mbtn_right_dbl",      "ignore"},
                    }, "input", "force")
mp.enable_key_bindings("input")

function get_hidetimeout()
   if user_opts.visibility == "always" then
      return -1 -- disable autohide
   end
   return user_opts.hidetimeout
end

function always_on(val)
   if state.enabled then
      if val then
         show_osc()
      else
         hide_osc()
      end
   end
end

-- mode can be auto/always/never/cycle
-- the modes only affect internal variables and not stored on its own.
function visibility_mode(mode, no_osd)
   if mode == "cycle" then
      if not state.enabled then
         mode = "auto"
      elseif user_opts.visibility ~= "always" then
         mode = "always"
      else
         mode = "never"
      end
   end

   if mode == "auto" then
      always_on(false)
      enable_osc(true)
   elseif mode == "always" then
      enable_osc(true)
      always_on(true)
   elseif mode == "never" then
      enable_osc(false)
   else
      msg.warn("Ignoring unknown visibility mode '" .. mode .. "'")
      return
   end

   user_opts.visibility = mode
   utils.shared_script_property_set("osc-visibility", mode)

   if not no_osd and tonumber(mp.get_property("osd-level")) >= 1 then
      mp.osd_message("OSC visibility: " .. mode)
   end

   -- Reset the input state on a mode change. The input state will be
   -- recalculated on the next render cycle, except in 'never' mode where it
   -- will just stay disabled.
   mp.disable_key_bindings("input")
   state.input_enabled = false

   update_margins()
   request_tick()
end

visibility_mode(user_opts.visibility, true)
mp.register_script_message("osc-visibility", visibility_mode)
mp.add_key_binding(nil, "visibility", function() visibility_mode("cycle") end)

mp.register_script_message("thumbfast-info", function(json)
                              local data = utils.parse_json(json)
                              if type(data) ~= "table" or not data.width or not data.height then
                                 msg.error("thumbfast-info: received json didn't produce a table with thumbnail information")
                              else
                                 thumbfast = data
                              end
end)

set_virt_mouse_area(0, 0, 0, 0, "input")
