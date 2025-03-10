#!/bin/bash
if [[ $EUID -ne 0 ]]; then
	echo "El script debe ser ejecutado como root"
	exit 1
fi

test -e ./logd.sh
if [[ $? -eq 1 ]]; then
	echo "No se ha encontrado el archivo logd, y este es necesario para la instalación del servicio."
	echo "Asegúrate de que el archivo se encuentra en el mismo directorio que este script."
	exit 1
fi

#Directorio de configuración de logd
mkdir -p /etc/logd
chmod 755 /etc/logd

echo "Instalación del servicio logd"
bin="/usr/bin"
cp ./logd.sh $bin/logd.sh
chmod +x logd.sh
log="/tmp/archivoRespuesta.txt"
touch $log
echo "Archivo de respuesta de la instalación de logd" >> $log
date +"%d.%m.%Y-%H.%M.%S.%2N" >> $log
archivoServicio="/etc/systemd/system/logd.service"
touch $archivoServicio

cat << EOF | tee $archivoServicio > /dev/null
[Unit]
Description=Servicio de log del sistema
After=network.target

[Service]
ExecStart=$bin/logd.sh
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl enable logd.service >> $log 2>> $log

echo "Instalando msmtp"
apt update >> $log 2>> $log
DEBIAN_FRONTEND=noninteractive apt install msmtp -y >> $log 2>> $log

echo "Instalando logger"
apt install logger -y >> $log 2>> $log

echo "Instalando sysstat"
apt install sysstat -y >> $log 2>> $log

echo "Instalando certificados"
apt install ca-certificates -y >> $log 2>> $log

echo "-----"
echo "Se van a configurar las alertas por correo electrónico."
echo "Para ello, es importante que cuentes con una cuenta de correo electrónico y una clave de aplicación."
echo "Si aún no tienes una clave de aplicación, puedes generarla en la siguiente página:"
echo "https://myaccount.google.com/apppasswords"
echo "---"
read -p "Introduce una dirección de correo: " email
read -p "Introduce la clave de aplicación: " contrasenia

echo "Configurando msmtp"
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
password $contrasenia
EOF

#Almacenar dirección de correo en un archivo
echo $email > /etc/logd/correo

echo -e "To: $email\nSubject: Correo de prueba.\n\nCorreo de prueba, instalando el servicio logd" | msmtp -t >> $log 2>> $log
if [[ $? -eq 0 ]]; then
	echo "Correo enviado."
else
	echo "Ha habido un error al enviar el correo de prueba."
	exit 1
fi

read -p "Introduce los nombres de los servicios que quieres monitorizar separados por espacios: " servicios
echo $servicios > /tmp/servicios
tr ' ' '\n' < "/tmp/servicios" > /etc/logd/servicios.conf
rm /tmp/servicios

systemctl start logd.service >> $log
systemctl status logd.service >> $log

echo "Servicio instalado."
echo "Si quieres modificar los servicios que quieres monitorizar, modifica el siguiente archivo:"
echo "/etc/logd/servicios.conf" 
echo "Cada servicio que introduzcas debe estar en una línea diferente."
echo "-----"
echo "Creando entrada en crontab"
echo "*/5 * * * * root /bin/bash /usr/bin/logd.sh" | tee -a /etc/crontab > /dev/null 2> /dev/null

systemctl daemon-reload >> $log

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