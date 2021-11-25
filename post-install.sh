#!/bin/sh

# auto-detect profiles for installed firefox instances, and link config files
for profile in $(find "$HOME/.mozilla/firefox" \
                      -maxdepth 1 \
                      -type l,d \
                      -iname '*default*' \
                     | grep -v 'backup'); do
    mkdir -p "$profile/chrome"
    ln -s "$(pwd)/firefox/user.js" "$profile/user.js"
    ln -s "$(pwd)/firefox/userChrome.css" "$profile/chrome/userChrome.css"
    ln -s "$(pwd)/firefox/userContent.css" "$profile/chrome/userContent.css"
done

# don't wait for a minute and a half before force stopping things
sed -i 's/#DefaultTimeoutStartSec=90s/DefaultTimeoutStartSec=30s/' /etc/systemd/system.conf
sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=30s/' /etc/systemd/system.conf

# get the network up
systemctl enable --now iwd
systemctl enable --now dhcpcd
systemctl enable --now dnscrypt-proxy.service

# fix fork bombs
if [ ! $(grep "\* hard nproc" /etc/security/limits.conf) ]; then
    echo "* hard nproc 2048" >> /etc/security/limits.conf
fi

# misc
mkdir "$HOME/.rtorrent.session"
