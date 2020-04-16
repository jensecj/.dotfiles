#!/bin/bash

# first install an AUR helper so we can grab packages from aur
AURHELPER=yay # or trizen, bauerbill, etc.
pacman -S $AURHELPER

declare -a packages=(
    # java
    jdk10-openjdk jre10-openjdk
    graal-bin graal-native-image-bin # alternative vm
    maven

    # python
    python python-pip python-setuptools
    pyenv python-pew python-virtualenv # virtual environments
    python-language-server #
    mypy # type checking
    hy # lispy-python

    # c++
    clang clang-tools-extra
    llvm llvm-libs lld
    libc++ openmp
    gcc gcc-libs
    boost boost-libs
    valgrind # performance tuning/debugging
    cmake # build tool

    # lisps
    chicken
    sbcl roswell

    # rust
    rustup rls-git

    # other languages
    octave nodejs
    ocaml dune opam llvm-ocaml

    # libraries
    libotf

    # programming tools
    termite termite-terminfo # terminal emulator
    alacritty                # another terminal
    zsh # preferred shell
    tmux # terminal multiplexer
    hyperfine # command-line benchmarking
    git hub # git and the github wrapper
    jupyter # interactive science notebooks
    docker # containerization
    podman buildah skopeo # more containers
    diff-so-fancy # fancy git diff
    watchman # inode change monitor and trigger

    # system
    dkms # dynamic kernel module support
    earlyoom # out-of-memory daemon

    # utilities
    moreutils # more shell utils
    keychain # manage ssh agents
    brightnessctl # easy brightness controls
    task-spooler # queue tasks to be completed sequentially
    unclutter # hide the curser when idle
    tldr # quick shell examples for most commands
    polybar # info bar / fringe for things
    sxhkd # hotkey daemon for x
    picom # screen compositor for X11
    i3-gaps # tiling window manager
    dunst # notification manager
    ufw # firewall
    opensnitch # app firewall
    slock # screen lock
    xidlehook # perform actions on idle (used with slock)
    dnscrypt-proxy # for running encrypted dnslookups
    autocutsel # for synching clipboards
    gperftools # performance analysis tools
    openssh openvpn
    wireguard-tools wireguard-dkms
    mosh # ssh-replacement, with persistent connections
    knockd # port-knocker
    gnupg
    progress # progress monitor (bar/throughput/etc.) for processes (e.g. gzip, cp, mv, ...)
    pv # also a progress monitor (uses pipes instead processes)
    borg # incremental, encrypted backups
    gocryptfs # encrypted mount points
    rsync # synching things
    ripgrep # more file searching
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
    firejail # app sandboxing
    ddrescue # disk recovery
    udiskie # automounting removable disks
    bat # cat clone with syntax highlighting, etc.
    httpie # simple http client for the terminal
    fd # alternative to find
    insect # scientific calculator, with many features (kg -> grams, etc.)
    xsv # work with csv in the terminal
    fzf # fuzzy file finder
    detox # clean up filenames
    rawdog # raw rss feeds in the terminal
    ditaa # create disgrams from ascii
    plantuml # create UML diagrams from ascii
    rsstail # tail for rss-feeds
    hexyl # cat, but spits out hex
    exa # ls alternative
    lynis # hardening
    autorandr # automatic xrandr

    # system information
    lshw # print hardware information (like other ls* tools)
    glances # monitor for lots of system info
    iotop # I/O monitor
    iftop # network monitor
    htop # process manager

    # misc
    youtube-dl # for downloading video/sound from the internet
    ranger-git # ncurses file explorer
    python-ueberzug-git # show images in the terminal
    redshift # screen dimmer / blue light reducer
    rofi # app menu / dmenu clone
    anki # flashcards
    peerflix # streaming torrents
    calibre # ebook manager
    mpv # video player
    moc # music player
    mupdf # pdf viewer
    zathura # pdf viewer
    zathura-pdf-mupdf # mupdf backend for zathura
    zathura-djvu zathura-ps # djvu and postscript backends for zathura
    feh # image viewer
    translate-shell # google-translate cli
    dictd # offline dictionary and daemon
    dict-wm # wordnet
    dict-gcide # gnu english dictionary
    dict-foldoc # gnu english dictionary
    dict-wikt-en-all # english wikitionary
    wordnet-common wordnet-cli # wordnet dict and extras
    yad slop bashcaster-git # for simple screen recording
    clamav # anti-virus
    fontpreview-git # simple cli for testing fonts

    # mail
    isync
    msmtp
    notmuch

    # browsers
    chromium
    firefox

    # fonts
    adobe-source-sans-pro-fonts
    adobe-source-code-pro-fonts # for programming
    noto-sans-cjk # chinese-japanses-korean
    nerd-fonts-complete # a collection of patched and icon fonts
    otf-fira-code # programming font with ligitures
)
$AURHELPER -S "${packages[@]}"

declare -a pip_packages=(
    i3altlayout
)
pip install -g "${pip_packages[@]}"

declare -a npm_packages=(
    qrcode-terminal # generate qrcodes in the terminal
    http-server
)
npm -g install "${npm_packages[@]}"

declare -a rustup_components=(
    clippy # linting
    rls # rust language server
)
for com in $rustup_components
do
    rustup component add "$com"
done

declare -a rust_packages=(
    snatch # threaded downloader
)
cargo install "${rust_packages[@]}"


# TODO: setup config for the following
# firefox:
# cookie autodelete
# decentral eyes
# https everywhere
# mute sites by default
# privacy badger
# umatrix
# ublock origin
# tamper monkey
# privacy settings
# link cleaner

FIREFOX_PROFILE="cf5z4a52.dev-edition-default"
ln -s "$(pwd)/firefox/user.js" /home/jens/.mozilla/firefox/$FIREFOX_PROFILE/user.js
ln -s "$(pwd)/firefox/userChrome.css" /home/jens/.mozilla/firefox/$FIREFOX_PROFILE/chrome/userChrome.css
ln -s "$(pwd)/firefox/userContent.css" /home/jens/.mozilla/firefox/$FIREFOX_PROFILE/chrome/userContent.css
