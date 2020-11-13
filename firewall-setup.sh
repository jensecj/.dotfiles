#!/bin/bash
# must be run with priviledges

ensure() {
    FILE=$1
    S=$2

    # only add the line if its not already there
    [[ -z $(grep "$S" "$FILE") ]] && echo "$S" >> "$FILE"
}

# default behaviour
ufw default deny incoming
ufw default deny outgoing
ufw logging low

# disable remote pings to this machine
# note the difference in paths     ---↓
ensure /etc/sysctl.conf "net.ipv4.icmp_echo_ignore_all = 1"
ensure /etc/sysctl.conf "net.ipv6.icmp.echo_ignore_all = 1"
sysctl -p # reload sysctl config

sed -i 's/-A ufw-before-input -p icmp --icmp-type destination-unreachable -j ACCEPT/-A ufw-before-input -p icmp --icmp-type destination-unreachable -j DROP/' /etc/ufw/before.rules
sed -i 's/-A ufw-before-input -p icmp --icmp-type source-quench -j ACCEPT/-A ufw-before-input -p icmp --icmp-type source-quench -j DROP/' /etc/ufw/before.rules
sed -i 's/-A ufw-before-input -p icmp --icmp-type time-exceeded -j ACCEPT/-A ufw-before-input -p icmp --icmp-type time-exceeded -j DROP/' /etc/ufw/before.rules
sed -i 's/-A ufw-before-input -p icmp --icmp-type parameter-problem -j ACCEPT/-A ufw-before-input -p icmp --icmp-type parameter-problem -j DROP/' /etc/ufw/before.rules
sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' /etc/ufw/before.rules

# allow time synchronization
ufw allow ntp

# dont allow incoming ssh connections to this machine
ufw allow out ssh comment ssh
ufw allow out http comment http
ufw allow out https comment https
ufw allow out dns comment dns
ufw allow out whois comment whois
ufw allow out imaps comment IMAPS
ufw allow out 587 comment SMTP
ufw allow in 6881 comment rtor-dht
ufw allow out 6881 comment rtor-dht
ufw allow out gopher comment gopher
ufw allow out 1965 comment gemini
ufw allow out 51820/udp comment wireguard
ufw allow out 993 comment mail-delivery
