#!/bin/sh

INET_IFACE="p2p1"
LOCAL_NETWORK="10.23.10.0/24"
IMAGE_ADDR=10.23.10.10

iptables -F -t filter
iptables -F -t nat

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# INPUT chain
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT

# TCP protocol
iptables -A INPUT -s $LOCAL_NETWORK -m state --state NEW -p tcp -m multiport --dports ssh,5000 -j ACCEPT
# UDP
#iptables -A INPUT -s $LOCAL_NETWORK -p udp -m multiport --dports domain -j ACCEPT

# FORWARD chain
#iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
#iptables -A FORWARD -i $VPN_IFACE -o $INET_IFACE -d $IMAGE_ADDR -j ACCEPT
#iptables -A FORWARD -i $INET_IFACE -o $VPN_IFACE -j ACCEPT

# TCP services
iptables -A INPUT -m state --state NEW -p tcp -m multiport --dports 31337,5000,6000 -j ACCEPT
# UDP services
iptables -A INPUT -s $LOCAL_NETWORK -p udp -m multiport --dports 9999 -j ACCEPT

# DNAT
# TCP forwarding
iptables -t nat -A PREROUTING -i $INET_IFACE -p tcp --dport 5000 -j DNAT --to $IMAGE_ADDR:5000
# UDP forwarding
#iptables -t nat -A PREROUTING -i $VPN_IFACE -p udp --dport 9999 -j DNAT --to $IMAGE_ADDR:9999

# SNAT
#iptables -t nat -A POSTROUTING -o $INET_IFACE ! -s $LOCAL_NETWORK -d $IMAGE_ADDR -j SNAT --to $PROXY_ADDR
