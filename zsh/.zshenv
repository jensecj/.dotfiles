# exports, common paths, etc.
export DOTFILESHOME=$HOME/.dotfiles
export ZSHHOME=$HOME/.zsh
export ZSHPLUGINS=$ZSHHOME/plugins

export EDITOR=em # emacsclient, this scripts starts the daemon if needed
export BROWSER=firefox-developer-edition
export TERMINAL=alacritty
export DIFFPROG=emdiff

export LANG="en_DK.UTF-8"

# make gpg happy, needed for git signing from terminal
export GPG_TTY=$(tty)

export PROMPT_EOL_MARK=''

# ggtags config
export GTAGSLABEL="ctags"
export GTAGSCONF="$HOME/.globalrc"

# tldr config
export TLDR_COLOR_NAME="white bold"
export TLDR_COLOR_DESCRIPTION="white bold"
export TLDR_COLOR_COMMAND="yellow bold"
export TLDR_COLOR_PARAMETER="white"
export TLDR_CACHE_ENABLED=1
export TLDR_CACHE_MAX_AGE=720

export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_DEFAULT_OPTS="--prompt='>> '"

export EXA_COLORS="da=38;5;7:*.org=38;5;184:uu=0:gu=0"
export RANGER_LOAD_DEFAULT_RC="FALSE"
export PIP_REQUIRE_VIRTUALENV="true"

export WINIT_X11_SCALE_FACTOR=1

export GOPATH=$HOME/.go

export TIMEFMT=''$'\n%J'$'\n%U user | %S system | %P cpu | %*Es total'$'\n'\
'avg. shared (code):         %X KB'$'\n'\
'avg. unshared (data/stack): %D KB'$'\n'\
'total space usage:          %K KB'$'\n'\
'max memory usage:           %M KB'$'\n'\
'swaps:                      %W'$'\n'\
'major page faults (disk):   %F'$'\n'\
'minor page faults:          %R'

# add things to PATH
paths=("$DOTFILESHOME/bin"
       "$HOME/.cargo/bin"
       "$HOME/.roswell/bin")

for p in $paths; do
    export PATH=${PATH}:${p}
done
