#!/bin/sh
# save each word, so they can be used for statistics/practice/etc.
echo $(date +'%Y-%m-%dT%H:%M:%S%z') " | " $1 >> ~/.dict-lookups
termite --name="dict-lookup" --geometry 700x1000 -e "bash -c 'dict $1| less'"
# remove define from rofi's history
# or use ctrl-enter to force current text to be used, instead of first entry
# sed -i '/\define/d' /home/jens/.cache/rofi-3.runcache
