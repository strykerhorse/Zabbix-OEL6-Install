#!/bin/bash

# this script installs the zabbix agent onto CentOS hosts, adds a custom
# config file to the zabbix root directory, and starts and enables the service.

# install the zabbix agent rpm and run yum clean
rpm -ivh zabbix-agent-4.4.9-1.el6.x86_64.rpm
yum clean all
logger "Zabbix RPM installed and yum cache cleaned." -t OCONUS-OEL-Zabbix-Install-Script
# install zabbix agent in yum
yum install zabbix-agent
logger "Zabbix agent installed" -t OCONUS-OEL-Zabbix-Install-Script
# copy custom zabbix agent config file from this directory to /etc/zabbix
mv zabbix_agentd.conf /etc/zabbix/
logger "Zabbix agent config moved to zabbix agent directory" -t OCONUS-OEL-Zabbix-Install-Script
# change perms and ownership on the config file
chmod 644 /etc/zabbix/zabbix_agentd.conf
chown root:root /etc/zabbix/zabbix_agentd.conf
logger "Zabbix agent config chmod'd to 644 and chown'd to root:root" -t OCONUS-OEL-Zabbix-Install-Script
# start zabbix-agent service
service zabbix-agent restart
logger "Restarting Zabbix agent" -t OCONUS-OEL-Zabbix-Install-Script
# enable zabbix-agent service
chkconfig --level 35 zabbix-agent on
logger "Enabling Zabbix agent start upon reboot" -t OCONUS-OEL-Zabbix-Install-Script
# end
