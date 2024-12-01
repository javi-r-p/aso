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

echo "Instalando logcheck"
apt update > $log 2>> $log
apt install logcheck -y >> $log 2>> $log

echo "Instalando msmtp"
apt install msmtp -y >> $log 2>> $log

echo "Instalando logger"
apt install logger -y >> $log 2>> $log

echo "Instalando certificados"
apt install ca-certificates >> $log 2>> $log

while
	read -p "Introduce una dirección de correo: " email
	[ -z $email ]
do
	echo "No has introducido ninguna dirección de correo."
done
while
	read -s -p "Introduce la contraseña de la cuenta de correo electrónico: " contrasenia
	echo ""
	read -s -p "Confirma la contraseña: " contrasenia2
	[ "$contrasenia" != "$contrasenia2" ]
do
	echo "Las contraseñas no coinciden. Inténtalo de nuevo."
done

echo "Configurando msmtp"
touch /etc/msmtprc
chmod 600 /etc/msmtprc
chown root:root /etc/msmtprc

cat << EOF | tee /etc/msmtprc
defaults
auth on
tls on
tls_starttls on
tls_certcheck off
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile /var/log/msmtp.log

account default
host smtp.gmail.com
port 587
from $email
user $email
password $contrasenia
EOF

touch /var/log/msmtp.log
chmod 600 /var/log/msmtp.log
chown root:root /var/log/msmtp.log

echo -e "To: $email\nSubject: Correo de prueba." | msmtp -t
if [[ $? -eq 0 ]]; then
	echo "Correo enviado."
else
	echo "Ha habido un error al enviar el correo de prueba."
fi

systemctl start logd.service >> $log
systemctl status logd.service >> $log

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