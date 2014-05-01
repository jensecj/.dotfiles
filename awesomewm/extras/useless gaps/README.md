#The look
![Screenshot of useless gaps in action](gaps_screen.png?raw=true "Screenshot of useless gaps in action")

# Useless gaps for awesomewm 3.5
This is just a simple modification of `awful.layout.suit.fair` to
introduce useless gaps between clients.
If you want to use a different layout, just look at the changes i made
(lines 56-59) and apply to your theme of choice.

#Usage
Just copy the contents of useless_gaps.lua into the section above
layouts in your rc.lua, and add gaps as a layout.

Change `local gap_size = ...` to fit your needs

```lua
-- copy contents of useless_gaps.lua to here

local layouts =
{
    gaps, -- add gaps as a layout
    awful.layout.suit.fair,
    awful.layout.suit.tile,
    ...
}
```

Enjoy your useless gaps.
