#!/bin/bash

# first install an AUR helper so we can grab packages from aur
AURHELPER=yay

# * system packages
packages=(
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
    mesa libva-mesa-driver # gpu drivers for wayland
    vulkan-icd-loader amdvlk # vulkan drivers for amd

    # ** display server, window manager, etc.
    wayland
    sway # window manager, i3 drop-in replacement
    swayidle # idle trigger
    waylock # screen locker
    waybar # status bar
    persway # sway ipc daemon for auto-tiling
    dunst # notification manager
    wallutils # utils for monitors and wallpapers
    kanshi # autorandr for wayland
    gammastep # redshift display
    wl-clipboard # copy/paste in terminals
    slurp # select region
    grim # grab image from screen using region
    imv freeimage libpng libjpeg-turbo librsvg libnsgif # image viewer and backends

    # ** audio
    pipewire
    pipewire-pulse
    wireplumber
    easyeffects

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
    cpupower # helper for getting cpu info, and setting states (powersaving, frequency scaling, etc.)
    acpi # battery info
    hdparm # hdd info
    #smartmontools # hdd stats and control
    libnotify # notify-send, etc.
    inotify-tools # file watching
    bc # scientific cli calculator
    lsof # list open files for file-descriptor
    at # dispatch tasks to run sometime in the future

    # ** file system
    btfs # fuse filesystem for bittorrent
    mergerfs # fuse union filesystem
    snapraid # software raid
    sshfs # fuse fs for mounting remote directories locally

    # ** security
    clamav # anti-virus
    clamav-unofficial-sigs # more threat signatures for clamav
    apparmor # MAC system as a linux sec. module
    audit # kernel logging - for building apparmor profiles
    usbguard # control which usb devices are allowed
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
    docker docker-rootless-extras-bin # containerization
    podman netavark aardvark-dns podman-compose buildah skopeo # more containers
    criu # snapshot processes
    delta # fancy git diff
    watchexec # run commands when files change
    tree-sitter # incremental language parser
    zeal # offline dev docs

    # ** system
    expac # package info
    pacman-contrib # pactree, etc. # listing pacman package dependencies
    arch-audit # check installed packages against security.archlinux.org

    # ** system libraries
    harfbuzz # textshaping engine
    imagemagick # image tools
    poppler poppler-glib # pdf rendering
    perf # performance analysis tools
    wireguard-tools

    # ** system tools
    gnupg age minisign # crypto
    stow # symlink manager
    pass # password manager
    ripgrep # fast grep alternative
    rsync # synching things
    exa # ls alternative
    bat # cat alternative with syntax highlighting, etc.
    fd # find alternative
    jq # work with json in the terminal
    tokei # count lines of code
    fdupes fclones # find duplicate files in directories
    dua-cli # ncdu alternative
    just # modern make
    zoxide # z.sh alternative
    tree # list files in tree-view
    openssh openssh-askpass
    # knockd # port-knocker

    # ** utilities
    libvterm # vterms for everyone
    ffmpeg # working with video/audio
    ffmpegthumbnailer # create video thumbnails
    brightnessctl # easy brightness controls
    tldr # quick shell examples for most commands
    borg # incremental, encrypted backups
    gocryptfs # encrypted storage
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
    ddrescue # disk recovery
    udiskie # automounting removable disks
    # httpie # simple http client for the terminal
    fzf # fuzzy file finder
    autorandr # automatic xrandr

    # ** system information
    lshw # print hardware information (like other ls* tools)
    htop # process manager
    nvtop # gpu monitor
    iotop # I/O monitor
    bandwhich # network monitor
    iftop # network monitor
    powertop # power consumption

    # ** misc
    yt-dlp # for downloading video/sound from the internet
    ranger-git # ncurses file explorer
    # anki # flashcards
    # calibre # ebook manager
    mpv # video player
    moc wavpack libmpcdec taglib faad2 # music player, and codex etc.
    mupdf # pdf viewer
    zathura zathura-pdf-mupdf # document viewer, and backends
    pdftk # toolkit for manipulating pdfs, merging, splitting, etc.
    gimp # image editing
    nmap # network scanning
    dog # dns info
    whois

    # ** spelling, dictionaries
    hunspell ispell aspell # spellchecking
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

    # ** browsers
    links # cli browser
    firefox firefox-developer-edition
    profile-sync-daemon

    # ** programming languages
    # *** misc
    shellcheck-bin # bash linter
    checkbashisms

    # *** java
    jdk-openjdk # latest jdk
    jdk11-graalvm-bin native-image-jdk11-bin
    maven

    # *** clojure
    clojure leiningen
    sci babashka

    # *** python
    python python-pip python-setuptools
    pyenv # version management
    python-virtualenv # virtual environments
    python-numpy python-sympy python-scipy python-networkx python-pandas python-matplotlib
    python-black # code formatter
    python-pylint # linter
    python-pydocstyle # linting for docstrings
    python-pycodestyle # linting for codestyle
    flake8 # linter
    bandit # security linter
    mypy # type checking

    # *** c/cpp
    clang clang-tools-extra
    llvm llvm-libs lld
    gcc gcc-libs

    # *** rust
    rustup rust-analyzer

    # *** lisps
    chicken
    guile
    sbcl roswell
)
$AURHELPER -S "${packages[@]}"
