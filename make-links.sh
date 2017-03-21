# setup config files

ln -s $(pwd)/zsh/zshrc $HOME/.zshrc
ln -s $(pwd)/zsh/zprofile $HOME/.zprofile
ln -s $(pwd)/tmux.conf $HOME/.tmux.conf


# this fails if git has already been configured, which is better than
# overwriting configurations i guess.
ln -s $(pwd)/gitconfig $HOME/.gitconfig
