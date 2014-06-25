# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias l='ls -gohX --group-directories-first'
alias ll='ls -AghoX --group-directories-first'

alias netsw='sudo netctl switch-to'
alias ytmp3='youtube-dl -x --audio-format mp3'
alias dl='aria2c'

alias vncshow='echo listening on && wget -qO- http://ipecho.net/plain && echo :0 && x0vncserver -display :0 -passwordfile ~/.vnc/passwd -acceptkeyevents=0 -acceptpointerevents=0 -alwaysshared'
alias vncview='vncviewer'

PS1='[\u@\h \W]\$ '
