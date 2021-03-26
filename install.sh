#!/bin/bash

# first install an AUR helper so we can grab packages from aur
AURHELPER=yay # or trizen, bauerbill, etc.
pacman -S $AURHELPER

# * system packages
declare -a packages=(
    # ** boot
    efibootmgr
    grub
    linux linux-headers
    linux-lts linux-lts-headers
    linux-hardened linux-hardened-headers

    # ** base
    base-devel
    coreutils
    diffutils
    findutils
    usbutils
    moreutils

    # ** networking
    iwd # wifi
    dhcpcd # DHCP client for ip leasing

    # ** video drivers
    xf86-video-intel
    mesa

    # ** display server, window manager, etc.
    # *** X
    xorg-server
    i3-wm # tiling window manager
    picom # screen compositor for X
    dunst # notification manager
    sxhkd # hotkey daemon for x
    xob # simple X screen bar, multiple uses, volume, brightness, etc.
    polybar # info bar / fringe for things
    xorg-xev # check keyboard inputs
    xorg-xbacklight # display backlight
    xorg-xgamma # display gamma correction
    xorg-setxkbmap # keyboard config
    xorg-xrandr # monitor config
    xdo # do things to X windows
    xsel # work with X clipboard
    unclutter # hide the X curser when idle
    slock # screen lock
    xidlehook # perform actions on idle (used with slock)
    autocutsel # for synching clipboards
    # *** wayland
    # wlroots wayland
    # xorg-server-xwayland # X for wayland
    # sway # window manager, i3 drop-in replacement
    # swaylock # screen locker
    # swayidle # idle trigger
    # swaybg # wallpaper manager
    # waybar # status bar
    # mako # notification daemon

    # ** audio
    pulseaudio
    pavucontrol

    # ** fonts
    adobe-source-code-pro-fonts # for programming
    adobe-source-sans-pro-fonts # for everything else
    noto-fonts-cjk # chinese-japanses-korean
    noto-fonts-emoji # emoji icons
    ttf-nerd-fonts-symbols # icon font amalgamation
    ttf-ubraille # proper braille characters

    # ** core libraries
    dkms # dynamic kernel module support
    earlyoom # out-of-memory daemon
    psi-notify # notify on high system-resource use

    # ** core tools
    sudo # do things as root
    cpupower # helper for powersaving, frequency scaling, etc.
    acpi # battery info
    gptfdisk # partition disks
    inotify-tools # notify-send, etc.
    ntfs-3g # ntfs support through fuse
    bc # scientific cli calculator
    lsof # list open files for file-descriptor

    # ** file system
    mergerfs # fuse union filesystem
    snapraid # software raid
    sshfs # fuse fs for mounting remote directories locally

    # ** security
    clamav # anti-virus
    apparmor # MAC system as a linux sec. module
    audit # kernel logging - for building apparmor profiles
    firejail # app sandboxing
    bubblewrap-suid # app sandboxing
    dnscrypt-proxy # for running encrypted dnslookups
    ufw # firewall

    # ** programming tools
    alacritty # another terminal
    zsh # preferred interactive shell
    dash # preferred shell
    dashbinsh # make sure dash is symlinked to /bin/sh
    tmux # terminal multiplexer
    hyperfine # command-line benchmarking
    git # git and the github wrapper
    jupyter # interactive science notebooks
    docker # containerization
    podman buildah skopeo # more containers
    diff-so-fancy # fancy git diff
    entr # watch for file changes using inotify and kqueue
    tree-sitter # incremental language parser
    zeal # offline dev docs

    # ** system
    expac # package info
    pacman-contrib # pactree, etc. # listing pacman package dependencies
    arch-audit # check installed packages against security.archlinux.org

    # ** system libraries
    harfbuzz # textshaping engine
    imagemagick # image tools
    poppler # pdf rendering
    perf # performance analysis tools
    wireguard-tools

    # ** system tools
    gnupg
    stow # symlink manager
    pass # password manager
    ripgrep # fast grep alternative
    rsync # synching things
    exa # ls alternative
    bat # cat alternative with syntax highlighting, etc.
    fd # find alternative
    jq # work with json in the terminal
    tokei # count lines of code
    xsv # work with csv in the terminal
    fdupes # find duplicate files in directories
    dua-cli # ncdu alternative
    sd # simple find-and-replace
    just # modern make
    runiq # fast filter for duplicate lines
    zoxide # z.sh alternative
    tree # list files in tree-view
    openssh
    # openvpn
    # knockd # port-knocker
    # mosh # ssh-replacement, with persistent connections

    # ** utilities
    libvterm # vterms for everyone
    ffmpeg # working with video/audio
    ffmpegthumbnailer # create video thumbnails
    brightnessctl # easy brightness controls
    task-spooler # queue tasks to be completed sequentially
    wikiman # docs from man-pages, arch-wiki, etc.
    tldr # quick shell examples for most commands
    progress # cmd monitor (progress/throughput/eta/etc.) for processes (e.g. gzip, cp, mv)
    borg # incremental, encrypted backups
    gocryptfs # encrypted mount points
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
    fzf # fuzzy file finder
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
    xmeasure # screen ruler
    xcolor # color picker

    # ** system information
    lshw # print hardware information (like other ls* tools)
    htop # process manager
    iotop # I/O monitor
    bandwhich # network monitor
    iftop # network monitor

    # ** misc
    youtube-dl # for downloading video/sound from the internet
    ranger-git # ncurses file explorer
    ueberzug # show images in the terminal
    redshift # screen dimmer / blue light reducer
    rofi # app menu / dmenu clone
    # anki # flashcards
    peerflix # streaming torrents
    # calibre # ebook manager
    mpv # video player
    moc wavpack libmpcdec taglib faad2 # music player, and codex etc.
    mupdf # pdf viewer
    zathura # pdf viewer
    zathura-pdf-mupdf # mupdf backend for zathura
    zathura-djvu zathura-ps # djvu and postscript backends for zathura
    feh # image viewer
    sxiv # image / gif viewer
    # chafa # cat images/gifs in terminal
    slop # select region on screen and output to stdout
    maim # take screen shots/grabs
    gimp # image editing

    # ** spelling dictionaries
    hunspell # spellchecking
    ispell # spellchecking
    aspell # spellchecking
    aspell-en # english dictionary for apell
    dictd # offline dictionary and daemon
    dict-wn # wordnet
    dict-gcide # gnu english dictionary
    dict-foldoc # gnu english dictionary
    dict-wikt-en-all # english wikitionary

    # ** mail
    isync # IMAP sync, provides mbsync
    msmtp # smtp client/server
    msmtp-mta # setup sendmail to use msmtp
    notmuch # cli mail client
    # s-nail

    # ** browsers
    links # cli browser
    firefox firefox-developer-edition

    # ** programming languages
    # *** misc
    shellcheck-bin # bash linter
    checkbashisms

    # *** java
    jdk-openjdk # latest jdk
    jdk11-openjdk jre11-openjdk
    jdk8-graalvm-bin jdk11-graalvm-bin # alternative vm
    native-image-jdk8-bin native-image-jdk11-bin
    maven

    # *** clojure
    clojure leiningen
    sci babashka

    # *** python
    python python-pip python-setuptools
    python-virtualenv # virtual environments
    pyenv # version management
    python-black # code formatter
    python-pylint # linter
    python-pydocstyle # linting for docstrings
    python-pycodestyle # linting for codestyle
    flake8 # linter
    bandit # security linter
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

    # *** rust
    rustup rust-analyzer

    # *** lisps
    chicken
    sbcl roswell
)
$AURHELPER -S "${packages[@]}"

# * rust components
declare -a rustup_components=(
    clippy # linting
    rustfmt # autoformatter
)
for com in $rustup_components
do
    rustup component add "$com"
done

