#!/bin/bash

# ** common shortcuts
alias sudo='\sudo -E '
alias _='\sudo -E '
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias dd="dd status=progress"
alias cp="rsync -avz --progress"
alias mv="rsync -avz --progress --remove-source-files"

# * better defaults
alias ls='ls --color=always --time-style="+%d-%m-%Y" --group-directories-first'
#alias l="ls -gholXN"
#alias ll="ls -agholXN"

alias free="free -h" # show sizes in a human readable format
alias grep='grep --color=always' # use colors in grep
alias diff="diff --color=always" # use colors in diff
alias mkdir='mkdir -p -v' # create parent directories and tell us
alias df="df -h" # human-readable by default
alias bc="bc -ql" # be quiet, and load floating-point math and stdlib
alias ssh-add="ssh-add -t 1h" # 1-hour default timeout for cached ssh keys
alias emacsd="emacs --no-site-file --daemon"


# ** replacements
alias uniq="runiq"
alias l="exa --long --group-directories-first --time-style=long-iso"
alias ll="l --all --group"

# * pacman
alias pac='yay'
alias pacu='pac -Syu --combinedupgrade' # update all packages
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

ytdl() {
    youtube-dl -i \
               -f "bestvideo[height<=?1080]+bestaudio/best" \
               -o"%(uploader)s -- %(upload_date)s -- %(title)s.%(ext)s" \
               --no-playlist \
               --prefer-ffmpeg \
               --postprocessor-args="-threads 2" \
               "$@"
}

alias ytdlp='ytdl --yes-playlist'
alias ytarc="ytdl --write-description --all-subs --embed-subs --add-metadata" # --embed-thumbnail does not work with .mkv yet
alias ytdlnr='ytdl -o"%(autonumber)s -- %(uploader)s -- %(upload_date)s -- %(title)s.%(ext)s"'
alias ytmp3='youtube-dl -f "bestaudio" -x --audio-format mp3 -o"%(uploader)s -- %(title)s.%(ext)s"'

alias mpv="devour mpv"
function myt() {
    url=$1
    url=$(echo $url | sed 's/invidious.snopyta.org/youtube.com/')
    url=$(echo $url | sed 's/subscriptions.gir.st/youtube.com/')

    mpv --ytdl --ytdl-raw-options=format="bestvideo[height<=?1080]+bestaudio/best[height<=1080]" "$url"
}
# * applications

alias feh="devour feh"

# easy file / directory search using `fd`
alias ff="\fd --type f"
alias fd="\fd --type d"

alias pf=" devour peerflix --start --mpv"

alias rtorrent=" rtorrent"
alias rtor=" \rtorrent"

alias py="python"
alias qr="qrcode-terminal"

alias srm=" srm -fllr"

alias pdf='devour zathura'
alias cloc="tokei"

# ** misc

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

# figure out which terminal emulator we're inside of
# echo $TERM does not always work, because sometimes term lies
whichterm() {
    ps -p $PPID | awk '{print $4}' | sed -n '2p'
}
# same goes for a shell
whichshell() {
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
del() {
    mv '$@' ~/.local/share/Trash/files/
}

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

freejob() {
    jobid=$(jobs -l | fzf | cut -d' ' -f1 | tr -d '[]')

    if [ $jobid -gt 0 ]; then
        bg "%$jobid"
        disown "%$jobid"
    fi
}

rot90() {
    [ $# -gt 0 ] || return 1
    for img in $@; do
        convert $img -rotate 90 $img
    done
}

myip() {
    local arg=$1

    local show_local=0
    local show_public=0

    if [[ $arg == "local" ]]; then
        show_local=1
    elif [[ $arg == "public" ]]; then
        show_public=1
    else
        show_local=1
        show_public=1
    fi

    if [[ $show_local -gt 0 ]]; then
        local local_ip=$(ifconfig wlp3s0 | grep inet | sed -n 1p | awk '{print $2}');
        echo "local: $local_ip";
    fi

    if [[ $show_public -gt 0 ]]; then
        # local public_ip=$(curl ipinfo.io &> /dev/null | sed -n 2p | sed 's/\"//g' | sed 's/\,//g' | awk '{print $2}');
        local public_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
        echo "public: $public_ip";
    fi
}

# run everything in docker?
# https://github.com/jessfraz/dotfiles/blob/master/.dockerfunc

video2webm () {
    local bitrate=$1;
    shift;
    for file in "$@"; do
        local out="${file%.*}.webm";

        ffmpeg -y -i "$file" -c:v libvpx-vp9 -b:v "$bitrate" -pass 1 -speed 4 \
               -c:a libopus -f webm /dev/null -async 1 -vsync passthrough
        ffmpeg -i "$file" -c:v libvpx-vp9 -b:v "$bitrate" -pass 2 -speed 1 -c:a \
               libopus "$out" -async 1 -vsync passthrough;
    done;
}

ffmpegnorm() {
    if [ -z "$1" ]; then
        echo "usage: ffmpegnorm [FILE(s)]"
        return 1
    fi

    for file in "$@"
    do
        echo "$file"

        FILE="$file"
        FILENAME=${FILE%.*}
        EXT=${FILE##*.}

        MONO_FILE="$FILENAME.mono.$EXT"
        NORM_FILE="$FILENAME.norm.$EXT"
        ffmpeg -i "$FILE" -ac 1 "$MONO_FILE"
        ffmpeg-normalize "$MONO_FILE" -o "$NORM_FILE" -c:a aac
    done
}

tarencrypt() {
    local archive=$1
    shift
    tar czvpf - $@ | gpg --symmetric --cipher-algo aes256 -o $archive.tar.gz.gpg
}

tardecrypt() {
    local archive=$1
    gpg -d $archive | tar xzvf -
}
