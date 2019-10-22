# this uses the spectrum.sh plugin to make working with colors easier.

autoload colors; colors;

function _user_host() {
    if [[ -n $SSH_CONNECTION ]]; then
        me="%n@%m"
    elif [[ $LOGNAME != "$USER" ]]; then
        me="%n"
    fi

    if [[ -n $me ]]; then
        echo "%{$fg[cyan]%}$me%{$reset_color%}: "
    fi
}

function _current_dir() {
    if [[ "$PWD" != "$HOME" ]]; then
        echo "$FG[181]% %~ $FX[reset]"
    fi
}

function _virtuel_env() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        local name=$(basename "$VIRTUAL_ENV")
        echo "%{$fg[green]%}($name) %{$reset_color%}"
    fi
}

function _git_branch() {
    in_git_repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"
    if [[ "$in_git_repo" ]]; then
        local branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
        local is_dirty=$(git status --porcelain 2> /dev/null | tail -n1)
        if [[ "$is_dirty" ]]; then
            echo "%{$fg[yellow]%}($branch*)%{$reset_color%}"
        else
            echo "%{$fg[yellow]%}($branch)%{$reset_color%}"
        fi
    fi
}

function _split() {
    if [[ "$PWD" != "$HOME" ]]; then
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
