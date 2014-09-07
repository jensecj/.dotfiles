# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export ZSHHOME=$HOME/.dotfiles/zsh

# Disable marking untracked files under VCS as dirty.
# This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(git)

source $ZSH/oh-my-zsh.sh

paths=("/home/jens/.gem/ruby/2.1.0/bin")

for p in $paths; do
    export PATH=${PATH}:${p}
done

source $ZSHHOME/keybindings.zsh
source $ZSHHOME/aliases.zsh
source $ZSHHOME/options.zsh
source $ZSHHOME/jens-theme.zsh
