# The look
![Screenshot of useless gaps in action](centered_widget_screen.png?raw=true "Screenshot of useless gaps in action")

# Centered widget for awesomewm 3.5
This layout makes the center widget take priority when sizing the widgets,
it is a simple extension of the `wibox.layout.align.horizontal` layout.

# Usage
Copy the contents of `centered_widget.lua` into the space above where
the final layout is set in rc.lua, and remove the line that previously
chose the layout.

```lua
...
-- copy contents of centered_widget.lua to here

local layout = wibox.layout.align.horizontal() -- remove this line

layout:set_left(left_layout)
layout:set_middle(mytasklist[s])
layout:set_right(right_layout)
...
```
Enjoy you centered widget
