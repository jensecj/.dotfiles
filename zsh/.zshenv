# exports, common paths, etc.
export DOTFILESHOME=$HOME/.dotfiles
export ZSHHOME=$HOME/.zsh
export ZSHPLUGINS=$ZSHHOME/plugins

export EDITOR=em
export VISUAL=em
export BROWSER=firefox-developer-edition
export TERMINAL=alacritty
export DIFFPROG=emdiff

export LANG="en_DK.UTF-8"

# use gpg for git signing from terminal, ssh, etc
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
gpg-connect-agent updatestartuptty /bye >/dev/null

export PROMPT_EOL_MARK=''
unsetopt PROMPT_SP

export GRAVEYARD="$HOME/.local/share/Trash"

# tldr config
export TLDR_COLOR_NAME="white bold"
export TLDR_COLOR_DESCRIPTION="white bold"
export TLDR_COLOR_COMMAND="yellow bold"
export TLDR_COLOR_PARAMETER="white"
export TLDR_CACHE_ENABLED=1
export TLDR_CACHE_MAX_AGE=720

export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_DEFAULT_OPTS="--prompt='>> '"
# export FZF_DEFAULT_OPTS="--prompt='>> ' --bind=ctrl-bspace:backward-kill-word" # not supported yet

export LEIN_JVM_OPTS="${LEIN_JVM_OPTS-"-XX:+TieredCompilation -XX:TieredStopAtLevel=1"}"

export HIGHLIGHT_THEME="zenburn"
export EXA_COLORS="da=38;5;7:*.org=38;5;184:uu=0:gu=0"
export RANGER_LOAD_DEFAULT_RC="FALSE"
export PIP_REQUIRE_VIRTUALENV="true"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

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

paths=("$HOME/.local/bin")
for p in $paths; do
    export PATH=${PATH}:${p}
done
