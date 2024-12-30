#!/bin/bash

if [ $EUID -ne 0 ]; then
	echo "El script debe ser ejecutado como root"
	exit 1
fi

echo "Instalación del servicio de OpenLDAP y NFS"

apt update > /dev/null 2> /dev/null
echo "Instalando OpenLDAP"
apt install slapd ldap-utils -y > /dev/null 2> /dev/null
echo "Instalando NFS"
apt install nfs-server -y > /dev/null 2> /dev/null