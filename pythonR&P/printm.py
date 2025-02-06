# Programa de gestión de impresoras y trabajos de impresión

# Importación de módulos
import win32printing, tkinter
from tkinter import filedialog

# Detección del sistema operativo





# Control de errores
def errores (codigo):
    if codigo == 0:
        print("Programa finalizado exitosamente (" + str(codigo) + ")")
        exit(codigo)
    elif codigo == 1:
        print("Ha habido un error general (" + str(codigo) + ")")
        exit(codigo)

# Menú de opciones
print("1. Ver listado de impresoras")
print("2. Consultar la cola de impresión y/o cancelar un trabajo")
print("3. Imprimir un documento")
print("4. Salir")
opcion = int(input("Selecciona una opción: "))

# Opción 1: listado de impresoras
if opcion == 1:
    print("Has elegido ver el listado de impresoras")
    print("Listado de impresoras:")

    print("Tu impresora predeterminada es ")
# Opción 2: consultar la cola y / o cancelar trabajos
elif opcion == 2:
    print("Has elegido ver la cola de impresión")

    cancelar = input("¿Quieres cancelar algún trabajo? s/N")
    if not cancelar:
        cancelar = "n"
    elif cancelar == "s" or cancelar == "S":
        trabajoACancelar = int(input("Introduce el número del trabajo que quieres cancelar: "))
# Opción 3: imprimir un documento
elif opcion == 3:
    print("Has elegido imprimir un documento")
    tkinter.Tk().withdraw()
    archivos = filedialog.askopenfiles(title="Elige uno o varios archivos", filetypes=(("Word", "*.doc"), ("Word", "*.docx"), ("PDF", "*.pdf"), ("Archivos de texto plano", "*.txt")))
    print(archivos)
# Opción 4: salir del programa
elif opcion == 4:
    errores(0)
else:
    print("No has seleccionado una opción válida")
    errores(1)