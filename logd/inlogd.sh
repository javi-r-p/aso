#!/bin/bash
if [ $EUID -ne 0 ]; then
	echo "El script debe ser ejecutado como root"
	exit 1
fi
test -e ./logd.sh
if [ $? -eq 1 ]; then
	echo "No se ha encontrado el archivo logd, y este es necesario para la instalación del servicio."
	echo "Asegúrate de que el archivo se encuentra en el mismo directorio que este script."
	exit 1
fi
echo "Instalación del servicio logd"
bin="/usr/bin"
cp ./logd.sh $bin/logd.sh
chmod +x logd.sh
log="/var/tmp/archivoRespuesta.txt"
touch $log
echo "Archivo de respuesta de la instalación de logd" >> $log
date +"%d.%m.%Y-%H.%M.%S.%2N" >> $log
archivoServicio="/etc/systemd/system/logd.service"
touch $archivoServicio
cat <<EOF | tee $archivoServicio > /dev/null
[Unit]
Description=Servicio de log del sistema
After=network.target

[Service]
ExecStart=$bin/logd.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload >> $log
systemctl enable >> $log
chown root:root $log
chmod 644 $log
systemctl start logd.service >> $log
systemctl status logd.service >> $log
echo "Instalando logcheck"
apt update > /dev/null 2> /dev/null
apt install logcheck -y > /dev/null 2> /dev/null
echo "Instalando msmtp"
apt install msmtp -y > /dev/null 2> /dev/null
echo "Instalando logger"
apt install logger -y > /dev/null 2> /dev/null
while
	read -p "¿Quieres ver el archivo de respuesta? (s/n) " opcion
	[ -z "$opcion" ]
do
	echo "Selecciona una opción."
done
if [[ "$opcion" == "s" || "$opcion" == "S" ]]; then
	clear
	cat $log
	exit 0
else
	echo "¡Hasta pronto!"
	exit 0
fi