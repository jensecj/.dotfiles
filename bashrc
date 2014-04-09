# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias l='ls -gholX'
alias ll='ls -agholX'
PS1='[\u@\h \W]\$ '
