# Desinstalación de printm: Printing Manager
# Importación de módulos
import os, shutil, sys, subprocess

#Detección del sistema
sistema = sys.platform

# Elección
print("Desinstalador de printm")
opcion = input("¿Quieres desinstalar printm? (s/N)")

# Si no se introduce ninguna letra O se introduce la N, la desinstalación se cancela
if not opcion or opcion == "n" or opcion == "N":
    print("No se ha desinstalado el programa.")
    exit(0)
# Si se introduce la letra  S, se comienza el proceso de desinstalación
elif opcion == "s" or opcion == "S":
    # Elección sobre desinstalar o no los módulos descargados durante la instalación
    eliminarModulos = input("¿Quieres desinstalar los módulos? (s/N)")
    
    # Lista de módulos que se van a desinstalar (varía según el sistema)
    print("Son los siguientes:")
    if sistema == "win32":
        print("1. win32printing\n2. pywin32\n3.requests")
    elif sistema == "linux":
        print("1. cups\n2. requests")
    
    # Eliminar módulos si se introduce S
    if eliminarModulos == "s" or eliminarModulos == "S":
        if sistema == "win32":
            subprocess.run("pip uninstall -y win32printing pywin32 requests",shell=True)
        elif sistema == "linux":
            subprocess.run("pip uninstall -y cups requests")

    # Eliminar directorio de instalación y el desinstalador
    print("Desinstalando printm.")
    try:
        # Elimina la carpeta de la aplicación
        shutil.rmtree(os.path.dirname(os.path.realpath(__file__)))
        # Elimina el propio desinstaldor
        os.remove(sys.argv[0])

    # Si no es posible eliminar el directorio o el desinstalador, se muestra el error por pantalla
    except Exception as error:
        print(f"Error: {error}")