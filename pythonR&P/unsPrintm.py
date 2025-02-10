# Desinstalación de printm: Printing Manager
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