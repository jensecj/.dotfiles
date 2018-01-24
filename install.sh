#!/bin/sh

# first install an AUR helper so we can grab packages from aur
AURHELPER=yay # or trizen, bauerbill, etc.

declare -a packages=(
    # java
    jdk9-openjdk jre9-openjdk
    apache-ant apache-ivy # java build tools

    # python
    python python-pip
    python-setuptools python-pew
    python-virtualenv

    # c++
    clang clang-tools-extra
    gcc gcc-libs
    boost boost-libs
    llvm llvm-libs lld
    valgrind rtags
    cmake # c++ build tool

    # lisps
    chicken
    sbcl roswell

    #haskell
    ghc ghc-libs ghc-static

    # dot net
    dotnet-host dotnet-runtime dotnet-sdk-2.0

    # other languages
    octave rustup nodejs

    # programming tools
    emacs # now that the bootloader is installed, install the OS
    termite termite-terminfo # terminal emulator
    zsh # preferred shell
    tmux # term multiplexer
    git hub # git and the github wrapper
    jupyter # interactive science notebooks
    virtualbox # virtual machine manager
    vagrant # create virtual environments for provisioning using virtualbox
    docker # containerization
    direnv # directory specific, automatically loading exports

    # system / utilities
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
    progress # progress monitor (bar/throughput/etc.) for processes (e.g. gzip, cp, mv, ...)
    borg # incremental, encrypted backups
    rsync # synching things
    the_silver_searcher # file searching
    ripgrep # more file searching
    syncthing # syncthing files between devices
    rtorrent # torrenting
    texlive-bin # latex
    texlive-core # latex
    jq # explore json in the terminal
    gnuplot # plotting

    # misc
    youtube-dl # for downloading video/sound from the internet
    ranger # ncurses file explorer
    redshift # screen dimmer / blue light reducer
    rofi # app menu / dmenu clone
    anki # flashcards
    peerflix # streaming torrents
    dropbox # folder sync
    calibre # ebook manager
    mpv # video player
    mupdf # pdf viewer
    feh # image viewer

    # browsers
    chromium
    firefox
    icecat
    links # textbased ncurses browser

    # fonts
    adobe-source-code-pro-fonts
    adobe-source-sans-pro-fonts
    nerd-fonts-complete
    ttf-material-icons
)

$AURHELPER -S ${packages[@]}

declare -a npm_packages=(
    qrcode-terminal # generate qrcodes in the terminal
    http-server
    insect # convert between units (kg -> grams, etc.)
)

npm -g install ${npm_packages[@]}



cargo install snatch # threaded downloader
