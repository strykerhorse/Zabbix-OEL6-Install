#!/bin/bash
#
# this script rolls back changes made by the OCONUS_OEL_Zabbix_Agent.sh script
# through the following steps:
#
# reminding the user to contact their GTM for backout approval:
#
# stopping, disabling, and uninstalling the zabbix agent (while logging
# these actions);
# clearing the contents of the /etc/zabbix/directory; and
# removing the old zabbix directory at /etc/zabbix

# first, let's make this look good
# define a "centering function" that centers text in the terminal for later
# use

function print_centered {
     [[ $# == 0 ]] && return 1

     declare -i TERM_COLS="$(tput cols)"
     declare -i str_len="${#1}"
     [[ $str_len -ge $TERM_COLS ]] && {
          echo "$1";
          return 0;
     }

     declare -i filler_len="$(( (TERM_COLS - str_len) / 2 ))"
     [[ $# -ge 2 ]] && ch="${2:0:1}" || ch=" "
     filler=""
     for (( i = 0; i < filler_len; i++ )); do
          filler="${filler}${ch}"
     done

     printf "%s%s%s" "$filler" "$1" "$filler"
     [[ $(( (TERM_COLS - str_len) % 2 )) -ne 0 ]] && printf "%s" "${ch}"
     printf "\n"

     return 0
}
# define hostname variable
print_hostname=cat /proc/sys/kernel/hostname
# and now, courtesy of https://scripter.co/count-down-timer-in-shell/, define
# variables for a countdown timer

wait_time=10 # seconds to count down from

# log start of this script in syslog
logger "Zabbix agent rollback script started" -t Zabbix-Agent-Rollback
# set reminder to contact GTM, sleep 5 sec, log run
## set countdown variable 
countdown=${wait_time}
# build notifier structure 
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
print_centered "This script assumes you have contacted your GTM about this rollback action." 
print_centered "If not, please end this script and do not continue."
logger "GTM notification displayed" -t Zabbix-Agent-Rollback
while [[ ${countdown} -gt 0 ]];
do
print_centered "Press Ctrl+C within $countdown second(s) to end this script."
sleep 1
((countdown--))
done
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

# stop zabbix agent, log
service zabbix-agent stop
logger "GTM rollback countdown displayed for 10 seconds, moving on...." -t Zabbix-Agent-Rollback
# disable zabbix agent, log
chkconfig zabbix-agent off
logger "Disabled Zabbix agent start at system startup" -t Zabbix-Agent-Rollback
# uninstall zabbix agent, log
yum remove zabbix-agent -y
logger "Removed Zabbix agent using yum" -t Zabbix-Agent-Rollback
# remove old zabbix directory leftovers, log
rm -rf /etc/zabbix/*
logger "Removed contents of /etc/zabbix directory" -t Zabbix-Agent-Rollback
# remove old zabbix directory
rmdir /etc/zabbix
logger "Removed /etc/zabbix directory" -t Zabbix-Agent-Rollback
# notify zabbix SME to remove this host from Zabbix inventory, log response
printf "\nPlease notify the Zabbix SME to remove this host (${print_hostname})from inventory.\n"
logger "Echoed Zabbix SME notification to screen" -t Zabbix-Agent-Rollback
# end
