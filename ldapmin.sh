#Script desarrollado para facilitar la administración de objetos de OpenLDAP.

#Comprobar que los paquetes slapd y ldaputils están instalados,
#si no, mostrar un mensaje
comprobarSlapd=`dpkg -l | grep "slapd"`
comprobarLdaputils=`dpkg -l | grep "ldap-utils"`
if [ -z "$comprobarSlapd" ] && [ -z "$comprobarLdaputils" ]; then
	echo "Es posible que uno de los paquetes no esté instalado. Instálalo y vuelve a ejecutar el script."
	exit 1
fi

#Comprobar que el usuario que está ejecutando el script sea root,
#si no lo fuera, finalizar el programa.
if [ "$EUID" != "0" ]; then
	echo "El script debe ser ejecutado por el usuario root."
	exit 1
fi

if [ "$SHELL" != "/bin/bash" ]; then
	echo "El script debe de ejecutarse mediante el intérprete de comandos BASH. Ahora estás usando el intérprete $SHELL."
fi

#Tareas previas: creación de directorios y archivos temporales (en /tmp).
#Estos directorios y archivos se eliminan con cada inicio del sistema.
mkdir -p /tmp/logs
mkdir -p /tmp/objetos
touch /tmp/logs/crearObjeto.log
touch /tmp/logs/eliminarObjeto.log
touch /tmp/logs/modificarObjeto.log
clear

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

#Menú de opciones
echo -e "${namarillo}Bienvenido al programa de gestión de objetos de OpenLDAP.${fincolor}"
echo -e "${nciani}-----${fincolor} "
read -s -p "Contraseña del administrador de LDAP: " contrasenia #Preguntar por la contraseña del administrador de OpenLDAP.
clear
echo -e "${namarillo}Bienvenido al programa de gestión de objetos de OpenLDAP.${fincolor}"
echo -e "${ciani}-----${fincolor}"
echo -e "${azuli}Opciones${fincolor}"
echo -e "${verdei}1: Crear un objeto.${fincolor}"
echo -e "${rojoi}2: Eliminar un objeto.${fincolor}"
echo -e "${azuli}3: Modificar un objeto.${fincolor}"
echo -e "${fnrojoi}4: Salir.${fincolor}"
read -p "Introduce un número: " opcion

#Funciones
#Función para la opción número uno: crear objetos.
function crear {

	#Selección del tipo de objeto que se creará
	echo -e "${rojoi}-----${fincolor}"
	echo -e "${amarilloi}1: Unidad organizativa${fincolor}"
	echo -e "${amarilloi}2: Usuario${fincolor}"
	echo -e "${amarilloi}3: Grupo${fincolor}"
	read -p "¿Qué objeto quieres crear? " objetoSeleccionado

	#Crear unidad organizativa
	function crearUO {
		read -p "Nombre: " nombre
		echo "dn: ou=$nombre,$dominio" > /tmp/objetos/ou.ldif
		echo "objectClass: top" >> /tmp/objetos/ou.ldif
		echo "objectClass: organizationalUnit" >> /tmp/objetos/ou.ldif
		echo "ou: $nombre" >> /tmp/objetos/ou.ldif
		date >> /tmp/logs/crearObjetos.log
		ldapadd -x -D $adminLDAP -w $contrasenia -f /tmp/objetos/ou.ldif >> /tmp/logs/crearObject.log 2> /dev/null
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
		read -p "Nombre de usuario: " uid
		read -p "Nombre: " nombrePila
		read -p "Apellido/s: " apellidos
		read -p "Grupo al que pertenece el usuario: " nombreGrupo
		grupo=`ldapsearch -xLLL -b $dominio "(&(cn=$nombreGrupo)(objectClass=posixGroup))"`
		rutaObjeto=${grupo/dn: /}
		#Si el grupo en el que se desea que esté el usuario no existiera o no se encontrara,
		#se creará un nuevo grupo con el nombre que se especificó anteriormente.
		if [ -z "$grupo" ]
		then
			#Crear nuevo grupo.
			echo "Grupo no encontrado. Creando nuevo grupo con el nombre $nombreGrupo."
			echo "dn: cn=$nombreGrupo,$dominio" > /tmp/objetos/gid.ldif
			echo "objectClass: posixGroup" >> /tmp/objetos/gid.ldif
			echo "cn: $nombreGrupo" >> /tmp/objetos/gid.ldif
			ultimoGid=`ldapsearch -xLLL -b $dominio "objectClass=posixGroup" | grep "gidNumber" | tail -n 1`
			intGid=${ultimoGid/gidNumber: /}
			intGid=$((intGid+1))
			echo "gidNumber: $intGid" >> /tmp/objetos/gid.ldif
			date >> /tmp/logs/crearObjetos.log
			ldapadd -x -D $adminLDAP -w $contrasenia -f /tmp/objetos/gid.ldif >> /tmp/logs/crearObjetos.log 2> /dev/null
		else
			#Añadir usuario al grupo ya existente.
			echo "El grupo $nombreGrupo se ha encontrado. El usuario $uid pertenecerá a dicho grupo."
			consultaGid=`ldapsearch -xLLL -b $dominio "(&(cn=$nombreGrupo)(objectClass=posixGroup))" | grep "gidNumber"`
			intGid=${consultaGid/gidNumber: /}
		fi
		#Recuperar UID con el valor más alto.
		consultaUid=`ldapsearch -xLLL -b $dominio "objectClass=inetOrgPerson" | grep "uidNumber" | tail -n 1`
		intUid=${consultaUid/uidNumber: /}
		intUid=$((intUid+1))
		#Inserción de atributos del objeto al archivo que será ejecutado posteriormente.
		echo "dn: uid=$uid,$dominio" > /tmp/objetos/uid.ldif
		echo "objectClass: inetOrgPerson" >> /tmp/objetos/uid.ldif
		echo "objectClass: posixAccount" >> /tmp/objetos/uid.ldif
		echo "objectClass: shadowAccount" >> /tmp/objetos/uid.ldif
		echo "uid: $uid" >> /tmp/objetos/uid.ldif
		echo "givenName: $nombrePila" >> /tmp/objetos/uid.ldif
		echo "sn: $apellidos" >> /tmp/objetos/uid.ldif
		echo "cn: $nombrePila $apellidos" >> /tmp/objetos/uid.ldif
		echo "displayName: $nombrePila $apellidos" >> /tmp/objetos/uid.ldif
		echo "uidNumber: $intUid" >> /tmp/objetos/uid.ldif
		echo "gidNumber: $intGid" >> /tmp/objetos/uid.ldif
		#Bucle que preguntará por las contraseñas hasta que sean iguales.
		while
			read -s -p "Contraseña: " contraseniaUsuario
			echo ""
			read -s -p "Confirmar contraseña: " contraseniaUsuario2
			echo ""
			[ "$contraseniaUsuario" != "$contraseniaUsuario2" ]
			do
				echo "Las contraseñas no coinciden, inténtalo de nuevo."
			done
		#Continuar con la inserción de los datos al archivo LDIF.
		echo "userPassword: $contraseniaUsuario" >> /tmp/objetos/uid.ldif
		echo "loginShell: /bin/bash" >> /tmp/objetos/uid.ldif
		echo "homeDirectory: /home/$uid" >> /tmp/objetos/uid.ldif
		echo "mail: $uid@$dominioDns" >> /tmp/objetos/uid.ldif
		date >> /tmp/logs/crearObjetos.log
		#Ejecución del archivo LDIF.
		ldapadd -x -D $adminLDAP -w $contrasenia -f /tmp/objetos/uid.ldif >> /tmp/logs/crearObjetos.log 2> /dev/null
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
	function crearGrupo {
		read -p "Nombre: " cn
		while
			read -p "Unidad organizativa a la que pertenece el grupo: " ou
			consultaOU=`ldapsearch -xLLL -b $dominio ou=$ou`
			[ -z "$ou" ] || [ -z "$consultaOU" ]
		do
			echo "La unidad organizativa que has especificado no existe."
			read -p "¿Quieres crear una unidad organizativa con nombre $ou? (s/n) " crear
			if [ "$crear" = "s" ]; then
				echo "dn: ou=$nombre,$dominio" > /tmp/objetos/ou.ldif
				echo "objectClass: top" >> /tmp/objetos/ou.ldif
				echo "objectClass: organizationalUnit" >> /tmp/objetos/ou.ldif
				echo "ou: $nombre" >> /tmp/objetos/ou.ldif
			fi
		done
		#Recuperar GID del último grupo.
		ultimoGid=`ldapsearch -xLLL -b $dominio objectClass=posixGroup | grep "gidNumber" | tail -n 1`
		intUltimoGid=${ultimoGid/gidNumber: /}
		echo "dn: cn=$cn,ou=$ou,$dominio" > /tmp/objetos/gid.ldif
		echo "objectClass: posixGroup" >> /tmp/objetos/gid.ldif
		echo "cn: $cn" >> /tmp/objetos/gid.ldif
		echo "gidNumber: $intUltimoGid" >> /tmp/objetos/gid.ldif
		date >> /tmp/logs/crearObjetos.log
		ldapadd -x -D $adminLDAP -w $contrasenia -f /tmp/objetos/gid.ldif >> /tmp/logs/crearObjetos.log 2> /dev/null
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
	case $objetoSeleccionado in
	1)
		echo "Crear una unidad organizativa."
		crearUO;;
	2)
		echo "Crear un usuario."
		crearUsuario;;
	3)
		echo "Crear un grupo."
		crearGrupo;;
	esac
}

#Función para la opción número dos: eliminar objetos.
function eliminar {
	echo -e "${rojoi}-----${fincolor}"
	echo -e "${amarilloi}1: Unidad organizativa${fincolor}"
	echo -e "${amarilloi}2: Usuario${fincolor}"
	echo -e "${amarilloi}3: Grupo${fincolor}"
	read -p "¿Qué objeto quieres eliminar? " objetoSeleccionado
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
			ldapdelete -x -r -w $contrasenia -D "$adminLDAP" "$rutaObjeto" 2> /dev/null
		else
			echo "La unidad organizativa $nombre tiene hijos. Si quieres eliminarla deberás eliminar primero los hijos o moverlos a otra unidad organizativa."
		fi
	}
	function eliminarUsuario {
		while
			read -p "Nombre del usuario que quieres eliminar: " nombre
			dnObjeto=$(ldapsearch -xLLL -b $dominio uid=$nombre dn)
			rutaObjeto=${dnObjeto/dn: /}
			[ -z "$nombre" ] || [ -z "$rutaObjeto" ]
		do
			echo "El término que has introducido no corresponde a ningún usuario de este dominio. Inténtalo de nuevo."
		done
		ldapdelete -x -w $contrasenia -D "$adminLDAP" "$rutaObjeto" 2> /dev/null
	}
	function eliminarGrupo {
		while
			read -p "Nombre del grupo que deseas eliminar: " nombre
			dnObjeto=$(ldapsearch -xLLL -b $dominio cn=$nombre dn)
			rutaObjeto=${dnObjeto/dn: /}
			[ -z "$nombre" ] || [ -z "$rutaObjeto" ]
		do
			echo "El término que has introducido no corresponde a ningún grupo del dominio. Inténtalo de nuevo."
		done
		busquedaGidGrupo=`ldapsearch -xLLL -b $dominio (&(cn=$nombre)(objectClass=posixGroup)) gidNumber | grep "gidNumber"`
		busquedaGidGrupo=${busqueda/gidNumber: /}
		busquedaUsuarios=`ldapsearch -xLLL -b $dominio (&(gidNumber=$busquedaGidGrupo)(objectClass=posixAccount))`
		if [ -z "$busquedaUsuarios" ]; then
			echo "Este grupo no tiene ningún objeto hijo."
		else
			echo "El grupo que has especificado tiene hijos. Son los siguientes:"
			for objeto in $busquedaUsuarios; do
				echo "$objeto"
				echo " ----- "
			done;
			read -p "¿Quieres eliminar a los usuarios pertenecientes al grupo? (s/n) " eliminarHijos
			if [ "$eliminarHijos" = "s" ]; then
				ldapdelete -x -r -w $contrasenia -D "$adminLDAP" "$rutaObjeto" 2> /dev/null
			else
				echo "El grupo $nombre tiene hijos. Si quieres eliminarlo deberás eliminar primero los hijos o moverlos a otro grupo."
				salir $codError
			fi
		fi
	}
	case $objetoSeleccionado in
	1)
		echo "Eliminar una unidad organizativa"
		eliminarUO;;
	2)
		echo "Eliminar un usuario"
		eliminarUsuario;;
	3)
		echo "Eliminar un grupo"
		eliminarGrupo;;
	*)
		echo "No has seleccionado una opción válida"
		salir 1;;
	esac
}
#Función para la opción número tres: modificar objetos.
function modificar {
	echo -e "${rojo}-----${fincolor}"
	echo -e "${amarilloi}1: Unidad organizativa${fincolor}"
	echo -e "${amarilloi}2: Usuario${fincolor}"
	echo -e "${amarilloi}3: Grupo${fincolor}"
	read -p "¿Qué objeto quieres modificar? " objetoSeleccionado
	function modificarUO {
		while
			read -p "Nombre de la unidad organizativa que quieres modificar: " nombre
			rutaObjeto=$(ldapsearch -xLLL -b $dominio ou=$nombre dn)
			[ -z "$nombre" ] || [ -z "$rutaObjeto" ]
		do
			echo "El término que has introducido no corresponde a ninguna unidad organizativa del dominio. Inténtalo de nuevo"
		done
		read -p "Nuevo nombre de la unidad organizativa: " nuevoNombre
		echo "$rutaObjeto" > /tmp/objetos/modificar.ldif
		echo "changetype: modrdn" >> /tmp/objetos/modificar.ldif
		echo "newrdn: ou=$nuevoNombre" >> /tmp/objetos/modificar.ldif
		echo "deleteoldrdn: 1" >> /tmp/objetos/modificar.ldif
	}
	function modificarUsuario {
		while
			read -p "Nombre del usuario que deseas modificar: " nombre
			rutaObjeto=$(ldapsearch -xLLL -b $dominio uid=$nombre dn)
			[ -z "$nombre" ] || [ -z "$rutaObjeto" ]
		do
			echo "El término que has introducido no corresponde a ningún usuario del dominio. Inténtalo de nuevo."
		done
		busquedaUsuario=`ldapsearch -xLLL -b $dominio objectClass=inetOrgPerson`
		echo "Puedes modificar los siguientes atributos:"
		echo "1. Nombre de usuario."
		echo "2. Nombre."
		echo "3. Apellidos."
		echo "4. Contraseña."
		echo "5. Grupo al que pertenece."
		read -p "¿Qué atributo quieres modificar?" atributo
		case $atributo in
		1)
			echo "Has elegido modificar el nombre de usuario.";;
		2)
			echo "Has elegido modificar el nombre.";;
		3)
			echo "Has elegido modificar los apellidos.";;
		4)
			echo "Has elegido modificar la contraseña.";;
		5)
			echo "Has elegido cambiar el grupo al que pertenece el usuario.";;
		*)
			echo "No has seleccionado una opción válida.";;
		esac
	}
#	function modificarGrupo {

#	}
	case $objetoSeleccionado in
	1)
		echo "Modificar una unidad organizativa"
		modificarUO;;
	2)
		echo "Modificar un usuario"
		modificarUsuario;;
	3)
		echo "Modificar un grupo"
		modificarGrupo;;
	*)
		echo "No has seleccionado una opción válida"
		salir;;
	esac
}

#Condicionales
case $opcion in
1)
	echo "Has elegido crear un objeto"
	crear;;
2)
	echo "Has elegido eliminar un objeto."
	eliminar;;
3)
	echo "Has elegido modificar un objeto."
	modificar;;
4)
	salir 0;;
*)
	echo "No has seleccionado una opción válida."
	salir 1;;
esac
