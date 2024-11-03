#!/bin/bash
#Script para unir clientes Ubuntu a un dominio de OpenLDAP.

#Crear directorio para los perfiles (móviles)
mkdir /profiles
chmod 777 /profiles

#Definición de colores.
fincolor='\e[0m'            #Eliminar color
namarillo='\033[1;33m'      #Amarillo negrita
ncian='\033[1;36m'          #Cián negrita
amarilloi='\033[0;93m'      #Amarillo intenso
rojoi='\033[0;91m'          #Rojo intenso
verdei='\033[0;92m'         #Verde intenso
azuli='\033[0;94m'          #Azul intenso
ciani='\033[0;96m'          #Cián intenso
nciani='\033[1;96m'         #Cián intenso y negrita
fnrojoi='\033[0;101m'       #Fondo rojo e intenso

#Función de salida
function salir() {
	if [ $1 = 0 ]; then
		echo -e "${verdei}Programa finalizado.${fincolor}"
		exit 0
	else
		echo -e "${rojoi}Programa finalizado.${fincolor}"
		exit $1
	fi
}

#Comprueba que el usuario que ejecuta el script es el usuario root. Si no lo es, se llama a la función SALIR con código 1
if [ $EUID != 0 ]; then
	echo "El script debe ser ejecutado como root."
	salir 1
fi

#Mensaje de bienvenida y recogida de datos.
clear
echo -e "${azuli}Unión de cliente Ubuntu a un dominio OpenLDAP${fincolor}"
while
	read -p "Dirección IP del servidor de OpenLDAP: " ip
	[ -z "$ip" ]
do
	echo "La dirección IP del servidor es obligatoria."
done
echo "Comprobando conectividad..."
ping -c2 $ip > /dev/null 2> /dev/null
if [ $? = 1 ]; then
	echo "No se ha podido contactar con el servidor. Revisa la configuración de red y asegúrate de que el servidor está conectado."
	salir 1
fi
while
	read -p "Nombre del dominio: " dominioDns
	[ -z "$dominioDns" ]
do
	echo "El nombre de dominio es obligatorio."
done
while
	read -p "Usuario administrador del dominio: " adminLDAP
	[ -z "$adminLDAP" ]
do
	echo "El nombre de usuario es obligatorio."
done
while
	read -s -p "Contraseña del usuario administrador: " contrasenia
	[ -z "$contrasenia" ]
do
	echo "La contraseña es obligatoria."
done
#echo $dominioDns >> /etc/hosts

#Tratamiento de las variables de la IP del servidor, nombre de dominio y usuario administrador.
uri="ldap://$ip"
dominio="dc=${dominioDns/./,dc=}"
adminLDAP="cn=$adminLDAP"

#Rutas de los archivos de configuración de OpenLDAP
ldap="/etc/ldap/ldap.conf"
ldap2="/etc/ldap.conf"
ldapsecret="/etc/ldap.secret"
nsswitch="/etc/nsswitch.conf"
nslcd="/etc/nslcd.conf"
fstab="/etc/fstab"
commonauth="/etc/pam.d/common-auth"
commonsession="/etc/pam.d/common-session"
commonpassword="/etc/pam.d/common-password"
commonaccount="/etc/pam.d/common-account"

#Introducir información en archivos
nss="compat ldap"
auth="auth sufficient pam_ldap.so"
session="session required pam_mkhomedir.so skel=/etc/skel umask=0022"
password="password sufficient pam_ldap.so"
account="account sufficient pam_ldap.so"

#Actualización de los índices de repositorio, e instalación de los paquetes para OpenLDAP.
clear
echo -e "${ncian}Actualizando el índice de los repositorios.${fincolor}"
apt clean > /dev/null 2> /dev/null
apt update > /dev/null 2> /dev/null
echo -e "${namarillo}Instalando librerías de OpenLDAP.${fincolor}"
DEBIAN_FRONTEND=noninteractive apt install libnss-ldap libpam-ldap ldap-utils nslcd nfs-common rpcbind -y > /dev/null 2> /dev/null

#Mensaje
echo "Configuración en proceso."

#Escritura sobre el archivo /etc/ldap/ldap.conf
echo "Configurando LDAP."
echo "BASE $dominio" > $ldap
echo "URI $uri" >> $ldap

#Escritura sobre el archivo /etc/ldap.conf
echo "base $dominio" > $ldap2
echo "uri $uri" >> $ldap2
echo "ldap_version 3" >> $ldap2
echo "rootbinddn $adminLDAP,$dominio" >> $ldap2
echo "pam_password md5" >> $ldap2

#Escritura sobre el archivo /etc/ldap.secret
echo "$contrasenia" >> $ldapsecret
chmod 600 $ldapsecret

#Escritura sobre el archivo /etc/nsswitch.conf
echo "Configurando autenticación."
sed -i "s|^passwd:.*|passwd: $nss|" "$nsswitch"
sed -i "s|^group:.*|group: $nss|" "$nsswitch"
sed -i "s|^shadow:.*|shadow: $nss|" "$nsswitch"

#Escritura sobre el archivo /etc/nslcd.conf
echo "uid nslcd" > $nslcd
echo "gid nslcd" >> $nslcd
echo "uri $ip" >> $nslcd
echo "base $dominio" >> $nslcd
echo "binddn $adminLDAP,$dominio" >> $nslcd
echo "bindpw $contrasenia" >> $nslcd
echo "tls_cacertfile /etc/ssl/certs/ca-certificates.crt" >> $nslcd

#Escritura sobre el archivo /etc/fstab
echo "Configurando automontaje de sistemas de archivos."
echo "$ip:/profiles /profiles nfs auto,noatime,nolock,bg,nfsvers=3,intr,tcp,actimeo=1800 0 0" >> $fstab

#Escritura sobre el archivo /etc/pam.d/common-auth
echo "$auth" >> $commonauth

#Escritura sobre el archivo /etc/pam.d/common-session
echo "$session" >> $commonsession

#Escritura sobre el archivo /etc/pam.d/common-password
echo "$password" >> $commonpassword

#Escritura sobre el archivo /etc/pam.d/common-account
echo "$account" >> $commonaccount

#Fin de configuración
echo "Configuración finalizada."
read -p "¿Quieres ejecutar el comando getent passwd? (s/n) " opcion
if [ "$opcion" = "s" ]; then
	getent passwd
else
	salir 0
fi
