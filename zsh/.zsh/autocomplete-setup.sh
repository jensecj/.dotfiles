#!/bin/sh

# load the auto completion system and setup
autoload -Uz complist
autoload -Uz compinit

# if the cache does not exist, or if it is older
# than 24 hours, rebuild it.
cache_exists=$(test -e ~/.zcompdump)
if [[ ! -e "$HOME/.zcompdump" || $(find "$HOME/.zcompdump" -mtime +1) ]]; then
    compinit
else
    compinit -C
fi

zstyle ':completion:*' use-cache on
# show the selected item in the menu
zstyle ':completion:*' menu select
# setup an autocompletion style (case-insensitive)
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-dirs-first true
