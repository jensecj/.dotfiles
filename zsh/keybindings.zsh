insert-tilde() { zle -U "~" }
zle -N insert-tilde
bindkey "9~" insert-tilde
