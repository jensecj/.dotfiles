# setup config files

ln -s $(pwd)/zsh/zshrc ~/.zshrc

# this fails if git has already been configured, which is better than
# overwriting configurations i guess.
ln -s $(pwd)/gitconfig ~/.gitconfig 
