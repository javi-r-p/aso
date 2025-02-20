# Programa de gestión de impresoras y trabajos de impresión

# Importación de módulos y funciones
import sys
from printmlinux import *


# Menú de opciones
print("1. Ver listado de impresoras")
print("2. Consultar la cola de impresión y/o cancelar un trabajo")
print("3. Imprimir un documento")
print("4. Salir")
opcion = int(input("Selecciona una opción: "))

# Opción 1: listado de impresoras
if opcion == 1:
    print("Has elegido ver el listado de impresoras")
    impresoras()
# Opción 2: consultar la cola y / o cancelar trabajos
elif opcion == 2:
    print("Has elegido ver la cola de impresión")
    colaImpresion()
# Opción 3: imprimir un documento
elif opcion == 3:
    print("Has elegido imprimir un documento")
    impresoras()
    # impresora = int(input("\nSelecciona la impresora que quieres utilizar\nSi no seleccionas ninguna, se utilizará la predeterminada: "))
    archivo = input("Introduce la ruta absoluta del archivo: ")
    imprimir(archivo)
    continuar = True
    while continuar is True:
        continuar = input("¿Quieres imprimir otro archivo? (s/N) ")
        if continuar == "s" or continuar == "S":
            archivo = input("Introduce la ruta absoluta del archivo: ")
            imprimir(archivo)
            continuar = True
        else:
            errores(0)
# Opción 4: salir del programa
elif opcion == 4:
    errores(0)
else:
    print("No has seleccionado una opción válida")
    errores(1)