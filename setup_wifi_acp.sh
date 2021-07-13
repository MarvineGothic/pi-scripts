#!/bin/bash

#check if run as root
who=$(whoami)
if [ $who == "root" ]
then
echo ""
else
echo "Script should be run as root"
echo "sudo setup_wifi_acp.sh"
fi

apt-get install -y hostapd
apt-get install -y dnsmasq

systemctl unmask hostapd
systemctl enable hostapd

sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent


wifipass () {
echo;echo;echo
echo "This password will be used to connect to the pi"
echo "when the pi is in hotspot mode"
echo "Password should be between 8-63 characters"
read -p "Enter password to use with new hotspot " wifipasswd
COUNT=${#wifipasswd}
if [ $COUNT -lt 8 ]
then
echo "Password must be at least 8 characters long"
sleep 2
wifipass
fi
echo;echo
echo "You entered $wifipasswd"
read -p "Is this correct? y/n " wifians
if [ $wifians == "y" ]
then
echo
else
wifipass
fi
}

wifipass

echo "interface wlan0" >> /etc/dhcpcd.conf
echo "static ip_address=192.168.0.31/24" >> /etc/dhcpcd.conf
echo "nohook wpa_supplicant" >> /etc/dhcpcd.conf

mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
touch /etc/dnsmasq.conf

echo "interface=wlan0" >> /etc/dnsmasq.conf
echo "dhcp-range=192.168.0.32,192.168.0.50,255.255.255.0,24h" >> /etc/dnsmasq.conf
echo "domain=wlan" >> /etc/dnsmasq.conf
echo "address=/gw.wlan/192.168.0.31" >> /etc/dnsmasq.conf

rfkill unblock wlan

touch /etc/hostapd/hostapd.conf
echo "country_code=DK" >> /etc/hostapd/hostapd.conf
echo "interface=wlan0" >> /etc/hostapd/hostapd.conf
echo "ssid=wifipi" >> /etc/hostapd/hostapd.conf
echo "hw_mode=g" >> /etc/hostapd/hostapd.conf
echo "channel=7" >> /etc/hostapd/hostapd.conf
echo "macaddr_acl=0" >> /etc/hostapd/hostapd.conf
echo "auth_algs=1" >> /etc/hostapd/hostapd.conf
echo "ignore_broadcast_ssid=0" >> /etc/hostapd/hostapd.conf
echo "wpa=2" >> /etc/hostapd/hostapd.conf
echo "wpa_passphrase=$wifipasswd" >> /etc/hostapd/hostapd.conf
echo "wpa_key_mgmt=WPA-PSK" >> /etc/hostapd/hostapd.conf
echo "wpa_pairwise=TKIP" >> /etc/hostapd/hostapd.conf
echo "rsn_pairwise=CCMP" >> /etc/hostapd/hostapd.conf

systemctl reboot