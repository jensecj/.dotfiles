#!/bin/sh

_add_color() {
    local MAX_WIDTH=100

    local width="${COLUMNS:-100}"
    (( width > $MAX_WIDTH )) && width=$MAX_WIDTH

    # termcap terminology:
    # mb = start blink
    # md = start bold
    # me = turn off bold, blink and underline
    # so = start standout
    # se = stop standout
    # us = start underline
    # ue = stop underline

    # pick colors that resemble zenburn
	  command env \
            LESS_TERMCAP_mb=$(printf "\e[1;31m") \
            LESS_TERMCAP_md=$(printf "\e[01;38;5;223m") \
            LESS_TERMCAP_me=$(printf "\e[0m") \
            LESS_TERMCAP_so=$(printf "\e[01;38;5;108m") \
            LESS_TERMCAP_se=$(printf "\e[0m") \
            LESS_TERMCAP_ue=$(printf "\e[0m") \
            LESS_TERMCAP_us=$(printf "\e[01;38;5;174m") \
		        PAGER="${commands[less]:-$PAGER}" \
		        _NROFF_U=1 \
		        PATH="$HOME/bin:$PATH" \
            MANWIDTH="$width" \
			      "$@"
}

man() {
	  _add_color man "$@"
}
