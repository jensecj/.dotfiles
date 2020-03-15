#!/bin/sh

# load the auto completion system and setup
autoload -Uz complist
autoload -Uz compinit

# if the cache does not exist, or if it is older
# than 24 hours, rebuild it.
cache_exists=$(test -e ~/.zcompdump)
if [[ ! -e "$HOME/.zcompdump" || $(find "$HOME/.zcompdump" -mtime +1) ]]; then
    compinit
else
    compinit -C
fi

zstyle ':completion:*' use-cache on
# show the selected item in the menu
zstyle ':completion:*' menu select
# setup an autocompletion style (case-insensitive)
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# setup where hosts should completion should come from
# ignore /etc/hosts, its used for blacklisting a bunch of domains
_h=()
if [[ -r ~/.ssh/config ]]; then
    _h=($_h ${${${(@M)${(f)"$(cat ~/.ssh/config)"}:#Host *}#Host }:#*[*?]*})
fi
# if [[ -r ~/.ssh/known_hosts ]]; then
#   h=($h ${${${(f)"$(cat ~/.ssh/known_hosts{,2} || true)"}%%\ *}%%,*}) 2>/dev/null
# fi
if [[ $#_h -gt 0 ]]; then
    zstyle ':completion:*' hosts $_h
fi

# Don't complete common users
zstyle ':completion:*:*:*:users' ignored-patterns \
       "systemd-*" redis polkitd nullmail adm amanda apache avahi beaglidx \
       bin cacti canna clamav daemon hacluster haldaemon halt hsqldb ident \
       dbus distcache dovecot fax ftp games gdm gkrellmd gopher junkbust ldap \
       lp mail mailman mailnull mldonkey mysql nagios named netdump news \
       nfsnobody nobody nscd ntp nut nx openvpn operator pcap nm-openconnect \
       tor unbound postfix postgres privoxy pulse pvm quagga radvd rpc \
       rpcuser rpm shutdown squid sshd sync uucp vcsa xfs cups consul lightdm \
       nm-openvpn dnsmasq geoclue colord dnscrypt-proxy usbmux rtkit uuidd http '_*'
