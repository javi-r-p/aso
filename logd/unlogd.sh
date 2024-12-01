#!/bin/bash
#Se comprueba que quien ejecuta el script es el usuario root
if [ $EUID -ne 0 ]; then
	echo "El script debe ser ejecutado como root"
	exit 1
fi
#Mensaje de bienvenida
echo "Desinstalación del servicio logd"
#Confirmación de desinstalación
while
	read -p "¿Seguro que deseas desinstalar logd? (s/n) " opcion
	[ -z $opcion ]
do
	echo "Selecciona una opción válida"
done
if [ "$opcion" = "s" ]; then
	#Desinstalación
	systemctl stop logd.service > /dev/null 2> /dev/null
	rm /etc/systemd/system/logd.service /usr/bin/logd.sh > /dev/null 2> /dev/null
	apt remove --purge msmtp logcheck logger -y > /dev/null 2> /dev/null
	apt autoremove -y > /dev/null 2> /dev/null
	echo "El servicio logd se ha desinstalado. ¡Hasta pronto!"
	exit 0
else
	echo "No se ha desinstalado logd. ¡Hasta pronto!"
	exit 0
fi