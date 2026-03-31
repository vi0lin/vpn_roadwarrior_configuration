#!/usr/bin/bash

a_public_ip=$1
a_public=$2
b_lan=192.168.1.0/24
b_private_ip=$3
b_private=$4

pkg install wireguard-tools
sysrc wireguard_enable=YES
sysrc wireguard_interfaces="wg0"
sysrc pf_enable=YES

sysctl net.inet.ip.forwarding=1

# todo Check if files exists, ask for creating new ones.

# todo copy files across A B and C

b_public=$(cat /usr/local/etc/wireguard/b.public)

# WireGuard on A (/usr/local/etc/wireguard/wg0.conf)
```
[Interface] # B
PrivateKey = $b_private
Address = 10.9.0.2/24
ListenPort = 51820
[Peer] # A
PublicKey = $a_public
AllowedIPs = 10.9.0.0/24, 10.8.0.0/24
Endpoint = $a_public_ip:51820
PersistentKeepalive = 25
``` > /usr/local/etc/wireguard/wg0.conf

# pf on A (/etc/pf.conf)
```
ext_if="re0"
lan_if="re0"
wg_if="wg0"
# Option B
nat on $lan_if from { 10.8.0.0/24, 10.9.0.0/24 } to $b_lan -> ($lan_if)
nat on $lan_if from $b_lan to { 10.8.0.0/24, 10.9.0.0/24 } -> ($wg_if)
# Allow everything on loopback
set skip on lo0
# Allow WireGuard from A
pass in on $ext_if proto udp to port 51820
# Allow IKEv2 on A is already handled on A
# === Critical for LAN access from VPN clients ===
pass in on $wg_if from { 10.8.0.0/24, 10.9.0.0/24 } to $b_lan
pass out on $lan_if from { 10.8.0.0/24, 10.9.0.0/24 } to $b_lan
# Allow return traffic from LAN to VPN clients
pass in on $lan_if from $b_lan to { 10.8.0.0/24, 10.9.0.0/24 }
pass out on $wg_if from $b_lan to { 10.8.0.0/24, 10.9.0.0/24 }
# Optional: allow B itself to be reached from VPN (if you need to ping B's LAN IP)
pass in on $wg_if from { 10.8.0.0/24, 10.9.0.0/24 } to (self)
``` > /etc/pf.conf

service pf restart
service wireguard restart
