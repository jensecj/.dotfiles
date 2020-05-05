
# .zshenv -> .zprofile -> .zshrc -> .zlogin -> ... -> .zlogout
# order:

[[ $TERM == "dumb" ]] && unsetopt zle && PS1="\$ " && return

# uncomment to profile zsh
# zmodload zsh/zprof

# save our command history
HISTSIZE=100000
HISTFILESIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

# enable edit-then-execute binding
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X' edit-command-line

# use bash selection, so killing stops at delimiters
autoload -Uz select-word-style && {
    select-word-style bash
}

source $ZSHHOME/stdlib.sh

# load plugins
source $ZSHPLUGINS/spectrum.sh
source $ZSHPLUGINS/colored-man-pages.sh
source $ZSHPLUGINS/setup-zsh-completions.sh # FIXME: does this work?
source $ZSHPLUGINS/setup-zsh-syntax-highlighting.sh
source $ZSHPLUGINS/setup-zsh-autosuggestions.sh
eval "$(zoxide init zsh)"

# color directories/files
eval $(dircolors -b "$HOME/.dircolors")

# start the ssh daemon, and load keys into it
eval $(keychain --eval --quiet --agents ssh \
                ~/.ssh/github \
                ~/.ssh/sourcehut \
                ~/.ssh/termux)

source $ZSHHOME/autocomplete-setup.sh
source $ZSHHOME/keybindings.zsh
source $ZSHHOME/aliases.sh
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


source /usr/share/fzf/completion.zsh

eval "$(pyenv init -)"

# uncomment to profile zsh
# zprof
