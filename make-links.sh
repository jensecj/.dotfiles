# setup config files

ln -s $(pwd)/Xresources $HOME/.Xresources
ln -s $(pwd)/zsh/zshrc $HOME/.zshrc
ln -s $(pwd)/zsh/zprofile $HOME/.zprofile
ln -s $(pwd)/tmux.conf $HOME/.tmux.conf

ln -s $(pwd)/i3-config $HOME/.i3/config
ln -s $(pwd)/i3status.conf $HOME/.i3status.conf

ln -s $(pwd)/mpv/input.conf $HOME/.config/mpv/input.conf
ln -s $(pwd)/mpv/mpv.conf $HOME/.config/mpv/mpv.conf


# this fails if git has already been configured, which is better than
# overwriting configurations i guess.
ln -s $(pwd)/gitconfig $HOME/.gitconfig

# add our binaries to the system, this requires sudo
ln -s $(pwd)/bin/em /usr/bin/em
ln -s $(pwd)/bin/colortest /usr/bin/colortest
