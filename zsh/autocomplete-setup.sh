# load the auto completion system and setup
autoload -Uz compinit

if [[ $(find /home/jens/.zcompdump -mtime +1) ]]; then
    compinit
fi

compinit -C

zstyle ':completion:*' use-cache on
# zstyle ':completion:*' cache-path ~/.zsh/cache
# show the selected item in the menu
zstyle ':completion:*' menu select
# setup an autocompletion style (case-insensitive)
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
