#!/usr/bin/env bash

## NAT traffic going to the internet
route add default gw 172.16.16.1
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

echo 172.30.30.30 172.16.16.16 : PSK \"uYGc2rYbryqSLHpVqYNJCoG2LaxWDDpADEwydN9XYSfWuvChdEtRIFoGAhDUJ0yJwy1TXgv6UevTglwRrvMzuL766gGedgzv7YylOsth0dFBlsTZv2fHaC4pLeMRZrzRq23f4YzvH3Raa0aT1SYhOGDVv08VEav5BLCjAPBirO36pmIs76mdC8nsYCGHP8efMXW2J0g39jR3iRVahW7yKimhgCjpkm1mTikb5mG323oWSglFjyTgPNoCm2mumCT3\">> /etc/ipsec.secrets


## ipsec conf
cat > /etc/ipsec.conf <<EOL
config setup
        charondebug=all
        uniqueids=yes
        strictcrlpolicy=no
conn gateway-a-to-cloud
        type=tunnel
        keyexchange=ikev2
        authby=secret
        left=172.16.16.16
        leftsubnet=172.16.16.16/32
        right=172.30.30.30
        rightsubnet=172.30.30.30/32
        ike=aes256-sha2_256-modp2048!
        esp=aes256-sha2_256!
        dpdaction=restart
        auto=start
EOL

## restart ipsec
ipsec restart
