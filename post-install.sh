#!/bin/sh

# use a fancier diff
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

mkdir "$HOME/.rtorrent.session"

# disable beeps by not loading the pcspkr module
echo "blacklist pcspkr" >> /etc/modprobe.d/pcspkr-blacklist.conf

# dont wait for a minute and a half before force stopping things
sed -i 's/#DefaultTimeoutStartSec=90s/DefaultTimeoutStartSec=30s/' /etc/systemd/system.conf
sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=30s/' /etc/systemd/system.conf

systemctl enable dnscrypt-proxy.service
systemctl start dnscrypt-proxy.service

# enable custom systemd units
systemctl enable lock-on-sleep.service

systemctl --user enable random-wallpaper
systemctl --user enable mbsync
systemctl --user enable lowtmp

systemctl --user start random-wallpaper
systemctl --user start mbsync
systemctl --user start lowtmp
