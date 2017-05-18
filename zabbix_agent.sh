#!/bin/bash
sudo apt-get install zabbix-agent
sudo sed -i 's/Server=127.0.0.1/Server=192.168.0.174/g'  /etc/zabbix/zabbix_agentd.conf
sudo sed -i 's/Hostname=Zabbix\ server/Hostname=$HOSTNAME/g'  /etc/zabbix/zabbix_agentd.conf
