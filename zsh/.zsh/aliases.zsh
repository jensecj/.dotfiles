# better ls
alias ls='ls --color=always --time-style="+%d-%m-%Y" --group-directories-first'
alias l="ls -gholXN"
alias ll="ls -agholXN"

# preferred defaults
alias cp="cp -i" # ask before overwriting files
alias mv="mv -i" # ask before overwriting files
alias free="free -h" # show sizes in a human readable format
alias grep='grep --color=always' # use colors in grep
alias diff="diff --color=always" # and diff
alias mkdir='mkdir -p -v' # make parent directories and tell us
alias df="df -h" # human-readable by default
function bu() { cp "$1" "$1.bak"; }
function mcd() { mkdir "$1"; cd "$1" || exit 1; }

# some common shortcuts
alias _='sudo'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

function del() {
    mv '$@' ~/.local/share/Trash/files/
}

# easily create tar.gz archives, with progress bar
function tarczf () {
    tar cf - "${@:2}" -P | pv -s $(du -sb "${@:2}" | awk '{print $1}' | paste -sd+ - | bc) | gzip > "$1"
}

# easy pacman
alias pac='yay'
alias pacu='pac -Syu --combinedupgrade'
alias pacrm='pac -Rns'
alias pacss='pac -Ss'
alias pacs='pac -S'
alias pacls='pac -Qet'

# misc
alias octave='octave-cli' # who uses the gui anyway?
alias flux='xgamma -gamma 1 && redshift -O '
alias pdf='zathura'

# easy file / directory search using `fd`
alias ff="fd --type f"
alias fd="fd --type d"

# place space first so we ignore history (make sure HIST_IGNORE_SPACE is set)
alias rtorrent=" rtorrent"
alias rtor=" rtorrent"

alias git="hub"

alias rcp="rsync --verbose --human-readable --new-compress --archive --partial --progress"
alias rmv="rsync --verbose --human-readable --new-compress --archive --partial --progress --remove-source-files"

alias pf="peerflix --start --mpv"
alias dl='snatch --threads 4'
alias ytdl='youtube-dl -o"%(uploader)s -- %(title)s.%(ext)s"'
alias ytdlnr='youtube-dl -o"%(autonumber)s -- %(uploader)s -- %(title)s.%(ext)s"'

alias ytmp3='youtube-dl -x --audio-format mp3 -o"%(uploader)s -- %(title)s.%(ext)s"'

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
alias sl="streamlink --player=mpv"
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

alias start_dnscrypt="_ dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml"
alias start_xidlehook="xidlehook \
                       --time 10 \
                       --timer 'redshift -O 3500; slock' \
                       --notify 10 \
                       --notifier 'redshift -O 2800' \
                       --canceller 'redshift -O 3500' \
                       --not-when-fullscreen"

alias rtags='rc -J'
alias rtagsd='rdm'

alias cl++="clang++ -std=c++17 -stdlib=libstdc++"
alias cl++mj="cl++ -MJ compile_commands.json"
function fixmj () {
    if [ -z "$1" ]
    then
        echo "usage: fixmj <compilation database file>";
        return;
    else
        sed -i -e '1s/^/[\n/' -e '$s/,$/\n]/' "$1"
    fi
}

alias dis="objdump -M intel -C -g -w -d"

alias cloc="tokei"
alias cook="cookiecutter"

# quick compile/run with test data for hackathons
function ccc {
    clear && clang++ -std=c++17 "$1" -o "$1.out" && time "./$1.out" < test.in
}

# figure out which terminal emulator we're inside of
# echo $TERM does not always work, because sometimes term lies
function whichterm() {
    ps -p $PPID | awk '{print $4}' | sed -n '2p'
}
# same goes for a shell
function whichshell() {
    ps -p "$$" | awk '{print $4}' | sed -n '2p'
}

# create a note file for another file
function note() {
    if [ -z "$1" ]
    then
        echo "usage: note <file>"
    else
        $EDITOR "$1.note"
    fi
}

alias mount_ramdisk="_ mount -t tmpfs -o size=1024m tmpfs /mnt/ramdisk"
alias umount_ramdisk="_ umount /mnt/ramdisk"
