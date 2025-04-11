#!/bin/bash
#Check the script is ran as root
if [ $EUID -ne 0 ]; then
	echo "This script must be run as root"
	exit 1
fi

#Welcome message
echo "Logd service uninstallation"
echo "Logs created with this service won't be deleted"

#Confirm uninstallation
while
	read -p "Do you really want to uninstall logd? (y/n) " option
	[ -z $option ]
do
	echo "Select a valid option"
done
if [ "$option" = "s" ]; then
	#Uninstallation
	systemctl stop logd.service > /dev/null 2> /dev/null
	rm -r /etc/systemd/system/logd.service /usr/bin/logd.sh /etc/logd /etc/msmtprc > /dev/null 2> /dev/null
	apt remove --purge msmtp logcheck logger -y > /dev/null 2> /dev/null
	apt autoremove -y > /dev/null 2> /dev/null
	systemctl daemon-reload > /dev/null 2> /dev/null
	echo "The service has been uninstalled. Bye!"
	exit 0
else
	echo "The service hasn't been installed. Bye!"
	exit 0
fi
