#!/bin/sh

# https://github.com/christoph-heinrich/mpv-quality-menu
if [ ! -f scripts/quality-menu.lua ]; then
    echo "downloading quality-menu"
    curl -# --no-clobber -o'scripts/quality-menu.lua' 'https://raw.githubusercontent.com/christoph-heinrich/mpv-quality-menu/master/quality-menu.lua'
    curl -# --no-clobber -o'script-opts/quality-menu.conf' 'https://raw.githubusercontent.com/christoph-heinrich/mpv-quality-menu/master/quality-menu.conf'
fi

# https://github.com/4e6/mpv-reload
if [ ! -f scripts/reload.lua ]; then
    echo "downloading reload"
    curl -# --no-clobber -o 'scripts/reload.lua' 'https://raw.githubusercontent.com/4e6/mpv-reload/master/reload.lua'
fi

# https://github.com/po5/chapterskip
if [ ! -f scripts/chapterskip.lua ]; then
    echo "downloading chapterskip"
    curl -# --no-clobber -o 'scripts/chapterskip.lua' 'https://raw.githubusercontent.com/po5/chapterskip/master/chapterskip.lua'
fi

# https://github.com/jonniek/mpv-playlistmanager
if [ ! -f scripts/playlistmanager.lua ]; then
    echo "downloading playlistmanager"
    curl -# --no-clobber -o'scripts/playlistmanager.lua' 'https://raw.githubusercontent.com/jonniek/mpv-playlistmanager/master/playlistmanager.lua'
    curl -# --no-clobber -o'script-opts/playlistmanager.conf' 'https://raw.githubusercontent.com/jonniek/mpv-playlistmanager/master/playlistmanager.conf'
fi

# https://codeberg.org/jouni/mpv_sponsorblock_minimal
if [ ! -f scripts/sponsorblock_minimal.lua ]; then
    echo "downloading sponsorblock_minimal"
    curl -# --no-clobber -o 'scripts/sponsorblock_minimal.lua' 'https://codeberg.org/jouni/mpv_sponsorblock_minimal/raw/branch/master/sponsorblock_minimal.lua'
fi

# https://github.com/CogentRedTester/mpv-scripts/blob/master/pause-indicator.lua
if [ ! -f scripts/pause-indicator.lua ]; then
    echo "downloading pause-indicator"
    curl -# --no-clobber -o 'scripts/pause-indicator.lua' 'https://raw.githubusercontent.com/CogentRedTester/mpv-scripts/master/pause-indicator.lua'
fi

# https://github.com/CogentRedTester/mpv-scripts/blob/master/keep-session.lua
if [ ! -f scripts/keep-session.lua ]; then
    echo "downloading keep-session"
    curl -# --no-clobber -o 'scripts/keep-session.lua' 'https://raw.githubusercontent.com/CogentRedTester/mpv-scripts/master/keep-session.lua'
fi

# https://github.com/po5/thumbfast
if [ ! -f scripts/thumbfast.lua ]; then
    echo "downloading thumbfast"
    curl -# --no-clobber -o 'scripts/thumbfast.lua' 'https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua'
    curl -# --no-clobber -o 'script-opts/thumbfast.conf' 'https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua'
    curl -# --no-clobber -o 'scripts/thumbfast_osc.lua' https://raw.githubusercontent.com/po5/thumbfast/vanilla-osc/player/lua/osc.lua
fi
