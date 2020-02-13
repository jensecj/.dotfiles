#!/bin/sh

#########
# lines #
#########
drop() {
    val=$(echo "$1+1" | bc)
    tail -n +$val
}

take() {
    head -n $1
}

###########
# strings #
###########
upper_case() {
    tr '[:lower:]' '[:upper:]'
}
lower_case() {
    tr '[:upper:]' '[:lower:]'
}

prepend() {
    # why does this not work: $ echo "-" | prepend "kage"
    local val=$(cat -)
    echo -e "$1$val"
}
append() {
    local val=$(cat -)
    echo "$val$1"
}
wrap() {
    local val=$(cat -)
    if [ $# -eq 1 ]; then
        echo "$1$val$1"
    elif [ $# -eq 2 ]; then
        echo "$1$val$2"
    fi
}

substring() {
    local val=$(cat -)
    local val_len=$(echo "$val" | append "-1" | wc -c)
    local offset=${1:-0}
    local length=${2:-$val_len}

    echo "${val:$offset:$length}"
}

##############
# whitespace #
##############
ltrim() {
    sed -e 's/^[[:space:]]*//'
}
rtrim() {
    sed -e 's/[[:space:]]*$//'
}
trim() {
    sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

#########
# stack #
#########
speek() {
    head -n 1 "$1"
}
spush() {
    fil="$1"
    shift

    if [ -s "$fil" ]; then
        sed -i "1i$*" "$fil"
    else
        echo "$*" > "$fil"
    fi
}
spop() {
    fil="$1"
    val=$(speek "$fil")
    sed -i '1d' "$1"
    echo "$val"
}

#########
# queue #
#########
qpush () {
    fil="$1"
    shift

    echo "$*" >> "$fil"
}
qpop() {
    fil="$1"
    val=$(speek "$fil")
    sed -i '1d' "$1"
    echo "$val"
}
qpeek() {
    head -n 1 "$1"
}

###########
# aliases #
###########
alias shuffle=shuf
