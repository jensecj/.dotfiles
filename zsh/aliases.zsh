# better ls
alias ls='ls --color=always --time-style="+%d-%m-%Y" --group-directories-first'
alias l="ls -gholXN"
alias ll="ls -agholXN"

# some very common shortcuts
alias _='sudo'
alias ..='cd ..'

# easy pacman
alias ya='yaourt'
alias yau='ya -Syua'
alias yarm='ya -Rns'
alias yass='ya -Ss'
alias yas='ya -S'

# misc
alias octave='octave-cli' # who uses the gui anyway?

alias rcp="rsync --verbose --progress"
alias rmv="rsync --verbose --progress --remove-source-files"

alias pf="peerflix --start --mpv"
alias dl='snatch --threads 4'
alias ytdl='youtube-dl -o"%(uploader)s -- %(title)s.%(ext)s"'
alias ytmp3='youtube-dl -x --audio-format mp3 -o"%(uploader)s -- %(title)s.%(ext)s"'

alias fm="ranger"
alias sl="streamlink --player=mpv"
alias myt="mpv --ytdl"
alias py="python"

alias start_dnscrypt="_ dnscrypt-proxy /etc/dnscrypt-proxy.conf"

alias cl++="clang++ -std=c++14"

# functions
function ccc {
    clear && clang++ -std=c++14 $1 && time cat test.in | ./a.out
}
