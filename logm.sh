#!/bin/bash
echo "Monitor del sistema"

if [ "$EUID" != 0 ]; then
	echo "El script debe ser ejecutado como root."
	exit 1
fi

find /var/log/logm.log > /dev/null 2> /dev/null
if [ "$?" = "1" ]; then
	touch /var/log/logm.log
fi
