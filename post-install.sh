#!/bin/sh

# TODO: auto-detect firefox profile?
FIREFOX_PROFILE="cf5z4a52.dev-edition-default"
ln -s "$(pwd)/firefox/user.js" "$HOME/.mozilla/firefox/$FIREFOX_PROFILE/user.js"
ln -s "$(pwd)/firefox/userChrome.css" "$HOME/.mozilla/firefox/$FIREFOX_PROFILE/chrome/userChrome.css"
ln -s "$(pwd)/firefox/userContent.css" "$HOME/.mozilla/firefox/$FIREFOX_PROFILE/chrome/userContent.css"

# use a fancier diff
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

mkdir "$HOME/.rtorrent.session"

# disable beeps by not loading the pcspkr module
echo "blacklist pcspkr" >> /etc/modprobe.d/pcspkr-blacklist.conf

# disable xdg-user-dirs
echo "enabled=false" >> ~/.config/xdg-user-dirs.conf

# dont wait for a minute and a half before force stopping things
sed -i 's/#DefaultTimeoutStartSec=90s/DefaultTimeoutStartSec=30s/' /etc/systemd/system.conf
sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=30s/' /etc/systemd/system.conf

systemctl enable dnscrypt-proxy.service
systemctl start dnscrypt-proxy.service

# enable custom systemd units
systemctl enable lock-on-sleep.service

systemctl --user enable random-wallpaper.timer
systemctl --user enable lowtmp
systemctl --user enable mbsync

systemctl --user start random-wallpaper.timer
systemctl --user start lowtmp
systemctl --user start mbsync

# fix fork bombs
if [ ! $(grep "\* hard nproc" /etc/security/limits.conf) ]; then
    echo "* hard nproc 2048" >> /etc/security/limits.conf
fi
