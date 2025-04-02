#!/bin/bash
#Lock file
lock="/var/lock/logd.lock"
if [ -e $lock ]; then
    echo "Service already running"
    exit 0
fi
touch $lock
trap 'rm -f $lock; exit' EXIT SIGINT SIGTERM

#Time and date
datetime=`date +"%d-%m-%Y.%H:%M:%S"`

#Get email address and registered service to supervise
email=`cat /etc/logd/email`
services=`cat /etc/logd/services.conf`

#Check if log file already exists
if [ -e "/var/log/logd.log" ]; then
    touch /var/log/logd.log
fi
log="/var/log/logd.log"

echo "--- --- ---" >> $log
echo "Service started at $datetime" >> $log
echo "--- --- ---" >> $log

#Functions
function categories {
    case "$1" in
        0) logger -p user.emerg "$2";;
        1) logger -p user.alert "$2";;
        2) logger -p user.crit "$2";;
        3) logger -p user.err "$2";;
        4) logger -p user.warning "$2";;
    esac
}
function sendEmail {
	datetime=`date +"%d-%m-%Y.%H:%M:%S"`
    echo -e "Subject: $datetime - $1\n\n$2" | msmtp $email
}

#System monitoring
#RAM Usage
function RAMUsage {
    memInfo=`free -m | grep "Mem:" | awk '{print $2, $3, $4}'`
    read totalMemory usedMemory freeMemory <<< $memInfo
    percentage=$((100 * usedMemory / totalMemory))

    echo "-----" >> $log
    echo "RAM usage is at: $percentage%" >> $log
    echo "---" >> $log
    ps aux --sort=-%mem | head -n 6 >> $log

    if [[ $RAMUsage -gt 75 ]]; then
        sendEmail "RAM Usage" "RAM Usage is above 75%, the top 5 consuming processes are:\n `ps aux --sort=-%mem | head -n 6`"
    fi
}

#Processor usage
function procUsage {
	procInfo=`mpstat | awk '{print $12}' | tail -n 1`
	procInfo=$(echo "scale=0; 100 - $procInfo" | bc)
    echo "-----" >> $log
    echo "Processor usage: $procInfo%" >> $log
    echo "---" >> $log
    ps aux --sort=-%cpu | head -n 6 >> $log

    if [[ $procUsage -gt 80 ]]; then
        sendEmail "Processor usage" "Processor usage is above 80%, the top 5 consuming processes are:\n `ps aux --sort=-%cpu | head -n 6`"
    fi
}

#Disk usage
function disksUsage {
    echo "-----" >> $log
    df -h | grep -E '^/dev/' | awk '{print $1, $5}' | while read disk; do
        volume=$(echo $disk | awk '{print $1}')
        usage=$(echo $disk | awk '{print $2}' | sed 's/%//')

        echo "Volume: $volume; usage: $usage%" >> $log
        echo "---" >> $log

        if [[ $usage -gt 80 ]]; then
            sendEmail "Storage is running out" "The volume $volume has an usage of $usage%."
            categories 1 "ALERT: Volume $volume usage over 80%"
        fi
    done
}

#Check services
function checkServices {
    echo "-----" >> $log
    for service in $services; do
        if systemctl is-active --quiet $service; then
            echo "Service $service is running." >> $log
            echo "---" >> $log
        else
            echo "Service $service is stopped." >> $log
            sendEmail "Service $service" "Service $service is stopped."
            categories 2 "CRITICAL: Service $service is stopped"
        fi
    done
}

#Loops
(
    while true
    do
        uptime -p >> $log
        sleep 10800
    done
) &
(
    while true
    do
        disksUsage
        checkServices
        sleep 600
    done
) &
(
    while true
    do
        RAMUsage
        procUsage
        sleep 300
    done
)

#Delete lock file at service stop signal
wait
rm -f $lock