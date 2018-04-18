#!/bin/sh
termite --name="dict-lookup" --geometry 700x1000 -e "bash -c 'dict $1| less'"
# remove define from rofi's history
# or use ctrl-enter to force current text to be used, instead of first entry
# sed -i '/\define/d' /home/jens/.cache/rofi-3.runcache
