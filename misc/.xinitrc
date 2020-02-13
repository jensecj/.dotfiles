# remap capslock to ctrl
setxkbmap -layout dk -option ctrl:nocaps
export LANG=en_DK.UTF-8

xrandr & # ensure xrandr is started early

xset -b # disable the dang beep

# source our terminal resources
xrdb ~/.Xresources

[ -f ~/.xprofile ] && . ~/.xprofile
