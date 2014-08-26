alias ls='ls --color=always --time-style="+%d-%m-%Y" --group-directories-first'

l() { ls -gohX $* | awk "{if (NR!=1) {printf (\"%s\t%s %s\n\", \$3, \$4, \$5)}}" }
ll() { ls -AgohX $* | awk "{if (NR!=1) {printf (\"%s\t%s %s\n\", \$3, \$4, \$5)}}" }

alias _='sudo'
alias ..='cd ..'

alias netsw='sudo netctl switch-to'
alias ytmp3='youtube-dl -x --audio-format mp3'
alias dl='aria2c'

alias vncshow='echo listening on && wget -qO- http://ipecho.net/plain && echo :0 && x0vncserver -display :0 -passwordfile ~/.vnc/passwd -acceptkeyevents=0 -acceptpointerevents=0 -alwaysshared'
alias vncview='vncviewer'
