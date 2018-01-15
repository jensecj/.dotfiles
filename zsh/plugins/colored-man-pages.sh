if [[ "$OSTYPE" = solaris* ]]
then
    if [[ ! -x "$HOME/bin/nroff" ]]
    then
        mkdir -p "$HOME/bin"
        cat > "$HOME/bin/nroff" <<EOF
#!/bin/sh
if [ -n "\$_NROFF_U" -a "\$1,\$2,\$3" = "-u0,-Tlp,-man" ]; then
        shift
        exec /usr/bin/nroff -u\$_NROFF_U "\$@"
fi
#-- Some other invocation of nroff
exec /usr/bin/nroff "\$@"
EOF
        chmod +x "$HOME/bin/nroff"
    fi
fi

function man() {
    # restrict man-page to a width of 100 columns, makes it a lot easier to read
    # on big screens
    local width="${COLUMNS:-100}"
    (( width > 100 )) && width=100

    # termcap terminology:
    # mb = start blink
    # md = start bold
    # me = turn off bold, blink and underline
    # so = start standout
    # se = stop standout
    # us = start underline
    # ue = stop underline

    # set man-page colors to something resembling zenburn
    env \
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
        man "$@"
}
