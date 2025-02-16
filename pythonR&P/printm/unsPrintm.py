# Desinstalación de printm: Printing Manager
'''
from pathlib import Path
print("Desinstalador de printm")
print("NOTA: los módulos de Python instalados no se eliminarán.")
opcion = input("¿Quieres desinstalar printm? (s/N)")
if not opcion or opcion == "n" or opcion == "N":
    print("No se ha desinstalado el programa.")
    exit(0)
elif opcion == "s" or opcion == "S":
    print("Desinstalando printm.")


    print("Se ha desinstalado printm. ¡Hasta pronto!")
    exit(0)
'''
import os
import shutil
import sys

def uninstall_app(app_directory):
    try:
        # Uninstall the app (add your uninstallation logic here)
        # For example, removing installed packages:
        # os.system('pip uninstall -y your_package_name')
        
        # Delete the folder
        shutil.rmtree(app_directory)
        
        # Delete this script
        os.remove(sys.argv[0])
        
        print("App uninstalled and folder deleted successfully.")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    # Provide the path to the app directory
    app_directory = os.path.dirname(os.path.realpath(__file__))
    
    uninstall_app(app_directory)
