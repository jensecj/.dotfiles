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

# Use emacs key bindings
bindkey -e

if [[ "${terminfo[kcuu1]}" != "" ]]; then
    # start typing + <Up-Arrow> - fuzzy find history forward
    bindkey "${terminfo[kcuu1]}" up-line-or-search
fi
if [[ "${terminfo[kcud1]}" != "" ]]; then
    # start typing + <Down-Arrow> - fuzzy find history backward
    bindkey "${terminfo[kcud1]}" down-line-or-search
fi

# <Space> - do history expansion
bindkey ' ' magic-space

# # <C-UpArrow> - scroll up
# bindkey ';5A'
# # <C-DownArrow> - scroll down
# bindkey ';5B'

# <C-RightArrow> - move forward one word
bindkey ';5C' forward-word
# <C-LeftArrow> - move backward one word
bindkey ';5D' backward-word

# <Menu> inserts a ~
# insert-tilde()
# {
#     zle -U "~"
# }
# zle -N insert-tilde
# bindkey "9~" insert-tilde
# bindkey "9~" insert-tilde

# <C-w> kills region or whole line
kill-region-or-line()
{
    if [[ "$MARK" -eq 0 || "$MARK" -eq "$CURSOR" ]]; then
        zle .kill-whole-line
    else
        zle .kill-region
    fi
}
zle -N kill-region-or-line
bindkey '^w' kill-region-or-line

if [[ "${terminfo[kcbt]}" != "" ]]; then
    # <Shift-Tab> - move through the completion menu backwards
    bindkey "${terminfo[kcbt]}" reverse-menu-complete
fi

# <backspace> - delete backward
bindkey '^?' backward-delete-char
# <C-Backspace> - kill word backwards
bindkey '^H' backward-kill-word

# <del> - delete forwards
bindkey '^[[3~' delete-char
# <C-del> - kill word forwards
bindkey '^[[3;5~' kill-word
