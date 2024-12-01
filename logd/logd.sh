#!/bin/bash
#Archivo de bloqueo
lock="/var/lock/logd.lock"
if [ -e $lock ]; then
    echo "El servicio ya se está ejecutando"
    exit 0
fi
touch $lock
trap 'rm -f $lock; exit' EXIT SIGINT SIGTERM

#Fecha y hora
tiempo=`date +"%d-%m-%Y.%H:%M:%S"`

#Recoger dirección de correo electrónico y servicios registrados
correo=`cat /etc/logd/correo`
servicios=`cat /etc/logd/servicios.conf`

#Comprobar si el archivo log existe
if [ -e "/var/log/logd.log" ]; then
    touch /var/log/logd.log
fi
log="/var/log/logd.log"

echo "--- --- ---" >> $log
echo "Servicio iniciado en la fecha y hora $tiempo" >> $log
echo "--- --- ---" >> $log

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
    infoMemoria=`free -m | grep "Mem:" | awk '{print $2, $3, $4}'`
    read memoriaTotal memoriaUsada memoriaLibre <<< $infoMemoria
    usoRAM=$((100 * memoriaUsada / memoriaTotal))

    echo "-----" >> $log
    echo "Uso de la memoria RAM: $usoRAM%" >> $log
    echo "---" >> $log
    ps aux --sort=-%mem | head -n 6 >> $log

    if [[ $usoRAM -gt 80 ]]; then
        enviarCorreo "Uso de memoria RAM" "El uso de la RAM está por encima del 85%, los 5 procesos con más consumo son:\n `ps aux --sort=-%mem | head -n 6`"
    fi
}

#Uso del procesador
function usoProc {
    usoProc=`grep 'cpu ' /proc/stat | awk '{print ($2+$4)*100/($2+$4+$5)}'`
    usoProc=$(echo "scale=0; $usoProc/1" | bc)

    echo "-----" >> $log
    echo "Uso del procesador: $usoProc%" >> $log
    echo "---" >> $log
    ps aux --sort=-%cpu | head -n 6 >> $log

    if [[ $usoProc -gt 90 ]]; then
        enviarCorreo "Uso de procesador" "El uso del procesador está por encima del 90%, los 5 procesos con más consumo son:\n `ps aux --sort=-%cpu | head -n 6`"
    fi
}

#Uso de los discos
function usoDiscos {
    echo "-----" >> $log
    df -h | grep -E '^/dev/' | awk '{print $1, $5}' | while read disco; do
        volumen=$(echo $disco | awk '{print $1}')
        uso=$(echo $disco | awk '{print $2}' | sed 's/%//')

        echo "Disco: $volumen; uso: $uso%" >> $log
        echo "---" >> $log

        if [[ $uso -gt 80 ]]; then
            enviarCorreo "El almacenamiento se está agotando" "El disco $volumen tiene un uso del $uso%."
            categorias 1 "ALERT: Disk usage over 80%"
        fi
    done
}

#Comprobar servicios
function comprobarServicios {
    echo "-----" >> $log
    for servicio in $servicios; do
        if systemctl is-active --quiet $servicio; then
            echo "Servicio $servicio en funcionamiento." >> $log
            echo "---" >> $log
        else
            echo "El servicio $servicio está detenido." >> $log
            enviarCorreo "Servicio $servicio" "El servicio $servicio está detenido."
            categorias 2 "CRITICAL: Service $servicio is not working"
        fi
    done
}

#Bucles
#(
#    while true
#    do
#        uptime -p >> $log
#        sleep 43200
#    done
#) &
(
    while true
    do
        usoDiscos
        comprobarServicios
        sleep 10
    done
) &
(
    while true
    do
        usoRAM
        usoProc
        sleep 10
    done
)

#Eliminar el archivo de bloqueo cuando se pare el servicio
wait
rm -f $lock