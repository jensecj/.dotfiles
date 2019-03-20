#!/bin/sh

mkdir "$HOME/.rtorrent.session"
ln -s "$(pwd)/systemd-units/lock-on-sleep.service" /etc/systemd/system/

# disable beeps by not loading the pcspkr module
echo "blacklist pcspkr" >> /etc/modprobe.d/pcspkr-blacklist.conf

# dont wait for a minute and a half before force stopping things
sed -i 's/#DefaultTimeoutStartSec=90s/DefaultTimeoutStartSec=30s/' /etc/systemd/system.conf
sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=30s/' /etc/systemd/system.conf

# enable custom systemd units
systemctl enable lock-on-sleep.service
systemctl --user enable random-wallpaper.timer
systemctl --user start random-wallpaper.timer
