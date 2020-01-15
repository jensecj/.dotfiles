
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
autoload edit-command-line
zle -N edit-command-line
bindkey '^X' edit-command-line

# use bash selection, so killing stops at delimiters
autoload -U select-word-style && {
    select-word-style bash
}

source $ZSHHOME/stdlib.sh

# load plugins
source $ZSHPLUGINS/z.sh
source $ZSHPLUGINS/colored-man-pages.sh
source $ZSHPLUGINS/spectrum.sh
source $ZSHPLUGINS/zsh-autosuggestions.sh
source $ZSHPLUGINS/zsh-completions.sh
source $ZSHPLUGINS/zsh-syntax-highlighting.sh

# color directories/files
eval $(dircolors -b "$HOME/.dircolors")

# start the ssh daemon, and load keys into it
eval $(keychain --eval --quiet --agents ssh \
                ~/.ssh/github \
                ~/.ssh/sourcehut \
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

source /usr/share/fzf/completion.zsh

eval "$(pyenv init -)"

# uncomment to profile zsh
# zprof
