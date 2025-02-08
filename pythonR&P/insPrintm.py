# Instalación de printm: Printing Manager
# Importación de módulos y mensaje de bienvenida
print("Instalación de printm")
import sys, subprocess, requests, os
from pathlib import Path

# Detección del sistema operativo, instalación de módulos y definición y creación de la ruta de instalación
sistema = sys.platform
if sistema == "win32":
    #bin = "C:/Program Files"
    bin = "C:/Users/javie"
    #subprocess.run("pip install win32printing requests", shell=True)
elif sistema == "linux":
    bin = "/usr/lib"
    subprocess.run("apt install python3-requests python3-cups -y", shell=True)

instalacion = Path(bin,"printm/")
print(instalacion)
instalacion.mkdir(exist_ok=True)

# Preguntar si se desea que la aplicación sea gráfica o por terminal
print("Puedes elegir si la aplicación cuenta con interfaz gráfica o no:")
print("1. CON interfaz gráfica")
print("2. SIN interfaz gráfica")
opcion = int(input("Elige una opción: "))
if opcion == 1:
    print("Has elegido la versión con interfaz gráfica")
elif opcion == 2:
    print("Has elegido la versión por terminal")
# Descarga de archivos
print("Instalando dependencias")
archivoGeneral = requests.get("https://github.com/javi-r-p/aso/releases/download/alpha/printm.py")
rutaArchivoGeneral = Path(instalacion,"printm.py")
rutaArchivoGeneral.write_bytes(archivoGeneral.content)
archivoEspecifico = requests.get("https://github.com/javi-r-p/aso/releases/download/alpha/printm" + sistema + ".py")
rutaArchivoEspecifico = Path(instalacion,"printmFunctions.py")
rutaArchivoEspecifico.write_bytes(archivoEspecifico.content)