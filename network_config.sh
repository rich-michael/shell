#!/bin/bash
#检查网卡个数
total=`route -n|wc -l`
em=$[$total-3]

#设置/etc/network/interfaces
for i in `seq $em`
do
read -p "enter your netname:" ip
cat << EOF > /etc/network/interfaces
auto em$i
iface em$i inet static
address $ip
gateway 192.168.1.1
netmask 255.255.255.0
nameserver 202.96.134.133
nameserver 202.96.128.86
EOF
done
#设置/etc/resolv.conf
sudo cat << EOF >> /etc/resolv.conf
nameserver 202.96.134.133
EOF
#设置/etc/resolvconf/resolv.conf.d/base（本地DNS）
sudo cat << EOF >> /etc/resolvconf/resolv.conf.d/base
nameserver 192.168.1.1
nameserver 0.0.0.0
EOF
#网络重启
sudo /etc/init.d/networking restart
sudo reboot
