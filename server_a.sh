#!/usr/bin/bash

public_ip=$(ifconfig | awk '/inet / && $2 !~ /^127\./ && $2 !~ /^192\.168\./ && $2 !~ /^10\./ {print $2; exit}')
default_b_lan=192.168.1.0/24
read -p "B LAN [$default_b_lan]: " b_lan
b_lan=${b_lan:-$default_b_lan}

user="user"
secret=$(head -c 16 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9')

pkg install strongswan wireguard-tools
sysrc strongswan_enable=YES
sysrc wireguard_enable=YES
sysrc wireguard_interfaces="wg0"
sysrc pf_enable=YES

sysctl net.inet.ip.forwarding=1

# todo Check if files exists, ask for creating new ones.

genkey() {
  wg genkey | \
  tee /usr/local/etc/wireguard/$name.private | \
  wg pubkey | \
  tee /usr/local/etc/wireguard/$name.public
}

genkey a
genkey b
genkey c

# todo copy files across A B and C

a_private=$(cat /usr/local/etc/wireguard/a.private)
b_public=$(cat /usr/local/etc/wireguard/b.public)
c_public=$(cat /usr/local/etc/wireguard/c.public)

mkdir -p /usr/local/etc/strongswan/ipsec.d/{cacerts,certs,private}
cd /usr/local/etc/strongswan/ipsec.d
pki --gen --outform pem > ca.key
pki --self --in ca.key --dn "CN=VPN CA" --ca --outform pem > ca.crt
pki --gen --outform pem > server.key
pki --pub --in server.key | pki --issue --cacert ca.crt --cakey ca.key \
  --dn "CN=$public_ip" --san $public_ip --flag serverAuth --outform pem > server.crt
chmod 600 *.key
cp -i ca.crt /usr/local/etc/strongswan/ipsec.d/cacerts/
cp -i server.crt server.key /usr/local/etc/strongswan/ipsec.d/
cp -i ca.crt /usr/local/etc/swanctl/x509ca/
cp -i server.crt server.key /usr/local/etc/swanctl/private/
cd -

# todo distribute ca.crt across A B and C
cat /usr/local/etc/strongswan/ipsec.d/ca.crt
echo $user
echo $password
echo
cat /usr/local/etc/wireguard/a.public
cat /usr/local/etc/wireguard/b.private
cat /usr/local/etc/wireguard/c.private

# WireGuard on A (/usr/local/etc/wireguard/wg0.conf)
```
[Interface] # A
PrivateKey = $a_private
Address = 10.9.0.1/24
ListenPort = 51820
[Peer] # B
PublicKey = $b_public
AllowedIPs = 10.9.0.2/32, $b_lan
PersistentKeepalive = 25
[Peer] # C
PublicKey = $c_public
AllowedIPs = 10.9.0.3/32
PersistentKeepalive = 25
``` > /usr/local/etc/wireguard/wg0.conf

# Swanctl on A (/usr/local/etc/swanctl/swanctl.conf)
```
# Include config snippets
include conf.d/*.conf
connections {
  roadwarrior {
    local_addrs = %any
    remote_addrs = %any
    local {
      auth = pubkey
      certs = server.crt
      id = $public_ip
    }
    remote {
      auth = eap-mschapv2
      eap_id = %any
      id = %any
    }
    children {
      roadwarrior_child {
        local_ts = $b_lan,10.8.0.0/24,10.9.0.0/24
        remote_ts = dynamic
        mode = tunnel
        # esp_proposals = aes256-sha256
        esp_proposals = aes256-sha256,aes256gcm16
        start_action = none
      }
    }
    pools = roadwarrior_pool
    version = 2
    proposals = aes256-sha256-modp1024,aes256-sha256-modp2048,aes256-sha256-ecp384,aes256gcm16-sha256-ecp384
    dpd_delay = 30s
    unique = never
  }
}
pools {
  roadwarrior_pool {
    addrs = 10.8.0.0/24
  }
}
secrets {
  eap-user1 {
    id = $user
    secret = "$secret"
  }
}
``` > /usr/local/etc/swanctl/swanctl.conf

# pf on A (/etc/pf.conf)
```
ext_if="vtnet0"
wg_if="wg0"
lo_if="lo0"
# NAT for external to B's LAN via wg interface
nat on $ext_if from any to $b_lan -> ($wg_if)
# IKEv2
pass in on $ext_if proto udp from any to any port {500,4500}
# WireGuard from any
pass in on $ext_if proto udp to port 51820
# Allow VPN clients to reach B's LAN
pass on $wg_if from { 10.8.0.0/24 , 10.9.0.0/24, self } to $b_lan
pass on $wg_if from { 10.8.0.0/24 , 10.9.0.0/24, self } to 10.8.0.0/24
pass on $wg_if from { 10.8.0.0/24 , 10.9.0.0/24, self } to 10.9.0.0/24
# Comment
pass in on $wg_if from $b_lan to { 10.8.0.0/24, 10.9.0.0/23, self }
# Comment
pass in on $wg_if from $b_lan to { 10.8.0.0/24, 10.9.0.0/24 }
pass out on enc0 from $b_lan to { 10.8.0.0/24, 10.9.0.0/24 }
``` > /etc/pf.conf

# Strongswan on A (/usr/local/etc/strongswan.conf)
## For Deeper Strongswan Log Uncomment filelog section
## Use tail -f /var/log/charonlog
## This is for cipher and hashing proposal investigation, when windows fails.
```
charon {
  # filelog {
  #   /var/log/charonlog {
  #     time_format = %b %e %T
  #     ike_name = yes
  #     append = yes
  #     default = 3
  #     flush_line = yes
  #   }
  # }
  load_modular = yes
  plugins {
    eap-mschapv2 {
      load = yes
    }
    eap-identity {
      load = yes
    }
    include strongswan.d/charon/*.conf
  }
}
include strongswan.d/*.conf
``` > /usr/local/etc/strongswan.conf

service pf restart
service strongswan restart
service wireguard restart
