#!/bin/zsh

# this needs to be loaded after all other plugins
source $ZSHHOME/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red,bold
ZSH_HIGHLIGHT_STYLES[arg0]=none
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[alias]=fg=green
ZSH_HIGHLIGHT_STYLES[builtin]=fg=green
ZSH_HIGHLIGHT_STYLES[function]=fg=green
ZSH_HIGHLIGHT_STYLES[command]=fg=green
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=174
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=174
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=174
