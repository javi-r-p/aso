# Desinstalación de printm: Printing Manager
# Importación de módulos
import os, shutil

# Elección
print("Desinstalador de printm")
opcion = input("¿Quieres desinstalar printm? (s/N) ")

# Si no se introduce ninguna letra O se introduce la N, la desinstalación se cancela
if not opcion or opcion == "n" or opcion == "N":
    print("No se ha desinstalado el programa.")
    exit(0)
# Si se introduce la letra  S, se comienza el proceso de desinstalación
else:
    # Eliminar directorio de instalación y el desinstalador
    print("Desinstalando printm.")
    try:
        # Elimina la carpeta de la aplicación
        shutil.rmtree(os.path.dirname(os.path.realpath(__file__)))
        # Elimina el propio desinstaldor
        os.remove(sys.argv[0])

    # Si ocurre un error, mostrarlo por pantalla
    except Exception as error:
        print(f"Error: {error}")