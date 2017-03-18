# setup config files

ln -s $(pwd)/zsh/zshrc ~/.zshrc
ln -s $(pwd)/zsh/zprofile ~/.zprofile
ln -s $(pwd)/tmux.conf ~/.tmux.conf

# this fails if git has already been configured, which is better than
# overwriting configurations i guess.
ln -s $(pwd)/gitconfig ~/.gitconfig 
