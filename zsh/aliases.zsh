# better ls
alias ls='ls --color=always --time-style="+%d-%m-%Y" --group-directories-first'
alias l="ls -gholXN"
alias ll="ls -agholXN"

# some very common shortcuts
alias _='sudo'
alias ..='cd ..'

# a collection of random commands

alias netsw='sudo netctl switch-to'

alias ytdl='youtube-dl -o"%(uploader)s -- %(title)s.%(ext)s"'
alias ytmp3='youtube-dl -x --audio-format mp3 -o"%(uploader)s -- %(title)s.%(ext)s"'

alias dl='snatch --threads 4'

# alias git='hub'

alias ya='yaourt'
alias yau='ya -Syua'
alias yarm='ya -Rns'
alias yass='ya -Ss'
alias yas='ya -S'

alias octave='octave-cli' # who uses the gui anyway?

alias rcp="rsync --verbose --progress"
