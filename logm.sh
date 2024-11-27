#!/bin/bash
echo "Monitor del sistema"
mkdir -p /var/logm/
find /var/log/logm.log > /dev/null 2> /dev/null
if [ "$?" = "1" ]; then
	touch /var/logm/logm.log
fi

