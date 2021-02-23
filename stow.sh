#!/bin/sh

sudo stow -t / root # system config, /etc, /usr, etc.
stow bin
stow alacritty termite zsh tmux # shell things
stow i3 dunst compton polybar # system look and feel
stow gnupg systemd # system utils
stow emacs mpv bat cookiecutter ranger rofi rtorrent zathura  # programs

stow misc # user config, bash dotfiles, etc.
