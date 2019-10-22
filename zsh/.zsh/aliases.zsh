#!/bin/zsh
# * changing defaults

# ** better ls
alias ls='ls --color=always --time-style="+%d-%m-%Y" --group-directories-first'
#alias l="ls -gholXN"
#alias ll="ls -agholXN"

alias l="exa --long --group-directories-first --time-style=long-iso"
alias ll="l --all"

# ** prefer interactive use, and human-readable outputs
alias cp="cp -i" # ask before overwriting files
alias mv="mv -i" # ask before overwriting files
alias free="free -h" # show sizes in a human readable format
alias grep='grep --color=always' # use colors in grep
alias diff="diff --color=always" # and diff
alias mkdir='mkdir -p -v' # make parent directories and tell us
alias df="df -h" # human-readable by default

# ** common shortcuts
alias _='sudo'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# * extra functions

# figure out which terminal emulator we're inside of
# echo $TERM does not always work, because sometimes term lies
function whichterm() {
    ps -p $PPID | awk '{print $4}' | sed -n '2p'
}
# same goes for a shell
function whichshell() {
    ps -p "$$" | awk '{print $4}' | sed -n '2p'
}

function bu() { cp "$1" "$1.bak"; }
function mcd() { mkdir "$1"; cd "$1" || exit 1; }

function del() {
    mv '$@' ~/.local/share/Trash/files/
}

# easily create tar.gz archives, with progress bar
function tarczf () {
    tar cf - "${@:2}" -P | pv -s $(du -sb "${@:2}" | awk '{print $1}' | paste -sd+ - | bc) | gzip > "$1"
}

# * fzf functions

function fzf-cd() {
    cd $(fd | fzf --no-multi)
    zle clear-screen
}
zle -N fzf-cd

function fzf-z() {
    cd $(z | awk '{print $2}' | fzf --no-sort --no-multi)
    zle clear-screen
}
zle -N fzf-z

function fzf-locate() {
    locate | fzf | xargs | xsel -i
}
zle -N fzf-locate

function fzf-history() {
    BUFFER=$(history -n -r 1 | fzf --no-sort --no-multi --query "$LBUFFER")
    CURSOR=$#BUFFER
}
zle -N fzf-history

function fzf-urls() {
    # look at all scrollback contents of tmux buffer, and copy
    # selected url to clipboard
    local url_regex="(((http|https|ftp|gopher|git)|mailto)[.:@][^ >\"\t]*|www\.[-a-z0-9.]+)[^ .,;\t>\">\):]"
    tmux capture-pane -pS -100000 \
        | rg --no-filename --no-line-number "$url_regex" \
        | fzf --no-sort --no-multi \
        | xargs \
        | xsel -i
}
zle -N fzf-urls

function fman() {
    man -k . | fzf | awk '{print $1}' | xargs -r man
}

# * stack based functions
function speek() {
    head -n 1 "$1"
}
function spush() {
    local fil="$1"
    shift

    if [ -s "$fil" ]; then
        sed -i "1i$*" "$fil"
    else
        echo "$*" > "$fil"
    fi
}
function spop() {
    local fil="$1"
    local val=$(speek "$fil")
    sed -i '1d' "$1"
    echo "$val"
}

# * queue based functions
function qpush () {
    local fil="$1"
    shift

    echo "$*" >> "$fil"
}
function qpop() {
    local fil="$1"
    local val=$(speek "$fil")
    sed -i '1d' "$1"
    echo "$val"
}
function qpeek() {
    head -n 1 "$1"
}

# * aliases

# easy pacman
alias pac='yay'
alias pacu='pac -Syu --combinedupgrade'
alias pacrm='pac -Rns'
alias pacss='pac -Ss'
alias pacs='pac -S'
alias pacls='pac -Qet'
function paci() {
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

alias git="hub"

alias zt="zerotier-cli"

alias rcp="rsync --verbose --human-readable --new-compress --archive --partial --progress"
alias rmv="rsync --verbose --human-readable --new-compress --archive --partial --progress --remove-source-files"

alias pf=" peerflix --start --mpv"
alias dl='snatch --threads 4'

alias ytdl='youtube-dl -f "bestvideo[height<=?1080]" -o"%(uploader)s -- %(title)s.%(ext)s"'
alias ytdlnr='youtube-dl -f "bestvideo[height<=?1080]" -o"%(autonumber)s -- %(uploader)s -- %(title)s.%(ext)s"'
alias ytmp3='youtube-dl -f "bestvideo[height<=?480]+bestaudio" -x --audio-format mp3 -o"%(uploader)s -- %(title)s.%(ext)s"'

function sbclmk () {
    if [[ -z $1 ]]; then
        echo "usage: sbclmk <path/to/project>";
        return 1;
    fi

    echo "creating project $1"
    sbcl --noinform \
         --eval "(ql:quickload \"cl-project\")" \
         --eval "(cl-project:make-project #p\"$1\")" \
         --eval "(exit)"
}

alias fm="ranger"
alias sl="streamlink --player=mpv --player-no-close --player-continuous-http --title '{title} - {url}'"
alias myt="mpv --ytdl"
alias py="python"
alias qr="qrcode-terminal"

function myip() {
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

function start_xidlehook() {
    nohup xidlehook \
          --timer normal 180 "dimmer 3000" "dimmer pop" \
          --timer primary 10 "dimmer pop; slock" "" \
          --not-when-fullscreen --not-when-audio \
          >>& ~/.xidlehook.log & disown
}

alias rtags='rc -J'
alias rtagsd='rdm'


alias cl++="clang++ -std=c++17 -stdlib=libstdc++"
alias cl++mj="cl++ -MJ compile_commands.json"

alias dis="objdump -M intel -C -g -w -d"

alias cloc="tokei"
alias cook="cookiecutter"

function video2webm () {
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

function ffmpegnorm {
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
function ccc {
    clear && clang++ -std=c++17 "$1" -o "$1.out" && time "./$1.out" < test.in
}

function md5dir() {
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

ping() {
    local i=0
    local options=""
    local host=""

    for arg
    do
        i=$(($i+1))
        if [ "$i" -lt "$#" ]
        then
            options="${options} ${arg}"
        else
            host="${arg}"
        fi
    done

    # lookup host in .ssh/config
    local hostname=$(awk "\$1==\"Host\" {host=\$2} \$1==\"HostName\" && host==\"${host}\" {print \$2}" "$HOME/.ssh/config")
    if [ -z "$hostname" ]
    then
        hostname="$host"
    fi

    /bin/ping $options "$hostname"
}

alias mount_ramdisk="_ mount -t tmpfs -o size=1024m tmpfs /mnt/ramdisk"
alias umount_ramdisk="_ umount /mnt/ramdisk"
