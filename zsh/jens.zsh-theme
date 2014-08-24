PROMPT='
$(_user_host)${_current_dir} $(git_prompt_info)
$ '

local _current_dir="%{$fg_bold[blue]%}%3~%{$reset_color%} "

function _user_host() {
  if [[ -n $SSH_CONNECTION ]]; then
    me="%n@%m"
  elif [[ $LOGNAME != $USER ]]; then
    me="%n"
  fi
  if [[ -n $me ]]; then
    echo "%{$fg[cyan]%}$me%{$reset_color%}:"
  fi
}

# clean the default prefix and suffix
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""

# mark dirty repos
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[white]%}*%{$reset_color%}"
