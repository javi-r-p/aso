#!/bin/bash
#Comprobar si el archivo log existe
buscarArchivo=$(test -e /var/log/logd)
if [ $? -eq 1 ]; then
        touch /var/log/logd.log
fi
logFile="/var/log/logd.log"
#Monitorización del sistema
