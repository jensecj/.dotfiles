#!/bin/sh

# first install yaourt so we can grab packages from aur
sudo pacman -S yaourt

declare -a packages=(
    # java
    jdk9-openjdk jre9-openjdk

    # python
    python python2
    python-pip python2-pip
    python-setuptools python-pew

    # c++
    clang clang-tools-extra
    gcc gcc-libs
    boost boost-libs
    llvm llvm-libs lld
    valgrind rtags

    # other languages
    octave rustup nodejs chicken ghc ghc-libs ghc-static

    # programming tools
    emacs # now that the bootloader is installed, install the OS
    termite termite-terminfo # terminal emulator
    zsh # preferred shell
    tmux
    git hub # git and the github wrapper
    apache-ant apache-ivy # java build tools
    cmake # c++ build tool
    jupyter # interactive science notebooks
    virtualbox # virtual machine manager
    vagrant # create virtual environments for provisioning using virtualbox
    docker # containerization

    # system apps
    keychain # manage ssh agents
    unclutter # hide the curser when idle
    tldr # quick shell examples for most commands
    polybar # info bar / fringe for things
    compton # screen compositor for X11
    i3-wm # tiling window manager
    dunst # notification manager
    ufw # firewall
    slock # screen lock
    dnscrypt-proxy # for running encrypted dnslookups
    autocutsel # for synching clipboards
    gperftools # performance analysis tools
    htop # process manager
    openssh
    openvpn
    gnupg

    # apps
    youtube-dl # for downloading video/sound from the internet
    ranger # ncurses file explorer
    rsync # synching things
    redshift # screen dimmer / blue light reducer
    rofi # app menu / dmenu clone
    calibre # ebook manager
    anki # flashcards
    peerflix # streaming torrents
    dropbox


    mpv # video player
    mupdf # pdf viewer
    feh # image viewer



    # browsers
    chromium
    firefox
    icecat
    links # textbased ncurses browser

    # utilities
    the_silver_searcher # file searching
    ripgrep # more file searching
    syncthing # syncthing files between devices
    borg # backup
    rtorrent # torrenting
    texlive-bin # latex
    texlive-core # latex
    jq # explore json in the terminal
    gnuplot # plotting

    # fonts
    adobe-source-code-pro-fonts
    adobe-source-sans-pro-fonts
    nerd-fonts-complete
    ttf-material-icons
)

yaourt -S ${packages[@]}

declare -a npm_packages=(
    qrcode-terminal # generate qrcodes in the terminal
    http-server
    insect # convert between units (kg -> grams, etc.)
)

npm -g install ${npm_packages[@]}



cargo install snatch # threaded downloader
