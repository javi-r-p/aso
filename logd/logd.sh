#!/bin/bash
#Archivo de bloqueo
lock="/var/lock/logd.lock"
if [ -e $lock ]; then
    echo "El servicio ya se está ejecutando"
    exit 0
fi
touch $lock

#Fecha y hora
tiempo=`date +"%d-%m-%Y.%H:%M:%S"`

#Recoger dirección de correo electrónico
correo=`cat /etc/logd/correo`

#Comprobar si el archivo log existe
if [ -e "/var/log/logd.log" ]; then
    touch /var/log/logd.log
fi
log="/var/log/logd.log"

echo "--- --- ---" >> $log
echo "Servicio iniciado en la fecha y hora $tiempo" >> $log

#Funciones
function categorias {
    case "$1" in
        0) logger -p user.emerg "$2";;
        1) logger -p user.alert "$2";;
        2) logger -p user.crit "$2";;
        3) logger -p user.err "$2";;
        4) logger -p user.warning "$2";;
    esac
}
function enviarCorreo {
    echo -e "Subject: $tiempo - $1\n\n$2" | msmtp $correo
}

#Monitorización del sistema
#Uso de la memoria RAM
function usoRAM {
    infoMemoria=`free -mh | grep "Mem:" | awk '{print $2, $3, $4}'`
    read memoriaTotal memoriaUsada memoriaLibre <<< $infoMemoria
    usoRAM=$((100 * memoriaUsada / memoriaTotal))
    procesosRAM=`ps aux --sort=-%mem | head -n 6`

    echo $usoRAM >> $log
    echo "---" >> $log
    echo $procesosRAM >> $log

    if [[ $usoRAM -gt 85 ]]; then
        enviarCorreo "Uso de memoria RAM" "El uso de la RAM está por encima del 85%, los 5 procesos con más consumo son: $procesos"
    fi
}

#Uso del procesador
function usoProc {
    usoProc=`grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}'`
    procesosProc=`ps aux --sort=-%cpu | head -n 6`

    echo $usoProc >> $log
    echo "---" >> $log
    echo $procesosProc >> $log
    if [[ $usoProc -gt 90 ]]; then
        enviarCorreo "Uso de procesador" "El uso del procesador está por encima del 90%, los 5 procesos con más consumo son: $procesos"
    fi
}

#Comprobar servicios
#function comprobarServicios {

#}

#Bucles
(
    while true; do
        uptime -p >> $log
        sleep 43200
    done
) & (
    while true; do
        comprobarServicios
        sleep 900
    done
) & (
    while true; do
        usoRAM
        usoProc
        sleep 300
    done
)

#Eliminar el archivo de bloqueo cuando se pare el servicio
wait
rm -f $lock