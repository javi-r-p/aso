# Programa de gestión de impresoras y trabajos de impresión

# Importación de módulos y funciones
import tkinter, sys
from tkinter import filedialog
from printmFunctions import *

# Control de errores + función de salida
def errores (codigo):
    if codigo == 0:
        print("Programa finalizado exitosamente (" + str(codigo) + ")")
        exit(codigo)
    elif codigo == 1:
        print("Ha habido un error general (" + str(codigo) + ")")
        exit(codigo)

# Funciones del programa
# Opción 1: consultar el listado de impresoras
def opcion1():
    print("Has elegido ver el listado de impresoras")
    listadoImpresoras()

# Opción 2: consultar la cola de impresión
def opcion2():
    print("Has elegido ver la cola de impresión")
    colaImpresion()

    global cancelar
    cancelar = input("¿Quieres cancelar algún trabajo? s/N ")
    if not cancelar or cancelar == "N" or cancelar == "n":
        cancelar = "n"
        print("No se ha cancelado ningún trabajo.")
        errores(0)
    elif cancelar == "s" or cancelar == "S":
        trabajoACancelar = int(input("Introduce el número del trabajo que quieres cancelar: "))
        cancelar(trabajoACancelar)

# Opción 3: imprimir uno o varios documentos
def opcion3():
    print("Has elegido imprimir un documento")
    tkinter.Tk().withdraw()
    archivos = filedialog.askopenfiles(title="Elige uno o varios archivos")
    print(archivos)

# Menú de opciones
print("1. Ver listado de impresoras")
print("2. Consultar la cola de impresión y/o cancelar un trabajo")
print("3. Imprimir un documento")
print("4. Salir")
opcion = int(input("Selecciona una opción: "))

# Opción 1: listado de impresoras
if opcion == 1:
    opcion1()
# Opción 2: consultar la cola y / o cancelar trabajos
elif opcion == 2:
    opcion2()
# Opción 3: imprimir un documento
elif opcion == 3:
    opcion3()
# Opción 4: salir del programa
elif opcion == 4:
    errores(0)
else:
    print("No has seleccionado una opción válida")
    errores(1)