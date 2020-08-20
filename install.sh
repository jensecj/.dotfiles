#!/bin/bash

# first install an AUR helper so we can grab packages from aur
AURHELPER=yay # or trizen, bauerbill, etc.
pacman -S $AURHELPER

# * system
declare -a packages=(
    # ** setup
    efibootmgr
    grub
    linux linux-headers
    linux-lts linux-lts-headers
    linux-hardened linux-hardened-headers

    # ** core
    base-devel
    coreutils
    diffutils
    findutils
    usbutils
    moreutils

    # ** networking
    NetworkManager # wifi

    # ** display server, window manager, etc
    xorg-server
    xorg-xev
    xorg-xbacklight
    xorg-xgamma
    xorg-setxkbmap
    xorg-xrandr

    # NOTE: not yet wayland, maybe someday
    # wayland
    # xorg-server-xwayland # X for wayland
    # wlroots
    # sway # window manager, i3 drop-in replacement
    # swaylock # screen locker
    # swayidle # idle trigger
    # waybar # wayland info bar
    # mako # wayland notification daemon

    # ** video drivers
    xf86-video-intel

    # ** audio
    pulseaudio
    pavucontrol

    # ** fonts
    adobe-source-code-pro-fonts # for programming
    adobe-source-sans-pro-fonts # for everything else
    noto-fonts-cjk # chinese-japanses-korean
    ttf-nerd-fonts-symbols # icon font amalgamation

    # ** early
    sudo # do things as root
    cpupower # helper for powersaving, frequency scaling, etc.
    acpi # battery info
    gptfdisk # partition disks
    inotify-tools # notify-send, etc.
    harfbuzz # textshaping engine
    imagemagick # image tools
    stow # symlink manager
    xdo # do things to X windows
    lsof # list open files for file-descriptor
    xsel # work with clipboard
    pass # password manager
    bc # scientific cli calculator
    poppler # pdf rendering
    ntfs-3g # ntfs support

    # ** security
    clamav # anti-virus
    apparmor # MAC system as a linux sec. module
    audit # kernel logging - for building apparmor profiles
    firejail # app sandboxing
    bubblewrap-suid # app sandboxing
    dnscrypt-proxy # for running encrypted dnslookups
    ufw # firewall
    # opensnitch # app firewall

    # ** programming tools
    # termite termite-terminfo # terminal emulator
    alacritty # another terminal
    zsh # preferred shell
    tmux # terminal multiplexer
    hyperfine # command-line benchmarking
    git # git and the github wrapper
    jupyter # interactive science notebooks
    docker # containerization
    podman buildah skopeo # more containers
    diff-so-fancy # fancy git diff
    entr # watch for file changes using inotify and kqueue

    # ** system
    i3-wm # tiling window manager
    dunst # notification manager
    sxhkd # hotkey daemon for x
    xob # simple X screen bar, multiple uses, volume, brightness, etc.
    picom # screen compositor for X
    polybar # info bar / fringe for things
    unclutter # hide the curser when idle
    xidlehook # perform actions on idle (used with slock)
    autocutsel # for synching clipboards
    earlyoom # out-of-memory daemon
    psi-notify # notify on high system-resource use
    dkms # dynamic kernel module support
    keychain # manage ssh agents
    expac # package info
    pacman-contrib # pactree, etc. # listing pacman package dependencies
    arch-audit # check installed packages against security.archlinux.org

    # ** sys tools
    ripgrep # fast grep alternative
    exa # ls alternative
    bat # cat alternative with syntax highlighting, etc.
    fd # find alternative
    jq # work with json in the terminal
    tokei # count lines of code
    xsv # work with csv in the terminal
    rmlint # find duplicate files in directories
    dua-cli # ncdu alternative
    fselect # find files using SQL syntax
    xcp # extended cp
    sd # simple find-and-replace
    just # modern make
    runiq # fast filter for duplicate lines
    zoxide # z.sh alternative
    tree # list files in tree-view

    # ** utilities
    ffmpeg # working with video/audio
    ffmpegthumbnailer # create video thumbnails
    brightnessctl # easy brightness controls
    task-spooler # queue tasks to be completed sequentially
    tldr # quick shell examples for most commands
    slock # screen lock
    perf # performance analysis tools
    openssh openvpn
    wireguard-tools
    links # cli browser
    # mosh # ssh-replacement, with persistent connections
    # knockd # port-knocker
    gnupg
    progress # cmd monitor (progress/throughput/eta/etc.) for processes (e.g. gzip, cp, mv)
    borg # incremental, encrypted backups
    gocryptfs # encrypted mount points
    rsync # synching things
    rtorrent # torrenting
    texlive-bin # latex
    texlive-core
    texlive-science
    texlive-publishers
    texlive-latexextra
    texlive-pictures
    texlive-fontsextra
    texlive-formatsextra
    minted # syntax-highlighting for latex
    # biber # bibtex extras
    gnuplot # plotting
    gucharmap # explore font glyphs
    downgrade # for downgrading packages to a version in cache
    # lsyncd # "real-time" directory synchronization
    ddrescue # disk recovery
    udiskie # automounting removable disks
    # httpie # simple http client for the terminal
    # insect # scientific calculator, with many features (kg -> grams, etc.)
    fzf # fuzzy file finder
    # detox # clean up filenames
    # rawdog # raw rss feeds in the terminal
    ditaa # create disgrams from ascii
    plantuml # create UML diagrams from ascii
    rsstail # tail for rss-feeds
    # hexyl # cat, but spits out hex
    lynis # hardening
    autorandr # automatic xrandr
    qrencode # turn strings into qr codes
    secure-delete # securely delete files
    hashdeep # hash all files in a directory recursively

    # ** system information
    lshw # print hardware information (like other ls* tools)
    htop # process manager
    iotop # I/O monitor
    iftop # network monitor

    # ** misc
    youtube-dl # for downloading video/sound from the internet
    axel # download accelerator
    ranger-git # ncurses file explorer
    ueberzug # show images in the terminal
    redshift # screen dimmer / blue light reducer
    rofi # app menu / dmenu clone
    # anki # flashcards
    peerflix # streaming torrents
    # calibre # ebook manager
    mpv # video player
    moc # music player
    mupdf # pdf viewer
    zathura # pdf viewer
    zathura-pdf-mupdf # mupdf backend for zathura
    zathura-djvu zathura-ps # djvu and postscript backends for zathura
    feh # image viewer
    sxiv # image / gif viewer
    dictd # offline dictionary and daemon
    dict-wn # wordnet
    dict-gcide # gnu english dictionary
    dict-foldoc # gnu english dictionary
    dict-wikt-en-all # english wikitionary
    slop bashcaster-git # for simple screen recording

    # ** mail
    isync # IMAP sync, provides mbsync
    msmtp # smtp client/server
    msmtp-mta # setup sendmail to use msmtp
    notmuch # cli mail client
    # s-nail

    # ** browsers
    firefox
    firefox-developer-edition

    # ** programming languages
    # *** java
    jdk-openjdk # latest jdk
    jdk11-openjdk jre11-openjdk
    jdk8-graalvm-bin jdk11-graalvm-bin # alternative vm
    native-image-jdk8-bin native-image-jdk11-bin
    maven

    # *** clojure
    clojure leiningen

    # *** python
    python python-pip python-setuptools
    python-virtualenv # virtual environments
    pyenv # version management
    python-black # code formatter
    python-tox # testing and building
    python-poetry # dependency management
    pypy3 pypy3-pip pypy3-setuptools
    mypy # type checking

    # *** c++
    clang clang-tools-extra
    llvm llvm-libs lld
    libc++ openmp
    gcc gcc-libs
    boost boost-libs
    valgrind # performance tuning/debugging
    cmake # build tool

    # *** lisps
    chicken
    sbcl roswell

    # *** rust
    rustup rls-git
)
$AURHELPER -S "${packages[@]}"

# * pip
declare -a pip_packages=(
    i3altlayout
)
pip install -g "${pip_packages[@]}"

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
)
cargo install "${rust_packages[@]}"
