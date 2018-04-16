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
    tmux # terminal multiplexer
    git hub # git and the github wrapper
    jupyter # interactive science notebooks
    virtualbox # virtual machine manager
    vagrant # create virtual environments for provisioning using virtualbox
    docker # containerization
    direnv # directory specific, automatically loading exports
    python-cookiecutter # create new project skeletons from templates
    diff-so-fancy # fancy git diff

    # system / utilities
    keychain # manage ssh agents
    unclutter # hide the curser when idle
    tldr # quick shell examples for most commands
    polybar # info bar / fringe for things
    compton # screen compositor for X11
    i3-gaps # tiling window manager
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
    pv # also a progress monitor (uses pipes instead processes)
    borg # incremental, encrypted backups
    gocryptfs # encrypted mount points
    rsync # synching things
    the_silver_searcher # file searching
    ripgrep # more file searching
    syncthing # syncthing files between devices
    rtorrent # torrenting
    texlive-bin # latex
    texlive-core # latex
    jq # explore json in the terminal
    gnuplot # plotting
    downgrade # for downgrading packages to a version in cache
    tokei # count lines of code
    fdupes # find duplicate files in directories
    lsyncd # "real-time" directory synchronization
    ncdu # free-space visualizer for filesystem

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
    zathura # pdf viewer
    zathura-pdf-mupdf # mupdf backend for zathura
    zathura-djvu zathura-ps # djvu and postscript backends for zathura
    feh # image viewer
    translate-shell # google-translate cli
    dictd # offline dictionary and daemon
    dict-gcide # gnu english dictionary
    irssi # irc client

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

# rust packages
cargo install snatch # threaded downloader

# disable beeps by not loading the pcspkr module
echo "blacklist pcspkr" >> /etc/modprobe.d/pcspkr-blacklist.conf

# dont wait for a minute and a half before force stopping things
sed -i 's/#DefaultTimeoutStartSec=90s/DefaultTimeoutStartSec=30s/' /etc/systemd/system.conf
sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=30s/' /etc/systemd/system.conf

systemctl enable lock-on-sleep
