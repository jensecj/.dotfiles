alias ls='ls --color=always --time-style="+%d-%m-%Y" --group-directories-first'

alias l="ls -gholX"
alias ll="ls -agholX"

alias _='sudo'
alias ..='cd ..'

alias netsw='sudo netctl switch-to'
alias ytmp3='youtube-dl -x --audio-format mp3'
alias dl='aria2c'

alias vncshow='echo listening on && wget -qO- http://ipecho.net/plain && echo :0 && x0vncserver -display :0 -passwordfile ~/.vnc/passwd -acceptkeyevents=0 -acceptpointerevents=0 -alwaysshared'
alias vncview='vncviewer'

alias git='hub'

alias ya='yaourt'
alias yau='ya -Syua'
alias yarm='ya -Rns'
alias yass='ya -Ss'
alias yas='ya -S'
