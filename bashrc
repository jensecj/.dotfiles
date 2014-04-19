# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias l='ls -gohX --group-directories-first'
alias ll='ls -AghoX --group-directories-first'
PS1='[\u@\h \W]\$ '
