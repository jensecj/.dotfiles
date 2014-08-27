alias ls='ls --color=always --time-style="+%d-%m-%Y" --group-directories-first'

l() { ls -gohX $* | tr -s " " | cut -d" " -f3- | sed "/ /s//\t/" }
ll() { ls -AgohX $* | tr -s " " | cut -d" " -f3- | sed "/ /s//\t/" }

alias _='sudo'
alias ..='cd ..'

alias netsw='sudo netctl switch-to'
alias ytmp3='youtube-dl -x --audio-format mp3'
alias dl='aria2c'

alias vncshow='echo listening on && wget -qO- http://ipecho.net/plain && echo :0 && x0vncserver -display :0 -passwordfile ~/.vnc/passwd -acceptkeyevents=0 -acceptpointerevents=0 -alwaysshared'
alias vncview='vncviewer'
