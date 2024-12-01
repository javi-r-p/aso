#!/bin/bash
#Comprobar si el archivo log existe
buscarArchivo=`test -e /var/log/logd`
codigoBA=`$?`
if [ "$codigoBA" = "1" ]; then
        touch /var/log/logd.log
fi
logFile="/var/log/logd.log"
#Monitorización del sistema
