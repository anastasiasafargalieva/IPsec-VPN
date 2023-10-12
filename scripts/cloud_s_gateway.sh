#!/usr/bin/env bash

## Traffic going to the internet
route add default gw 172.30.30.1

## setting NAT for cloud s
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

echo 172.30.30.30 172.16.16.16 : PSK \"uYGc2rYbryqSLHpVqYNJCoG2LaxWDDpADEwydN9XYSfWuvChdEtRIFoGAhDUJ0yJwy1TXgv6UevTglwRrvMzuL766gGedgzv7YylOsth0dFBlsTZv2fHaC4pLeMRZrzRq23f4YzvH3Raa0aT1SYhOGDVv08VEav5BLCjAPBirO36pmIs76mdC8nsYCGHP8efMXW2J0g39jR3iRVahW7yKimhgCjpkm1mTikb5mG323oWSglFjyTgPNoCm2mumCT3\">> /etc/ipsec.secrets
echo 172.30.30.30 172.18.18.18 : PSK \"HMXJumvFLTN1noNm8ET4WOeKD5Ec4KFMqwZ5Pyx9jYreob2e0InG4ferASftV0EPMh7TD1oXu7IEslyhBpRd2lwIBqONA36rEHSsW9mFxD5rskLSo1Zi5JKxqjB8R1mfvfLx4RdasEwecgL2OvCiXZaJk6ez2xZBhd2WIEO5DNqpjiJEBSalsb4eo4IYSs661WAMQ2W25efEY0oDnvoL5gGXoGuLFZbJ1CWrigq2dqVFNgdDxdk6ruSVPWNXBdxY\">> /etc/ipsec.secrets


## DNAT
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --source 172.18.18.18 --dport 8080 -j DNAT --to-destination 10.1.0.2
iptables -A INPUT -p esp --source 172.18.18.18 -j ACCEPT
iptables -A INPUT --source 172.18.18.18 -j DROP
iptables -t nat -A PREROUTING -i enp0s8 -p tcp --source 172.16.16.16 --dport 8080 -j DNAT --to-destination 10.1.0.3
iptables -A INPUT -p esp --source 172.16.16.16 -j ACCEPT
iptables -A INPUT --source 172.16.16.16 -j DROP

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

## ipsec conf
cat > /etc/ipsec.conf <<EOL
config setup
        charondebug=all
        uniqueids=yes
        strictcrlpolicy=no
conn cloud-vpn
        type=tunnel
        keyexchange=ikev2
        authby=secret
        leftfirewall=yes
        left=172.30.30.30
        leftsubnet=172.30.30.30/32
        ike=aes256-sha2_256-modp2048!
        esp=aes256-sha2_256!
        dpdaction=restart
        auto=start
conn gateway-a-vpn
        also=cloud-vpn
        right=172.16.16.16
        rightsubnet=172.16.16.16/32
conn gateway-b-vpn
        also=cloud-vpn
        right=172.18.18.18
        rightsubnet=172.18.18.18/32
EOL

## restart ipsec
ipsec restart
