
# .zshenv -> .zprofile -> .zshrc -> .zlogin -> ... -> .zlogout
# order:

[[ $TERM == "dumb" ]] && unsetopt zle && PS1="\$ " && return

# uncomment to profile zsh
# zmodload zsh/zprof

# save our command history
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
# print usage statistics for commands that take longer than 5 seconds to complete
REPORTTIME=5

# enable edit-then-execute binding
autoload edit-command-line
zle -N edit-command-line
bindkey '^Xe' edit-command-line

# use bash selection, so killing stops at delimiters
autoload -U select-word-style && {
    select-word-style bash
}

# load plugins
for p in $ZSHHOME/plugins/*.sh; do
    source $p
done

# this needs to be loaded after all other plugins
source $ZSHHOME/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh && {
    # change some default highlighter values to fit with zenburn, and my
    # preferences. may need to go to main-highlighter.zsh and uncomment the changes
    # styles after an update.
    : ${ZSH_HIGHLIGHT_STYLES[path]:=none}
    : ${ZSH_HIGHLIGHT_STYLES[globbing]:=fg=none,bold}
    : ${ZSH_HIGHLIGHT_STYLES[arg0]:=fg=151}
    : ${ZSH_HIGHLIGHT_STYLES[reserved-word]:=fg=228}
    : ${ZSH_HIGHLIGHT_STYLES[single-quoted-argument]:=fg=174}
    : ${ZSH_HIGHLIGHT_STYLES[double-quoted-argument]:=fg=174}
    : ${ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]:=fg=174}
}
# color directories/files
eval $(dircolors -b $HOME/.dircolors)

# start the ssh daemon, and load keys into it
eval $(keychain --eval --quiet --agents ssh \
                ~/.ssh/github \
                ~/.ssh/stuetop \
                ~/.ssh/termux)

source $ZSHHOME/autocomplete-setup.sh
source $ZSHHOME/keybindings.zsh
source $ZSHHOME/aliases.zsh
source $ZSHHOME/options.zsh
source $ZSHHOME/jens-theme.zsh

# use direnv to allow directory specific exports
# eval "$(direnv hook zsh)"

autoload -U zrecompile
# Compile zcompdump, if modified, to increase startup speed.
if [ "$HOME/.zcompdump" -nt "$HOME/.zcompdump.zwc" -o ! -e "$HOME/.zcompdump.zwc" ]; then
    zcompile "$HOME/.zcompdump"
fi
# zrecompile -p $HOME/.zshrc &>/dev/null
bindkey -M emacs '^F' fzf-cd
bindkey -M emacs '^R' fzf-history
bindkey -M emacs '^U' fzf-urls
bindkey -M emacs '^B' fzf-z
bindkey -M emacs '\ei' fzf-locate


# uncomment to profile zsh
# zprof
