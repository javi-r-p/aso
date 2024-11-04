#!/bin/bash
#Script desarrollado para facilitar la administración de objetos de OpenLDAP.

#Comprobar que el usuario que está ejecutando el script sea root,
#si no lo fuera, finalizar el programa.
if [ "$EUID" != "0" ]; then
	echo "El script debe ser ejecutado por el usuario root."
	exit 1
fi

#Ficheros LDIF y logs de errores (temporales) en /tmp
touch /tmp/ou.ldif
touch /tmp/uid.ldif
touch /tmp/gid.ldif
touch /tmp/objetos.log
touch /tmp/errores.log
ou="/tmp/ou.ldif"
uid="/tmp/uid.ldif"
gid="/tmp/gid.ldif"
objetos="/tmp/objetos.log"
errores="/tmp/errores.log"

clear

#Comprobar que los paquetes slapd y ldaputils están instalados,
#si no, mostrar un mensaje
comprobarSlapd=`dpkg -l | grep "slapd"`
comprobarLdaputils=`dpkg -l | grep "ldap-utils"`
if [ -z "$comprobarSlapd" ] || [ -z "$comprobarLdaputils" ]; then
	echo "Es posible que uno de los paquetes no esté instalado. Instálalo y vuelve a ejecutar el script."
	exit 1
fi

#Definición de colores
fincolor='\e[0m'	    	#Eliminar color
namarillo='\033[1;33m'      #Amarillo negrita
bcian='\033[1;36m'          #Cián negrita
amarilloi='\033[0;93m'      #Amarillo intenso
rojoi='\033[0;91m'          #Rojo intenso
verdei='\033[0;92m'         #Verde intenso
azuli='\033[0;94m'          #Azul intenso
ciani='\033[0;96m'          #Cián intenso
nciani='\033[1;96m'         #Cián intenso y negrita
fnrojoi='\033[0;101m'       #Fondo rojo e intenso

#Función de salida
function salir() {
	if [ "$1" = "0" ]; then
		echo -e "${verdei}Programa finalizado.${fincolor}"
		exit 0
	else
		echo -e "${rojoi}Programa finalizado.${fincolor}"
		exit $1
	fi
}

#Función de control de errores
function controlErrores() {
	echo -e "${fnrojoi}ERROR${fincolor}"
	case $1 in
	2)
		echo "Error de protocolo. (2)";;
	3)
		echo "Tiempo límite excedido. (3)";;
	4)
		echo "Tamaño límite excedido. (4)";;
	7)
		echo "Método de autenticación no soportado. (7)";;
	8)
		echo "Se requiere un método de autenticación más seguro. (8)";;
	13)
		echo "Los datos deben de estar protegidos. (13)";;
	14)
		echo "Reenviar petición para continuar con el método de autenticación. (14)";;
	16)
		echo "Esa entrada no contiene el atributo especificado. (16)";;
	17)
		echo "Atributo indefinido. (17)";;
	20)
		echo "Dicho atributo ya existe. (20)";;
	21)
		echo "El atributo especificado no corresponde con su sintaxis. (21)";;
	32)
		echo "No existe el objeto especificado. (32)";;
	34)
		echo "DN inválido. (34)";;
	48)
		echo "Método de autenticación no válido. (48)";;
	49)
		echo "Credenciales inválidas. (49)";;
	50)
		echo "Permisos insuficientes. (50)";;
	51)
		echo "Servidor ocupado. (51)";;
	52)
		echo "Servidor no disponible. (52)";;
	64)
		echo "Nombre de entrada no válido. (64)";;
	65)
		echo "Tipo de objeto no válido. (65)";;
	68)
		echo "Dicha entrada ya existe. (68)";;
	69)
		echo "No está permitido cambiar el tipo de objeto. (69)";;
	80)
		echo "Error interno del servidor. (80)";;
	*)
		echo "Error.";;
	esac
}

#Obtener nombre de dominio, formato DN y DNS
dominio=`slapcat | head -n 1`
dominio=${dominio/dn: /}
dominioDns=${dominio/dc=/}
dominioDns=${dominioDns/,dc=/.}

#Obtener nombre del administrador de OpenLDAP
adminLDAP=`slapcat | head -n 9 | tail -n 1`
adminLDAP=${adminLDAP/creatorsName: /}

#Menú de opciones y recogida de datos
echo -e "${namarillo}Bienvenido al programa de gestión de objetos de OpenLDAP.${fincolor}"
echo -e "${nciani}-----${fincolor} "
while
	read -s -p "Contraseña del administrador de LDAP: " contrasenia #Preguntar por la contraseña del administrador de OpenLDAP.
	[ -z "$contrasenia" ]
do
	echo "Debes introducir una contraseña."
done
clear
echo -e "${namarillo}Bienvenido al programa de gestión de objetos de OpenLDAP.${fincolor}"
echo -e "${ciani}-----${fincolor}"
echo -e "${azuli}Opciones${fincolor}"
echo -e "${verdei}1: Crear un objeto:${fincolor}"
echo -e "    ${verdei}1: Unidad organizativa.${fincolor}"
echo -e "    ${verdei}2: Usuario.${fincolor}"
echo -e "    ${verdei}3: Grupo.${fincolor}"
echo -e "${rojoi}2: Eliminar un objeto:${fincolor}"
echo -e "    ${rojoi}1: Unidad organizativa.${fincolor}"
echo -e "    ${rojoi}2: Usuario.${fincolor}"
echo -e "    ${rojoi}3: Grupo.${fincolor}"
echo -e "${azuli}3: Modificar un objeto:${fincolor}"
echo -e "    ${azuli}1: Unidad organizativa.${fincolor}"
echo -e "    ${azuli}2: Usuario.${fincolor}"
echo -e "    ${azuli}3: Grupo.${fincolor}"
echo -e "${fnrojoi}4: Salir.${fincolor}"
read -p "Introduce un número (e.j.: 11 crea una unidad organizativa, 4 sale del programa.): " opcion

#Funciones
#Crear
#Crear unidad organizativa
function crearUO {
	read -p "Nombre: " nombre
	echo "dn: ou=$nombre,$dominio" > $ou
	echo "objectClass: top" >> $ou
	echo "objectClass: organizationalUnit" >> $ou
	echo "ou: $nombre" >> $ou
	date >> $crearObjetos
	date >> $erorres
	ldapadd -x -D "$adminLDAP" -w "$contrasenia" -f $ou >> $objetos 2> $errores
	codError=$?
	if [ "$codError" = "0" ]; then
		echo "Unidad organizativa creada."
		#Preguntar si se quiere ver la información del usuario.
		read -p "¿Quieres ver la información de la unidad organizativa $name? (s/n) " mostrar
		if [ "$mostrar" = "s" ]; then
			ldapsearch -xLLL -b $dominio ou=$nombre
		else
			salir $codError
		fi
	else
		controlErrores $codError
		salir $codError
	fi
}

#Crear usuario
function crearUsuario {

	#Crear unidad organizativa usuarios si no existe.
	echo "Todos los usuarios estarán ubicados en la unidad organizativa usuarios."
	busquedaOU=`ldapsearch -xLLL -b $dominio ou=usuarios`
	if [ -z "$busquedaOU" ]; then
		echo "dn: ou=usuarios,$dominio" > $ou
		echo "objectClass: top" >> $ou
		echo "objectClass: organizationalUnit" >> $ou
		echo "ou: usuarios" >> $ou
		date >> $objetos
		date >> $errores
		ldapadd -x -D "$adminLDAP" -w "$contrasenia" -f $ou >> $objetos 2> $errores
	fi
	echo -e "${fnrojoi}¡IMPORTANTE!${fincolor}"
	echo "La contraseña será igual que el nombre del usuario."
	read -p "Nombre de usuario: " uid
	read -p "Nombre: " nombrePila
	read -p "Apellido/s: " apellidos
	read -p "Grupo al que pertenece el usuario: " nombreGrupo
	grupo=`ldapsearch -xLLL -b $dominio "(&(cn=$nombreGrupo)(objectClass=posixGroup))"`
	rutaObjeto=${grupo/dn: /}

	#Si el grupo en el que se desea que esté el usuario no existiera o no se encontrara,
	#se creará un nuevo grupo con el nombre que se especificó anteriormente.
	if [ -z "$grupo" ]; then
		#Crear nuevo grupo.
		echo "Grupo no encontrado. Creando nuevo grupo con el nombre $nombreGrupo."
		echo "dn: cn=$nombreGrupo,$dominio" > $gid
		echo "objectClass: posixGroup" >> $gid
		echo "cn: $nombreGrupo" >> $gid
		ultimoGid=`ldapsearch -xLLL -b $dominio "objectClass=posixGroup" | grep "gidNumber" | tail -n 1`
		intGid=${ultimoGid/gidNumber: /}
		intGid=$((intGid+1))
		echo "gidNumber: $intGid" >> $gid
		date >> $objetos
		date >> $errores
		ldapadd -x -D "$adminLDAP" -w "$contrasenia" -f $gid >> $objetos 2> $errores
	else
		#Añadir usuario al grupo ya existente.
		echo "El grupo $nombreGrupo se ha encontrado. El usuario $uid pertenecerá a dicho grupo."
		consultaGid=`ldapsearch -xLLL -b $dominio "(&(cn=$nombreGrupo)(objectClass=posixGroup))" | grep "gidNumber"`
		intGid=${consultaGid/gidNumber: /}
	fi

	#Recuperar UID con el valor más alto. Si no hay ningún usuario creado, se empezará por el número 80000
	consultaUid=`ldapsearch -xLLL -b $dominio "objectClass=posixAccount" | grep "uidNumber" | tail -n 1`
	intUid=${consultaUid/uidNumber: /}
	if [ -z "$intUid" ]; then
		intUid=80000
	else
		intUid=$((intUid+1))
	fi

	#Inserción de atributos del objeto al archivo que será ejecutado posteriormente.
	echo "dn: uid=$uid,ou=usuarios,$dominio" > $uid
	echo "objectClass: inetOrgPerson" >> $uid
	echo "objectClass: posixAccount" >> $uid
	echo "objectClass: shadowAccount" >> $uid
	echo "uid: $uid" >> $uid
	echo "givenName: $nombrePila" >> $uid
	echo "sn: $apellidos" >> $uid
	echo "cn: $nombrePila $apellidos" >> $uid
	echo "displayName: $nombrePila $apellidos" >> $uid
	echo "uidNumber: $intUid" >> $uid
	echo "gidNumber: $intGid" >> $uid
	echo "userPassword: $uid" >> $uid
	echo "loginShell: /bin/bash" >> $uid
	echo "homeDirectory: /profiles/$uid" >> $uid
	echo "mail: $uid@$dominioDns" >> $uid
	date >> $objetos
	date >> $errores

	#Ejecución del archivo LDIF.
	ldapadd -x -D "$adminLDAP" -w "$contrasenia" -f $uid >> $objetos 2> $errores
	codError=$?
	if [ "$codError" = "0" ]; then
		echo "Usuario creado."
		#Preguntar si se quiere ver la información del usuario.
			read -p "¿Quieres ver la información del usuario $givenName? (s/n) " mostrar
			if [ "$mostrar" = "s" ]; then
				ldapsearch -xLLL -b $dominio uid=$uid
			else
				salir $codError
			fi
	else
		controlErrores $codError
		salir $codError
	fi
}

#Crear grupo
function crearGrupo {

	#Crear unidad organizativa grupos si no existe.
	echo "Todos los grupos que crees mediante este script estarán ubicados en la unidad organizativa grupos."
	busquedaOU=`ldapsearch -xLLL -b $dominio ou=grupos`
	if [ -z "$busquedaOU" ]; then
		echo "dn: ou=grupos,$dominio" > $ou
		echo "objectClass: top" >> $ou
		echo "objectClass: organizationalUnit" >> $ou
		echo "ou: grupos" >> $ou
		date >> /tmp/objetos/crearObjetos.ldif
		date >> $errores
		ldapadd -x -D "$adminLDAP" -w "$contrasenia" -f $ou >> $objetos 2> $errores
	fi

	read -p "Nombre: " cn

	#Recuperar GID del último grupo.
	consultaGid=`ldapsearch -xLLL -b $dominio objectClass=posixGroup | grep "gidNumber" | tail -n 1`
	intGid=${consultaGid/gidNumber: /}
	if [ -z "$intGid" ]; then
		intGid=90000
	else
		intGid=$(($intGid+1))
	fi
	echo "dn: cn=$cn,ou=grupos,$dominio" > $gid
	echo "objectClass: posixGroup" >> $gid
	echo "cn: $cn" >> $gid
	echo "gidNumber: $intGid" >> $gid
	date >> $objetos
	date >> $errores
	ldapadd -x -D "$adminLDAP" -w "$contrasenia" -f $gid >> $objetos 2> $errores
	codError=$?
	if [ "$codError" = "0" ]; then
		echo "Grupo creado."

		#Preguntar si se quiere ver la información del grupo.
		read -p "¿Quieres ver la información del grupo $cn? (s/n) " mostrar
		if [ "$mostrar" = "s" ]; then
			ldapsearch -xLLL -b $dominio cn=$cn
		else
			salir $codError
		fi
	else
		controlErrores $codError
		salir $codError
	fi
}

#Eliminar
#Eliminar unidad organizativa
function eliminarUO {
	while
		read -p "Nombre de la unidad organizativa que quieres eliminar: " nombre
		dnObjeto=$(ldapsearch -xLLL -b $dominio ou=$nombre dn)
		rutaObjeto=${dnObjeto/dn: /}
		[ -z "$nombre" ] || [ -z "$rutaObjeto" ]
	do
		echo "El término que has introducido no corresponde a ninguna unidad organizativa de este dominio. Inténtalo de nuevo."
	done
	echo "Se han encontrado objetos hijos de la unidad organizativa $nombre. Son los siguientes:"
	read -p "¿Quieres eliminar a los hijos de la unidad organizativa $nombre? (s/n) " eliminarHijos
	if [ "$eliminarHijos" = "s" ]; then
		ldapdelete -x -r -w "$contrasenia" -D "$adminLDAP" "$rutaObjeto" 2> $errores
	else
		echo "La unidad organizativa $nombre tiene hijos. Si quieres eliminarla deberás eliminar primero los hijos o moverlos a otra unidad organizativa."
	fi
}

#Eliminar usuario
function eliminarUsuario {
	while
		read -p "Nombre del usuario que quieres eliminar: " nombre
		dnObjeto=$(ldapsearch -xLLL -b $dominio uid=$nombre dn)
		rutaObjeto=${dnObjeto/dn: /}
		[ -z "$rutaObjeto" ]
	do
		echo "El término que has introducido no corresponde a ningún usuario de este dominio. Inténtalo de nuevo."
	done
	read -p "Confirma que deseas eliminar el usuario $nombre. (s/n) " eliminar
	if [ "$eliminar" = "s" ]; then
		ldapdelete -x -w "$contrasenia" -D "$adminLDAP" "$rutaObjeto" 2> $errores
		if [ "$?" = "0" ]; then
			echo "El usuario $nombre se ha eliminado."
			salir 0
		else
			echo "Error"
			salir 1
		fi
	else
		salir 0
	fi
}

#Eliminar grupo
function eliminarGrupo {
	while
		read -p "Nombre del grupo que deseas eliminar: " nombre
		dnObjeto=$(ldapsearch -xLLL -b $dominio cn=$nombre dn)
		rutaObjeto=${dnObjeto/dn: /}
		[ -z "$rutaObjeto" ]
	do
		echo "El término que has introducido no corresponde a ningún grupo del dominio. Inténtalo de nuevo."
	done
	busquedaGidGrupo=`ldapsearch -xLLL -b $dominio "(&(cn=$nombre)(objectClass=posixGroup))" | grep "gidNumber"`
	busquedaGidGrupo=${busquedaGidGrupo/gidNumber: /}
	busquedaUsuarios=`ldapsearch -xLLL -b $dominio "(&(gidNumber=$busquedaGidGrupo)(objectClass=posixAccount))"`
	if [ -z "$busquedaUsuarios" ]; then
		echo "Este grupo no tiene ningún objeto hijo."
	else
		echo "El grupo que has especificado tiene hijos. Son los siguientes:"
		IFS=$'\n'
		for objeto in $busquedaUsuarios
		do
			if [[ "$objeto" =~ ^dn ]]; then
				echo -e "${azuli}--- --- --- --- ---${fincolor}"
			fi
			echo $objeto
		done
		read -p "¿Quieres eliminar a los usuarios pertenecientes al grupo, y el propio grupo? (s/n) " eliminarHijos
		if [ "$eliminarHijos" = "s" ]; then
			ldapdelete -x -r -w "$contrasenia" -D "$adminLDAP" "$rutaObjeto" 2> $errores
			if [ "$?" = "0" ]; then
				echo "El grupo $nombre se ha eliminado."
				salir 0
		else
			echo "El grupo $nombre tiene hijos. Si quieres eliminarlo deberás eliminar primero los hijos o moverlos a otro grupo."
			salir $codError
		fi
	fi
fi
}

#Modificar
#Modificar unidad organizativa
function modificarUO {
	while
		read -p "Nombre de la unidad organizativa que quieres modificar: " nombre
		rutaObjeto=$(ldapsearch -xLLL -b $dominio ou=$nombre dn)
		rutaObjeto=${dnObjeto/dn: /}
		[ -z "$rutaObjeto" ]
	do
		echo "El término que has introducido no corresponde a ninguna unidad organizativa del dominio. Inténtalo de nuevo"
	done
	read -p "Nuevo nombre de la unidad organizativa: " nuevoNombre
	echo "$rutaObjeto" > $ou
	echo "changetype: modrdn" >> $ou
	echo "newrdn: ou=$nuevoNombre" >> $ou
	echo "deleteoldrdn: 1" >> $ou
	ldapmodify -x -D "$adminLDAP" -w "$contrasenia" -f $ou >> $objetos 2> $errores
	if [ "$?" = "0" ]; then
		echo "Unidad organizativa modificada."
		#Preguntar si se quiere ver la información de la unidad organizativa.
		read -p "¿Quieres ver la información de la unidad organizativa $nuevoNombre? (s/n) " mostrar
		if [ "$mostrar" = "s" ]; then
			ldapsearch -xLLL -b $dominio ou=$nuevoNombre
			salir 0
		else
			salir 0
		fi
	else
		echo "Error"
		salir 1
	fi
}

#Modificar usuario
function modificarUsuario {
	while
		read -p "Nombre del usuario que deseas modificar: " nombre
		rutaObjeto=$(ldapsearch -xLLL -b $dominio uid=$nombre dn)
		[ -z "$rutaObjeto" ]
	do
		echo "El término que has introducido no corresponde a ningún usuario del dominio. Inténtalo de nuevo."
	done
	echo -e "${azuli}--- --- --- --- ---${fincolor}"
	echo "Puedes modificar los siguientes atributos:"
	echo "1. Nombre de usuario."
	echo "2. Nombre y apellidos."
	echo "3. Contraseña."
	echo "4. Grupo al que pertenece."
	echo "5. Correo electrónico."
	echo "6. Directorio personal del usuario."
	read -p "¿Qué atributo quieres modificar? " atributo
	case $atributo in
	1)
		echo "Modificar el nombre de usuario."
		read -p "Nuevo nombre de usuario: " nuevoUid
		echo "dn: uid=$nombre,ou=usuarios,$dominio" > $uid
		echo "changetype: modify" >> $uid
		echo "replace: uid" >> $uid
		echo "uid: $nuevoUid" >> $uid
		if [ "$?" = "0" ]; then
			echo "Usuario modificado."
			#Preguntar si se quiere ver la información del usuario.
			read -p "¿Quieres ver la información del usuario $nuevoUid? (s/n) " mostrar
			if [ "$mostrar" = "s" ]; then
				ldapsearch -xLLL -b $dominio uid=$nuevoUid
				salir 0
			else
				salir 0
			fi
		else
			echo "Error"
			salir 1
		fi;;
	2)
		echo "Modificar el nombre (completo)."
		read -p "Nombre y apellidos nuevos: " nuevoGivenName
		echo "dn: uid=$nombre,ou=usuarios,$dominio" > $uid
		echo "changetype: modify" >> $uid
		echo "replace: givenName" >> $uid
		echo "givenName: $nuevoGivenName" >> $uid
		nuevoDisplayName="$nuevoGivenName"
		echo "replace: displayName" >> $uid
		echo "displayName: $displayName" >> $uid
		ldapmodify -x -D "$adminLDAP" -w "$contrasenia" -f $uid >> $objetos 2> $errores
		if [ "$?" = "0" ]; then
			echo "Usuario modificado."
			#Preguntar si se quiere ver la información del usuario.
			read -p "¿Quieres ver la información del usuario $nombre? (s/n) " mostrar
			if [ "$mostrar" = "s" ]; then
				ldapsearch -xLLL -b $dominio uid=$nombre
				salir 0
			else
				salir 0
			fi
		else
			echo "Error"
			salir 1
		fi;;
	3)
		echo "Modificar la contraseña."
		while
			read -s -p "Nueva contraseña: " nuevaContrasenia
			read -s -p "Confirmar nueva contraseña: " nuevaContrasenia2
			[ "$nuevaContrasenia" != "$nuevaContrasenia2" ]
		do
			echo "Las contraseñas no coinciden. Inténtalo de nuevo."
		done
		echo "dn: uid=$nombre,ou=usuarios,$dominio" > $uid
		echo "changetype: modify" >> $uid
		echo "replace: userPassword" >> $uid
		echo "userPassword: $nuevaContrasenia" >> $uid
		ldapmodify -x -D "$adminLDAP" -w "$contrasenia" -f $uid >> $objetos 2> $errores
		if [ "$?" = "0" ]; then
			echo "Usuario modificado."
			#Preguntar si se quiere ver la información del usuario.
			read -p "¿Quieres ver la información del usuario $nombre? (s/n) " mostrar
			if [ "$mostrar" = "s" ]; then
				ldapsearch -xLLL -b $dominio uid=$nombre
				salir 0
			else
				salir 0
			fi
		else
			echo "Error"
			salir 1
		fi;;
	4)
		echo "Cambiar el grupo al que pertenece el usuario."
		read -p "Nuevo grupo: " nuevoGrupo
		busquedaGidGrupo=`ldapsearch -xLLL -b $dominio "(&(cn=$nuevoGrupo)(objectClass=posixGroup))" | grep gidNumber`
		intGid=${busquedaGidGrupo/gidNumber: /}
		echo "dn: uid=$nombre,ou=usuarios,$dominio" > $uid
		echo "changetype: modify" >> $uid
		echo "replace: gidNumber" >> $uid
		echo "gidNumber: $intGid" >> $uid
		ldapmodify -x -D "$adminLDAP" -w "$contrasenia" -f $uid >> $objetos 2> $errores
		if [ "$?" = "0" ]; then
			echo "Usuario modificado."
			#Preguntar si se quiere ver la información del usuario.
			read -p "¿Quieres ver la información del usuario $nombre? (s/n) " mostrar
			if [ "$mostrar" = "s" ]; then
				ldapsearch -xLLL -b $dominio uid=$nombre
				salir 0
			else
				salir 0
			fi
		else
			echo "Error"
			salir 1
		fi;;
	5)
		echo "Modificar el correo electrónico."
		read -p "Nuevo correo electrónico: " nuevoCorreo
		echo "dn: uid=$nombre,ou=usuarios,$dominio" > $uid
		echo "changetype: modify" >> $uid
		echo "replace: mail" >> $uid
		echo "mail: $nuevoCorreo" >> $uid
		ldapmodify -x -D "$adminLDAP" -w "$contrasenia" -f $uid >> $objetos 2> $errores
		if [ "$?" = "0" ]; then
			echo "Usuario modificado."
			#Preguntar si se quiere ver la información del usuario.
			read -p "¿Quieres ver la información del usuario $nombre? (s/n) " mostrar
			if [ "$mostrar" = "s" ]; then
				ldapsearch -xLLL -b $dominio uid=$nombre
				salir 0
			else
				salir 0
			fi
		else
			echo "Error"
			salir 1
		fi;;
	6)
		echo "Modificar el directorio personal del usuario."
		read -p "Nuevo directorio personal: " nuevoDirectorio
		echo "dn: uid=$nombre,ou=usuarios,$dominio" > $uid
		echo "changetype: modify" >> $uid
		echo "replace: homeDirectory" >> $uid
		echo "homeDirectory: $nuevoDirectorio" >> $uid
		ldapmodify -x -D "$adminLDAP" -w "$contrasenia" -f $uid >> $objetos 2> $errores
		if [ "$?" = "0" ]; then
			echo "Usuario modificado."
			#Preguntar si se quiere ver la información del usuario.
			read -p "¿Quieres ver la información del usuario $nombre? (s/n) " mostrar
			if [ "$mostrar" = "s" ]; then
				ldapsearch -xLLL -b $dominio uid=$nombre
				salir 0
			else
				salir 0
			fi
		else
			echo "Error"
			salir 1
		fi;;
	*)
		echo "No has seleccionado una opción válida."
		salir 1;;
	esac
}

#Modificar grupo
function modificarGrupo {
	while
		read -p "Nombre del grupo que deseas modificar: " nombre
		rutaObjeto=$(ldapsearch -xLLL -b $dominio cn=$nombre dn)
		[ -z "$rutaObjeto" ]
	do
		echo "El término que has introducido no corresponde a ningún grupo del dominio. Inténtalo de nuevo."
	done
	read -p "Nuevo nombre del grupo: " nuevoNombre
	echo "$rutaObjeto" > $gid
	echo "changetype: modrdn" >> $gid
	echo "newrdn: cn=$nuevoNombre" >> $gid
	echo "deleteoldrdn: 1" >> $gid
	ldapmodify -x -D "$adminLDAP" -w "$contrasenia" -f $gid >> $objetos 2> $errores
	if [ "$?" = "0" ]; then
		echo "Grupo modificado."
		#Preguntar si se quiere ver la información del grupo.
		read -p "¿Quieres ver la información del grupo $nuevoNombre? (s/n) " mostrar
		if [ "$mostrar" = "s" ]; then
			ldapsearch -xLLL -b $dominio cn=$nuevoNombre
			salir 0
		else
			salir 0
		fi
	else
		echo "Error"
		salir 1
	fi
}

#Case para el menú de opciones
case $opcion in
11)
	echo "Crear unidad organizativa."
	crearUO;;
12)
	echo "Crear usuario."
	crearUsuario;;
13)
	echo "Crear grupo."
	crearGrupo;;
21)
	echo "Eliminar unidad organizativa."
	eliminarUO;;
22)
	echo "Eliminar usuario."
	eliminarUsuario;;
23)
	echo "Eliminar grupo."
	eliminarGrupo;;
31)
	echo "Modificar unidad organizativa."
	modificarUO;;
32)
	echo "Modificar usuario."
	modificarUsuario;;
33)
	echo "Modificar grupo."
	modificarGrupo;;
4)
	salir 0;;
*)
	echo "No has seleccionado una opción válida."
	salir 1;;
esac