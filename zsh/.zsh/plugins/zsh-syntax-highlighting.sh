#!/bin/sh

# this needs to be loaded after all other plugins
. $ZSHHOME/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh && {
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
