# Instalación de printm: Printing Manager
# Importación de módulos y mensaje de bienvenida
print("Instalación de printm")
import sys, subprocess
from pathlib import Path

# Detección del sistema operativo, instalación de módulos y definición y creación de la ruta de instalación
sistema = sys.platform
# Instalación de unos módulos u otros en función del sistema
if sistema == "win32":
    #bin = "C:/Program Files"
    bin = "C:/Users/javie"
    subprocess.run("pip install win32printing requests pywin32", shell=True)
    print("Tu sistema operativo es Windows.")
elif sistema == "linux":
    bin = "/usr/lib"
    subprocess.run("apt install python3-requests python3-cups -y", shell=True)
    print("Tu sistema operativo es Linux.")

# Se establece la ruta por defecto
instalacion = Path(bin,"printm/")
print("El programa se va a instalar en la siguente ruta: " + str(instalacion))
# Se puede elegir una ruta diferente a la predeterminada
cambiarRuta = input("¿Quieres modificarla? (s/N) ")
# Si se introduce S se pregunta por la nueva ruta
if cambiarRuta == "s" or cambiarRuta == "S":
    instalacion = input("Introduce la nueva ruta, debe ser absoluta: ")
    instalacion = Path(instalacion)
# Crea el directorio de la instalación
instalacion.mkdir(exist_ok=True)

# Preguntar por el idioma
'''
print("Selecciona un idioma para la instalación:")
print("1. Inglés")
print("2. Español")
idioma = int(input("Introduce un idioma: "))


# Preguntar si se desea que la aplicación sea gráfica o por terminal
print("\nPuedes elegir si la aplicación cuenta con interfaz gráfica o no:")
print("1. CON interfaz gráfica.")
print("2. SIN interfaz gráfica.")
opcion = int(input("Elige una opción: "))
'''
import requests
'''
if opcion == 1:
    print("Has elegido la versión con interfaz gráfica")
    archivoGeneral = requests.get("https://github.com/javi-r-p/aso/releases/download/alpha/printmGraph.py")
    rutaArchivoGeneral = Path(instalacion,"printm.py")
elif opcion == 2:
    print("Has elegido la versión por terminal")
'''
archivoGeneral = requests.get("https://github.com/javi-r-p/aso/releases/download/alpha/printmTerminal.py")
rutaArchivoGeneral = Path(instalacion,"printm.py")

# Descarga de archivos
print("Instalando dependencias...")
# Archivo general
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