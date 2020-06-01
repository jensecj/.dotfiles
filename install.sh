#!/bin/bash

# first install an AUR helper so we can grab packages from aur
AURHELPER=yay # or trizen, bauerbill, etc.
pacman -S $AURHELPER

# * system
declare -a packages=(
    # ** java
    jdk10-openjdk jre10-openjdk
    graal-bin graal-native-image-bin # alternative vm
    maven

    # ** python
    python python-pip python-setuptools
    pypy3 pypy3-pip pypy3-setuptools
    pyenv python-pew python-virtualenv # virtual environments
    python-language-server #
    mypy # type checking
    hy # lispy-python

    # ** c++
    clang clang-tools-extra
    llvm llvm-libs lld
    libc++ openmp
    gcc gcc-libs
    boost boost-libs
    valgrind # performance tuning/debugging
    cmake # build tool

    # ** lisps
    chicken
    sbcl roswell

    # ** rust
    rustup rls-git

    # ** other languages
    octave nodejs
    ocaml dune opam llvm-ocaml

    # ** libraries
    libotf

    # ** programming tools
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

    # ** system
    dkms # dynamic kernel module support
    i3-gaps # tiling window manager
    earlyoom # out-of-memory daemon
    psi-notify # notify on high system-resource use
    dunst # notification manager
    sxhkd # hotkey daemon for x
    picom # screen compositor for X11
    polybar # info bar / fringe for things
    dnscrypt-proxy # for running encrypted dnslookups
    ufw # firewall
    keychain # manage ssh agents
    unclutter # hide the curser when idle
    opensnitch # app firewall
    xidlehook # perform actions on idle (used with slock)
    autocutsel # for synching clipboards

    # ** sys tools
    ripgrep # fast grep alternative
    exa # ls alternative
    bat # cat alternative with syntax highlighting, etc.
    fd # find alternative
    jq # work with json in the terminal
    tokei # count lines of code
    xsv # work with csv in the terminal
    fdupes # find duplicate files in directories
    dua-cli # ncdu alternative
    fselect # find files using SQL syntax
    xcp # extended cp
    sd # simple find-and-replace
    just # modern make
    runiq # fast filter for duplicate lines
    zoxide # z.sh alternative

    # ** utilities
    moreutils # more shell utils
    brightnessctl # easy brightness controls
    task-spooler # queue tasks to be completed sequentially
    tldr # quick shell examples for most commands
    slock # screen lock
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
    rtorrent # torrenting
    texlive-bin # latex
    texlive-core # latex
    gnuplot # plotting
    downgrade # for downgrading packages to a version in cache
    lsyncd # "real-time" directory synchronization
    firejail # app sandboxing
    ddrescue # disk recovery
    udiskie # automounting removable disks
    httpie # simple http client for the terminal
    insect # scientific calculator, with many features (kg -> grams, etc.)
    fzf # fuzzy file finder
    detox # clean up filenames
    rawdog # raw rss feeds in the terminal
    ditaa # create disgrams from ascii
    plantuml # create UML diagrams from ascii
    rsstail # tail for rss-feeds
    hexyl # cat, but spits out hex
    lynis # hardening
    autorandr # automatic xrandr
    secure-delete # securely delete files

    # ** system information
    htop # process manager
    lshw # print hardware information (like other ls* tools)
    iotop # I/O monitor
    iftop # network monitor

    # ** misc
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

    # ** mail
    isync
    msmtp
    notmuch

    # ** browsers
    chromium
    firefox
    firefox-developer-edition

    # ** fonts
    adobe-source-code-pro-fonts # for programming
    adobe-source-sans-pro-fonts
    noto-sans-cjk # chinese-japanses-korean
    nerd-fonts-complete # a collection of patched and icon fonts
    otf-fira-code # programming font with ligitures
)
$AURHELPER -S "${packages[@]}"

# * pip
declare -a pip_packages=(
    i3altlayout
)
pip install -g "${pip_packages[@]}"

# * npm
declare -a npm_packages=(
    qrcode-terminal # generate qrcodes in the terminal
)
npm -g install "${npm_packages[@]}"

# * cargo
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
