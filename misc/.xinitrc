#!/bin/sh

xset -b # disable the dang beep
setxkbmap -layout dk -option ctrl:nocaps # remap capslock to ctrl

xrandr & # ensure xrandr is started early

[ -f ~/.Xresources ] && xrdb -merge -I$HOME ~/.Xresources
[ -f ~/.xprofile ] && . ~/.xprofile
