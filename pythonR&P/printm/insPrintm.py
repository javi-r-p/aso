# Instalación de printm: Printing Manager
# Importación de módulos y mensaje de bienvenida
print("Instalación de printm")
import sys, subprocess
from pathlib import Path

# Detección del sistema operativo, instalación de módulos y definición y creación de la ruta de instalación
sistema = sys.platform
# Instalación de unos módulos u otros en función del sistema
if sistema == "win32":
    bin = "C:/Program Files"
    subprocess.run("pip install requests win32api tk", shell=True)
elif sistema == "linux":
    bin = "/usr/lib"
    subprocess.run("apt install python3-requests python3-cups python3-tk -y", shell=True)

# Establecer la ruta por defecto
instalacion = Path(bin,"printm/")
print("El programa se va a instalar en la siguente ruta: " + str(instalacion))
# Elegir una ruta diferente a la predeterminada (opcional)
cambiarRuta = input("¿Quieres modificarla? (s/N) ")
if cambiarRuta == "s" or cambiarRuta == "S":
    instalacion = input("Introduce la nueva ruta, debe ser absoluta: ")
    instalacion = Path(instalacion)
# Crea el directorio de la instalación
instalacion.mkdir(exist_ok=True)

# Importar el módulo para descargar los archivos
import requests

# Descargar archivos
print("Instalando dependencias...")
# Archivo general
archivoGeneral = requests.get("https://github.com/javi-r-p/aso/releases/download/alpha/printm.py")
rutaArchivoGeneral = Path(instalacion,"printm.py")
rutaArchivoGeneral.write_bytes(archivoGeneral.content)
# Archivo específico (según sistema operativo)
archivoEspecifico = requests.get("https://github.com/javi-r-p/aso/releases/download/alpha/printm" + sistema + ".py")
rutaArchivoEspecifico = Path(instalacion,"printmFunctions.py")
rutaArchivoEspecifico.write_bytes(archivoEspecifico.content)
# Archivo del desinstalador
archivoDesinstalador = requests.get("https://github.com/javi-r-p/aso/releases/download/alpha/unsPrintm.py")
rutaDesinstalador = Path(instalacion,"uninstall.py")
rutaDesinstalador.write_bytes(archivoDesinstalador.content)

# Fin de la instalación
print("Instalación finalizada.")
exit(0)