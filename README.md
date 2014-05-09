# The pretty
![Screenshot of my dotfiles in action](screen.png?raw=true "Screenshot of my dotfiles in action")

# The nitty gritty
seemed like a practical way to store configurations and facilitate
portability, so i tried it!

# Awesome
configuration is for awesome 3.5

* `Modkey + Enter` spawns terminal
* `Modkey + Backspace` spawns browser
* `Modkey + Delete` spawns editor
* `Modkey + F12` spawns htop

# Theme
I use the [Zen-nokto](http://gnome-look.org/content/show.php/Zen+suite?content=149883) GTK2+3 theme
together with the [Source Code Pro](https://github.com/adobe/source-code-pro) font.

# Git
* `git ad` add files to git repo
* `git ai` add files to git repo interactively
* `git br` branch (create or switch)
* `git ch` checkout a repo
* `git cl` clone a repo
* `git co` prompt for a message, the commit verbosely
* `git di` diff changes in repo
* `git lo` pretty log
* `git pu` push repo to remote
* `git st` simple status

# Symlinks
(should probably create a bootstrapper)
* ln -s ~/.dotfiles/bashrc ~/.bashrc
* ln -s ~/.dotfiles/bash_profile ~/.bash_profile
* ln -s ~/.dotfiles/gitconfig ~/.gitconfig
* ln -s ~/.dotfiles/xinitrc ~/.xinitrc
* ln -s ~/.dotfiles/Xresources ~/.Xresources
* ln -s ~/.dotfiles/awesomewm/zenburn ~/.config/awesome/themes/zenburn
* ln -s ~/.dotfiles/awesomewm/rc.lua ~/.config/awesome/rc.lua
* ln -s ~/.dotfiles/bin/em /usr/local/bin
