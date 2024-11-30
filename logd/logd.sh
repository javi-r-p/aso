#!/bin/bash
#Comprobar si el archivo log existe
buscarArchivo=`test -e /var/log/logd`
codigoBA=`$?`
if [ "$codigoBA" = "1" ]; then
        touch /var/log/logd.log
fi
logFile="/var/log/logd.log"
#Monitorización del sistema
while true
do
echo "----- ----- -----" | tee -a $logFile
date +"%d.%m.%Y-%H.%M.%S.%N" | tee -a $logFile
echo "5 procesos con mas consumo" | tee -a $logFile
ps aux --sort=-%cpu,-%mem | head -n 6 | tee -a $logFile
echo "-----" | tee -a $logFile
echo "Uso de particiones" | tee -a $logFile
df -h | awk '$5+0 > 90 {print $1, $5}' | tee -a $logFile
echo "-----" | tee -a $logFile
logger -t monitorizacion -f $logFile
sleep 10
done