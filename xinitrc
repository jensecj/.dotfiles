setxkbmap -layout dk -option ctrl:nocaps
synclient CoastingSpeed=0
synclient FingerHigh=50
synclient FingerLow=45
xrdb ~/.Xresources
start-pulseaudio-x11
unclutter &
dropboxd &
skype &
exec awesome
