# remap capslock to ctrl
setxkbmap -layout dk -option ctrl:nocaps
export LANG = en_DK.UTF-8

# disable the dang beep
xset -b

# user and computer specific touchpad settings
synclient CoastingSpeed=0
synclient FingerHigh=50
synclient FingerLow=45

# source our terminal resources
xrdb ~/.Xresources

echo "xinitrc ran" >> /home/jens/runlog
