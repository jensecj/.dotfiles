autoload colors; colors;

function _user_host() {
    if [[ -n $SSH_CONNECTION ]]; then
        me="%n@%m"
    elif [[ $LOGNAME != $USER ]]; then
        me="%n"
    fi

    if [[ -n $me ]]; then
        echo "%{$fg[cyan]%}$me%{$reset_color%}: "
    fi
}

function _current_dir() {
    if [[ "$PWD" != "$HOME" ]] then
       echo "$FG[181]% %~ $FX[reset]"
    fi
}

function _prmpt() {
    if [[ "$PWD" = "$HOME" ]] then
        echo ">"
    else
        echo "\n>"
    fi
}

PROMPT='$(_user_host)$(_current_dir)$(_prmpt) '
