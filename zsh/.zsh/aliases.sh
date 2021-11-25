#!/bin/bash

# * common shortcuts
alias sudo='\sudo -E '
alias _='\sudo -E '
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias dd="dd status=progress"
alias cp="rsync -avz --progress"
alias rm="echo 'use rip'"


# * better defaults
alias ls='ls --color=always --time-style="+%d-%m-%Y" --group-directories-first'
alias l="ls -gholXN"
alias ll="ls -agholXN"

alias free="free -h" # show sizes in a human readable format
alias grep='grep --color=always' # use colors in grep
alias diff="diff --color=always" # use colors in diff
alias mkdir='mkdir -p -v' # create parent directories and tell us
alias df="df -h" # human-readable by default
alias bc="bc -ql" # be quiet, and load floating-point math and stdlib
alias ssh-add="ssh-add -t 1h" # 1-hour default timeout for cached ssh keys
alias emacsd="emacs --no-site-file --daemon"

# alias escape="tr -cd '[:print:]'" # TODO: fix this, does not work

# * replacements
alias l="exa --long --group-directories-first --time-style=long-iso"
alias ll="l --all --group"


# * package manager
alias pac='yay'                          # aur helper
alias pacu='pac -Syu --combinedupgrade'  # update all packages
# alias pacu='pac -Syu --upgrademenu'  # update all packages
alias pacrm='pac -Rns'                   # remove a package
alias pacss='pac -Ss'                    # search for a package
alias pacs='pac -S'                      # install a package
alias pacls='pac -Qet'                   # list installed packages
alias pacown="pac -Qo"                   # list package which owns <file>
alias pacdeps="pactree -u"               # list package dependencies
alias pacrdeps="pactree -ur"             # list package dependents

paci() {
    pkg=$(yay -Sl | fzf --preview-window=top:70% --preview="yay -Si {2}" | awk '{print $2}')
    print -z $pkg
}


# * youtube-dl
alias ytdlp='ytdl --yes-playlist'
alias ytarc="ytdl --write-description --all-subs --embed-subs --add-metadata --embed-thumbnail"
alias ytdlnr='ytdl -o"%(autonumber)s -- %(uploader)s -- %(upload_date)s -- %(title)s.%(ext)s"'
alias ytmp3='youtube-dl -f "bestaudio" -x --audio-format mp3 -o"%(uploader)s -- %(title)s.%(ext)s"'


# * applications
alias mpv="mpv"
alias feh="feh --conversion-timeout 1"

# easy file / directory search using `fd`
alias ff="\fd --type f"
alias fd="\fd --type d"

alias rtor=" \rtorrent"

alias py="python"
alias qr="qrcode-terminal"

alias pdf='zathura'
alias cloc="tokei"

# * misc
alias drop_cache="sudo sync; sudo sysctl -w vm.drop_caches=3"
alias mount_ramdisk="_ mount -t tmpfs -o size=1024m tmpfs /mnt/ramdisk"
alias umount_ramdisk="_ umount /mnt/ramdisk"


# * fzf functions
fzf-cd() {
    cd $(fd | fzf --no-multi)
    zle clear-screen
}

fzf-z() {
    zi
    zle clear-screen
}

fzf-locate() {
    locate | fzf | xargs | xsel -i
}

fzf-history() {
    BUFFER=$(history -n -r 1 | fzf --no-sort --no-multi --query "$LBUFFER")
    CURSOR=$#BUFFER
}

fzf-urls() {
    # look at all scrollback contents of tmux buffer, and copy
    # selected url to clipboard
    local url_regex="(((http|https|ftp|gopher|git)|mailto)[.:@][^ >\"\t]*|www\.[-a-z0-9.]+)[^ .,;\t>\">\):]"
    tmux capture-pane -pS -100000 \
        | rg --no-filename --no-line-number "$url_regex" \
        | fzf --no-sort --no-multi \
        | xargs \
        | xsel -i
}


# * extra functions
whichterm() {
    # figure out which terminal emulator we're inside of
    # echo $TERM does not always work, because sometimes term lies
    ps -p $PPID | awk '{print $4}' | sed -n '2p'
}

whichshell() {
    # figure out which shell we're running
    ps -p "$$" | awk '{print $4}' | sed -n '2p'
}

bu() {
    for f in "$@"; do
        BAK="$f.bak"
        while [ -e "$BAK" ]; do
            BAK="$BAK.bak"
        done
        cp "$f" "$BAK"
    done
}

mvbu() {
    for f in "$@"; do
        BAK="$f.bak"
        while [ -e "$BAK" ]; do
            BAK="$BAK.bak"
        done
        mv "$f" "$BAK"
    done
}

mcd() { mkdir -p "$1"; cd "$1" || exit 1; }

lnk() {
    [ $# -gt 1 ] || return 1

    local src=$(realpath "$1")
    local dst=$(realpath "$2")
    echo "$src -> $dst"

    if [ "$3" = "-" ]; then
        sudo ln -s "$src" "$dst"
    else
        ln -s "$src" "$dst"
    fi
}
