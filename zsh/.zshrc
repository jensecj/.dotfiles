# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="jens"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(git)

source $ZSH/oh-my-zsh.sh

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/vendor_perl:/usr/bin/core_perl"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Aliases
alias ls='ls --color=auto'
alias l='ls -gohX --group-directories-first'
alias ll='ls -AghoX --group-directories-first'

alias netsw='sudo netctl switch-to'
alias ytmp3='youtube-dl -x --audio-format mp3'
alias dl='aria2c'

alias vncshow='echo listening on && wget -qO- http://ipecho.net/plain && echo :0 && x0vncserver -display :0 -passwordfile ~/.vnc/passwd -acceptkeyevents=0 -acceptpointerevents=0 -alwaysshared'
alias vncview='vncviewer'
