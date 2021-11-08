export PATH="$HOME/.local/bin:$PATH"
export GNUPGHOME="$HOME/.gnupg"
export MOZ_ENABLE_WAYLAND=1

if [ "$XDG_SESSION_DESKTOP" = "sway" ] ; then
    # https://github.com/swaywm/sway/issues/595
    export _JAVA_AWT_WM_NONREPARENTING=1
fi
