#!/bin/bash
discos=`df -h | grep '^/dev' | awk '{print "Partición: " $1 " Total: " $2 " Espacio en uso: " $3 " Espacio disponible: " $4 " Porcentaje de uso: " $5 " Punto de montaje: " $6}'`
for disco in $discos
do
	if [[ "$disco" =~ ^/dev ]]; then
		echo " ----- "
	fi
	echo $disco
done