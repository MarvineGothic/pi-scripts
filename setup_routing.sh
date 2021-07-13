#!/bin/bash

#https://www.raspberrypi.org/documentation/configuration/wireless/access-point-routed.md

#check if run as root
who=$(whoami)
if [ $who == "root" ]
then
echo ""
else
echo "Script should be run as root"
echo "sudo setup_routing.sh"
fi


echo "# https://www.raspberrypi.org/documentation/configuration/wireless/access-point-routed.md" >> /etc/sysctl.d/routed-ap.conf
echo "# Enable IPv4 routing" >> /etc/sysctl.d/routed-ap.conf
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.d/routed-ap.conf

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

netfilter-persistent save

systemctl reboot