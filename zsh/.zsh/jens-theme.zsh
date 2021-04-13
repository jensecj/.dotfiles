#!/bin/zsh

autoload colors; colors;

function _user_host() {
    if [ -n "$SSH_CONNECTION" ]; then
        me="%n@%m"
    elif [ "$LOGNAME" != "$USER" ]; then
        me="%n"
    fi

    if [ -n "$me" ]; then
        echo "%F{cyan}$me%f: "
    fi
}

function _current_dir() {
    if [ "$PWD" != "$HOME" ]; then
        cwd=$(realpath "$(pwd)" --relative-base="$HOME")
        echo "%F{181}$cwd%f"
    fi
}

function _virtuel_env() {
    if [ -n "$VIRTUAL_ENV" ]; then
        local name=$(basename "$VIRTUAL_ENV")
        echo "%F{green}($name) %f"
    fi
}

function _git_branch() {
    in_git_repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"
    if [ -n "$in_git_repo" ]; then
        local branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
        local is_dirty=$(git status --porcelain 2> /dev/null | tail -n1)
        if [ -n "$is_dirty" ]; then
            echo " %F{yellow}($branch*)%f"
        else
            echo " %F{yellow}($branch)%f"
        fi
    fi
}

function _split() {
    if [ "$PWD" != "$HOME" ]; then
        # HACK: there is a zero-width space on both sides of the newline, otherwise printf does nothing
        printf "​\n​"
    else
        printf ""
    fi
}

# the zsh equivalent to bash PROMPT_COMMAND
function precmd() {
    PROMPT="$(_virtuel_env)$(_user_host)$(_current_dir)$(_git_branch)$(_split)%(?..%? )\$ "
}

# disable pythons virtualenv prompt mutation
export VIRTUAL_ENV_DISABLE_PROMPT=1
