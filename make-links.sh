# setup config files

ln -s $(pwd)/Xresources $HOME/.Xresources
ln -s $(pwd)/zsh/zshrc $HOME/.zshrc
ln -s $(pwd)/zsh/zprofile $HOME/.zprofile
ln -s $(pwd)/tmux/tmux.conf $HOME/.tmux.conf
ln -s $(pwd)/tmux/tmux/ $HOME/.tmux
ln -s $(pwd)/termite/config $HOME/.config/termite/config

ln -s $(pwd)/i3.conf $HOME/.i3/config

mkdir $HOME/.rtorrent.session
ln -s $(pwd)/rtorrent.rc $HOME/.rtorrent.rc

ln -s $(pwd)/mpv/input.conf $HOME/.config/mpv/input.conf
ln -s $(pwd)/mpv/mpv.conf $HOME/.config/mpv/mpv.conf

ln -s $(pwd)/compton.conf $HOME/.config/compton.conf
ln -s $(pwd)/rofi.conf $HOME/.config/rofi/config
ln -s $(pwd)/polybar.conf $HOME/.config/polybar/config
ln -s $(pwd)/zathurarc $HOME/.config/zathura/zathurarc
ln -s $(pwd)/cookiecutter.rc $HOME/.cookiecutterrc


ln -s $(pwd)/ranger/rc.conf $HOME/.config/ranger/rc.conf
ln -s $(pwd)/ranger/zenburn.py $HOME/.config/colorschemes/zenburn.py

# this fails if git has already been configured, which is better than
# overwriting configurations i guess.
ln -s $(pwd)/gitconfig $HOME/.gitconfig

# add our binaries to the system, this requires privileges
ln -s $(pwd)/bin/em /usr/local/bin/em
ln -s $(pwd)/bin/colortest /usr/local/bin/colortest
ln -s $(pwd)/bin/define.sh /usr/local/bin/define

ln -s $(pwd)/bin/dmi/dmi.sh /usr/local/bin/dmi
ln -s $(pwd)/bin/dmi/dmi15.sh /usr/local/bin/dmi15
ln -s $(pwd)/bin/dmi/dmicph.sh /usr/local/bin/dmicph
ln -s $(pwd)/bin/dmi/dmiaa.sh /usr/local/bin/dmiaa

ln -s $(pwd)/systemd-units/lock-on-sleep.service /etc/systemd/system/
mkdir $HOME/.config/systemd/user/
ln -s $(pwd)/systemd-units/random-wallpaper.service $HOME/.config/systemd/user/
ln -s $(pwd)/systemd-units/random-wallpaper.timer $HOME/.config/systemd/user/
