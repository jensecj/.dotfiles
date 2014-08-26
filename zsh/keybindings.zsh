# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

bindkey -e # Use emacs key bindings

if [[ "${terminfo[kcuu1]}" != "" ]]; then
  bindkey "${terminfo[kcuu1]}" up-line-or-search      # start typing + <Up-Arrow> - fuzzy find history forward
fi
if [[ "${terminfo[kcud1]}" != "" ]]; then
  bindkey "${terminfo[kcud1]}" down-line-or-search    # start typing + <Down-Arrow> - fuzzy find history backward
fi

bindkey ' ' magic-space                               # <Space> - do history expansion

bindkey '^[[1;5C' forward-word                        # <C-RightArrow> - move forward one word
bindkey '^[[1;5D' backward-word                       # <C-LeftArrow> - move backward one word

insert-tilde()                                        # <Menu> inserts a ~
{
  zle -U "~"
}
zle -N insert-tilde
bindkey "9~" insert-tilde

kill-region-or-line()
{
  if [[ "$MARK" -eq 0 || "$MARK" -eq "$CURSOR" ]]; then
    zle .kill-whole-line
  else
    zle .kill-region
  fi
}
zle -N kill-region-or-line
bindkey '^w' kill-region-or-line                      # [C-w] - Kill from the cursor to the mark, or the whole line

if [[ "${terminfo[kcbt]}" != "" ]]; then
  bindkey "${terminfo[kcbt]}" reverse-menu-complete   # <Shift-Tab> - move through the completion menu backwards
fi

bindkey '^?' backward-delete-char                     # <Backspace> - delete backward
