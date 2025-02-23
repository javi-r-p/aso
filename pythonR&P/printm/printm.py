# Programa de gestión de impresoras y trabajos de impresión

# Importación de módulos
from tkinter import filedialog
from printmFunctions import *
import tkinter

# Función del menú
def menu():
    salir = False
    while not salir:
        try:
            # Menú de opciones
            print("1. Ver listado de impresoras")
            print("2. Consultar la cola de impresión y/o cancelar un trabajo")
            print("3. Imprimir un documento")
            print("4. Salir")

            opcion = int(input("Selecciona una opción: "))
            # Opción 1: listar las impresoras
            if opcion == 1:
                print("Has elegido ver el listado de impresoras")
                listadoImpresoras()
            # Opción 2: consultar la cola y / o cancelar trabajos
            elif opcion == 2:
                print("Has elegido ver la cola de impresión")
                colaImpresion()
            # Opción 3: imprimir un documento
            elif opcion == 3:
                print("Has elegido imprimir un documento")
                # impresora = int(input("\nSelecciona la impresora que quieres utilizar\nSi no seleccionas ninguna, se utilizará la predeterminada: "))
                root = tkinter.Tk()
                root.withdraw()
                archivo = filedialog.askopenfilename(title="Selecciona un archivo", filetypes=[("PDF", "*.pdf")])
                root.destroy()
                imprimir(archivo)
                continuar = True
                while continuar:
                    continuar = input("¿Quieres imprimir otro archivo? (s/N) ")
                    if continuar == "s" or continuar == "S":
                        archivo = filedialog.askopenfilename(title="Selecciona un archivo", filetypes=[("PDF", "*.pdf")])
                        imprimir(archivo)
                        continuar = True
                    else:
                        continuar = False
                print("----- -----")
            # Opción 4: salir del programa
            elif opcion == 4:
                errores(0)
            else:
                print("No has seleccionado una opción válida")
        except ValueError:
            print("No has seleccionado una opción válida")
        except KeyboardInterrupt:
            print("El usuario ha interrumpido el programa")
            errores(0)
menu()