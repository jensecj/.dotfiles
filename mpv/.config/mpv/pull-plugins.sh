#!/bin/sh

if [ ! -f scripts/mpv_thumbnail_script_client_osc.lua ]; then
    echo "downloading plugin: mpv_thumbnail_script"
    curl -s https://api.github.com/repos/TheAMM/mpv_thumbnail_script/releases/latest | grep browser_download_url | cut -d '"' -f 4 | wget -i -
    cp mpv_thumbnail_script_server.lua scripts/mpv_thumbnail_script_server-1.lua
    mv mpv_thumbnail_script_server.lua scripts/mpv_thumbnail_script_server-2.lua
    mv mpv_thumbnail_script_client_osc.lua scripts/mpv_thumbnail_script_client_osc.lua
fi

if [ ! -f scripts/youtube-quality.lua ]; then
    echo "downloading plugin: mpv-youtube-quality"
    curl https://raw.githubusercontent.com/jgreco/mpv-youtube-quality/master/youtube-quality.lua > scripts/youtube-quality.lua
fi

if [ ! -f scripts/reload.lua ]; then
    echo "downloading plugin: reload"
    curl https://raw.githubusercontent.com/4e6/mpv-reload/master/reload.lua > scripts/reload.lua
fi

if [ ! -f scripts/playlistmanager.lua ]; then
    echo "downloading plugin: playlistmanager"
    curl https://github.com/jonniek/mpv-playlistmanager/blob/master/titleresolver.lua > scripts/titleresolver.lua
    curl https://github.com/jonniek/mpv-playlistmanager/blob/master/playlistmanager.lua > scripts/playlistmanager.lua
fi

if [ ! -f scripts/navigator.lua ]; then
    echo "downloading plugin: navigator"
    curl https://github.com/jonniek/mpv-filenavigator/blob/master/navigator.lua > scripts/navigator.lua
fi
