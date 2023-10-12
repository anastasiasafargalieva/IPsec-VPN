#!/usr/bin/env bash

## NAT traffic going to the internet
route add default gw 172.18.18.1
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6


echo 172.30.30.30 172.18.18.18 : PSK \"HMXJumvFLTN1noNm8ET4WOeKD5Ec4KFMqwZ5Pyx9jYreob2e0InG4ferASftV0EPMh7TD1oXu7IEslyhBpRd2lwIBqONA36rEHSsW9mFxD5rskLSo1Zi5JKxqjB8R1mfvfLx4RdasEwecgL2OvCiXZaJk6ez2xZBhd2WIEO5DNqpjiJEBSalsb4eo4IYSs661WAMQ2W25efEY0oDnvoL5gGXoGuLFZbJ1CWrigq2dqVFNgdDxdk6ruSVPWNXBdxY\">> /etc/ipsec.secrets

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
        left=172.18.18.18
        leftsubnet=172.18.18.18/32
        right=172.30.30.30
        rightsubnet=172.30.30.30/32
        ike=aes256-sha2_256-modp2048!
        esp=aes256-sha2_256!
        dpdaction=restart
        auto=start
EOL

## restart ipsec
ipsec restart
