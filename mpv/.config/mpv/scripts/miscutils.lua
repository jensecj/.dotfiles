local msg = require 'mp.msg'
local utils = require 'mp.utils'

msg.info("v1 loaded")

-- * helpers

local function set_clipboard(text)
   mp.commandv("run", "/bin/bash", "-c", "printf '"..text.."' | wl-copy");
end

local function get_clipboard()
   -- local args = { 'xclip', '-selection', 'clipboard', '-out' }
   local args = { 'wl-paste' }
   clipboard = utils.subprocess({ args = args, cancellable = false }).stdout
   return string.gsub(clipboard, '%s+', '')
end

-- * commands

function copyurl()
   local url = mp.get_property("path")
   set_clipboard(url)
   mp.osd_message("copied "..url)
end
mp.add_key_binding("Ctrl+u", "copyurl", copyurl)

function append_clipboard_to_playlist()
   local url = get_clipboard()
   url = url:gsub("subscriptions.gir.st", "youtube.com")
   url = url:gsub("invidious.snopyta.org", "youtube.com")
   url = url:gsub("yewtu.be", "youtube.com")

   if url then
      mp.commandv("loadfile", url, "append-play")
      mp.osd_message("appended "..url)
   end
end
mp.add_key_binding("Ctrl+a", "append_clipboard_to_playlist", append_clipboard_to_playlist)

-- * misc

-- ** show chapter title when it changes
function display_chapter_title()
   local title = mp.get_property_osd("chapter-metadata/by-key/title")
   mp.osd_message(title, 3)
end
mp.observe_property("chapter", nil, display_chapter_title)
