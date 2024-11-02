#!/bin/bash
#Script para unir clientes Ubuntu a un dominio de OpenLDAP.

#Definición de colores.
fincolor='\e[0m'            #Eliminar color
namarillo='\033[1;33m'      #Amarillo negrita
bcian='\033[1;36m'          #Cián negrita
amarilloi='\033[0;93m'      #Amarillo intenso
rojoi='\033[0;91m'          #Rojo intenso
verdei='\033[0;92m'         #Verde intenso
azuli='\033[0;94m'          #Azul intenso
ciani='\033[0;96m'          #Cián intenso
nciani='\033[1;96m'         #Cián intenso y negrita
fnrojoi='\033[0;101m'       #Fondo rojo e intenso

#Mensaje de bienvenida y recogida de datos.
echo "Unión de cliente Ubuntu a un dominio OpenLDAP"
while
	read -p "Dirección IP del servidor de OpenLDAP: " ip
	[ -z "$ip" ]
do
	echo "La dirección IP del servidor es obligatoria."
done
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
	read -p "Contraseña del usuario administrador: " contrasenia
	[ -z "$contrasenia" ]
do
	echo "La contraseña es obligatoria."
done
