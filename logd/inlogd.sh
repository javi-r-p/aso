#!/bin/bash
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root"
	exit 1
fi

if [[ ! -e ./logd.sh ]]; then
	echo "Couldn't find logd.sh."
	echo "Make sure the logd.sh file is in the same directory as this installer."
	exit 1
fi

#Logd conf directory
mkdir -p /etc/logd
chmod 755 /etc/logd

echo "Logd service installation"
bin="/usr/bin"
cp ./logd.sh $bin/logd.sh
chmod +x logd.sh
log="/tmp/answerFile.txt"
touch $log
echo "Logd installation answer file" >> $log
date +"%d.%m.%Y-%H.%M.%S.%2N" >> $log
serviceFile="/etc/systemd/system/logd.service"
touch $serviceFile

cat << EOF | tee $serviceFile > /dev/null
[Unit]
Description=System logging service
After=network.target

[Service]
ExecStart=$bin/logd.sh
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl enable logd.service >> $log 2>> $log

echo "Installing msmtp"
apt update >> $log 2>> $log
DEBIAN_FRONTEND=noninteractive apt install msmtp -y >> $log 2>> $log

echo "Installing logger"
apt install logger -y >> $log 2>> $log

echo "Installing sysstat"
apt install sysstat -y >> $log 2>> $log

echo "Installing certificates"
apt install ca-certificates -y >> $log 2>> $log

echo "-----"
echo "Alerts through email will be set up."
echo "It is really important to have an email account and an app key."
echo "If you don't have any app key, you can create it in the following website:"
echo "https://myaccount.google.com/apppasswords"
echo "---"
read -p "E-Mail account: " email
read -p "App key: " password

echo "Setting up msmtp"
touch /etc/msmtprc
chmod 600 /etc/msmtprc
chown root:root /etc/msmtprc

cat << EOF | tee /etc/msmtprc > /dev/null
defaults
auth on
tls on
tls_starttls on
tls_certcheck off
tls_trust_file /etc/ssl/certs/ca-certificates.crt

account default
host smtp.gmail.com
port 587
from $email
user $email
password $password
EOF

#Save e-mail address into a file
echo $email > /etc/logd/email

echo -e "To: $email\nSubject: Test E-Mail.\n\nThis is a test e-mail. Logd is being installed. If you received this e-mail, e-mail alerts do work." | msmtp -t >> $log 2>> $log
if [[ $? -eq 0 ]]; then
	echo "E-Mail sent."
else
	echo "There was an error. Couldn't send test e-mail"
	exit 1
fi

read -p "Introduce the name of every service you want to supervise: " services
echo $servicios > /tmp/services
tr ' ' '\n' < "/tmp/services" > /etc/logd/services.conf
rm /tmp/services

systemctl start logd.service >> $log
systemctl status logd.service >> $log

echo "The service was succesfully installed."
echo "If you wanted to change the supervised services, you must modify this file:"
echo "/etc/logd/services.conf" 
echo "Each service must be on a different line."
echo "-----"

systemctl daemon-reload >> $log

while
	read -p "Do you want to view the answer file? (y/n) " option
	[ -z "$option" ]
do
	echo "Select an option."
done
if [[ "$option" == "S" || "$option" == "Y" ]]; then
	clear
	cat $log
	exit 0
else
	echo "Bye!"
	exit 0
fi
