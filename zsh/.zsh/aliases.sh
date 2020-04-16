#!/bin/bash
# * changing defaults

# ** better ls
alias ls='ls --color=always --time-style="+%d-%m-%Y" --group-directories-first'
#alias l="ls -gholXN"
#alias ll="ls -agholXN"

alias l="exa --long --group-directories-first --time-style=long-iso"
alias ll="l --all --group"

alias free="free -h" # show sizes in a human readable format
alias grep='grep --color=always' # use colors in grep
alias diff="diff --color=always" # and diff
alias mkdir='mkdir -p -v' # make parent directories and tell us
alias df="df -h" # human-readable by default
alias bc="bc -q"
alias ssh-add="ssh-add -t 1h"
alias emacsd="emacs --no-site-file --daemon"

# ** common shortcuts
alias sudo='\sudo '
alias _='\sudo '
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias cp="rsync --verbose --human-readable --new-compress --archive --partial --progress"
alias mv="rsync --verbose --human-readable --new-compress --archive --partial --progress --remove-source-files"

alias escape="tr -cd '[:print:]'"

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

freejob() {
    jobid=$(jobs -l | fzf | cut -d' ' -f1 | tr -d '[]')

    if [ $jobid -gt 0 ]; then
        echo $jobid
        bg "%$jobid"
        disown "%$jobid"
    fi
}

bu() { cp "$1" "$1.bak"; }
mvbu() { mv "$1" "$1.bak"; }

mcd() { mkdir -p "$1"; cd "$1" || exit 1; }

del() {
    mv '$@' ~/.local/share/Trash/files/
}

lnk() {
    [ $# -eq 2 ] || return 1

    local src=$(realpath $1)
    local dst=$(realpath $2)
    echo "$src -> $dst"
    ln -s $src $dst
}

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

fman() {
    man -k . | fzf | awk '{print $1}' | xargs -r man
}

rot90() {
    [ $# -gt 0 ] || return 1
    for img in $@; do
        convert $img -rotate 90 $img
    done
}

# * aliases

# easy pacman
alias pac='yay'
alias pacu='pac -Syyu --combinedupgrade'
alias pacrm='pac -Rns'
alias pacss='pac -Ss'
alias pacs='pac -S'
alias pacls='pac -Qet'

paci() {
    pkg=$(yay -Sl | fzf --preview-window=top:70% --preview="yay -Si {2}" | awk '{print $2}')
    print -z $pkg
}

# misc
alias octave='octave-cli' # who uses the gui anyway?
alias pdf='zathura'

# easy file / directory search using `fd`
alias ff="fd --type f"
alias fd="fd --type d"

# place space first so we ignore history (make sure HIST_IGNORE_SPACE is set)
alias rtorrent=" rtorrent"
alias rtor=" rtorrent"

alias pf=" peerflix --start --mpv"

alias ytdl='youtube-dl -i -f "bestvideo[height<=?1080]+bestaudio/best" -o"%(uploader)s -- %(upload_date)s -- %(title)s.%(ext)s" --no-playlist --prefer-ffmpeg --postprocessor-args="-threads 2"'
alias ytdlp='ytdl --yes-playlist'
alias ytarc="ytdl --write-description --all-subs --embed-subs --add-metadata" # --embed-thumbnail does not work with .mkv yet
alias ytdlnr='ytdl -o"%(autonumber)s -- %(uploader)s -- %(upload_date)s -- %(title)s.%(ext)s"'
alias ytmp3='youtube-dl -f "bestvideo[height<=?480]+bestaudio" -x --audio-format mp3 -o"%(uploader)s -- %(title)s.%(ext)s"'

alias myt='mpv --ytdl --ytdl-raw-options=format="bestvideo[height<=?720]+bestaudio/best[height<=720]"'
alias mythq='mpv --ytdl --ytdl-raw-options=format="bestvideo[height<=?1080]+bestaudio/best[height<=1080]"'

alias py="python"
alias qr="qrcode-terminal"

alias srm=" srm -lr"
alias drop_cache="sudo sync; sudo sysctl -w vm.drop_caches=3"

alias rm="trash-put"
alias urm="trash-list | fzf | cut -d' ' -f3"

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

alias cl++="clang++ -std=c++17 -stdlib=libstdc++"
alias cl++mj="cl++ -MJ compile_commands.json"

alias dis="objdump -M intel -C -g -w -d"

alias cloc="tokei"
alias cook="cookiecutter"

video2webm () {
    local bitrate=$1;
    shift;
    for file in "$@"; do
        local out=${file%.*}.webm;

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

# quick compile/run with test data for hackathons
ccc() {
    clear && clang++ -std=c++17 "$1" -o "$1.out" && time "./$1.out" < test.in
}

md5dir() {
    if [ $# -lt 1 ]; then
        echo "usage: md5dir path/to/dir"
        return 1
    fi

    # calculate the md5sum for each file entry in $dir, sort that
    # list, and calculate the md5sum of that list, to get a reasonably
    # unique aggregate
    dir=$(readlink -f "$1")
    find "$dir" -type f -exec md5sum {} + | awk '{print $1}' | sort | md5sum | awk '{print $1}'
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

vpn-down() {
    running=$(ip addr | grep --color=never vpn | sed -n '2p' | xargs | cut -d' ' -f5)

    if [ -n "$running" ]; then
        sudo wg-quick down "$running"
    fi
}

alias mount_ramdisk="_ mount -t tmpfs -o size=1024m tmpfs /mnt/ramdisk"
alias umount_ramdisk="_ umount /mnt/ramdisk"
