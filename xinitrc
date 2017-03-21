# remap capslock to ctrl
setxkbmap -layout dk -option ctrl:nocaps

# user and computer specific touchpad settings
synclient CoastingSpeed=0
synclient FingerHigh=50
synclient FingerLow=45

# source our terminal resources
xrdb ~/.Xresources

# start the audio server
start-pulseaudio-x11

# run programs i usually use
unclutter &
dropbox &
redshift -O 4000 &
exec awesome
