#!/bin/sh
# must be run with priviledges

# default behaviour
ufw default deny in
ufw default allow out
ufw logging off

# disable remote pings to this machine
echo "net.ipv4.icmp_echo_ignore_all = 1" >> /etc/sysctl.conf
sysctl -p
sed -i 's/-A ufw-before-input -p icmp --icmp-type destination-unreachable -j ACCEPT/-A ufw-before-input -p icmp --icmp-type destination-unreachable -j DROP/' /etc/ufw/before.rules
sed -i 's/-A ufw-before-input -p icmp --icmp-type source-quench -j ACCEPT/-A ufw-before-input -p icmp --icmp-type source-quench -j DROP/' /etc/ufw/before.rules
sed -i 's/-A ufw-before-input -p icmp --icmp-type time-exceeded -j ACCEPT/-A ufw-before-input -p icmp --icmp-type time-exceeded -j DROP/' /etc/ufw/before.rules
sed -i 's/-A ufw-before-input -p icmp --icmp-type parameter-problem -j ACCEPT/-A ufw-before-input -p icmp --icmp-type parameter-problem -j DROP/' /etc/ufw/before.rules
sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' /etc/ufw/before.rules

# allow time synchronization
ufw allow ntp

# dont allow incoming ssh connections to this machine
ufw allow out ssh
ufw reject in ssh

# dont browse the unsafe web
ufw reject in http
