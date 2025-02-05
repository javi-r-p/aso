# Programa de gestión de impresoras y trabajos de impresión

# Importación de módulos
import win32printing

# Detección del sistema operativo


# Menú de opciones
print("1. Ver listado de impresoras")
print("2. Consultar la cola de impresión y/o cancelar un trabajo")
print("3. Imprimir un documento")
print("4. Salir")
opcion = int(input("Selecciona una opción: "))

# Control de errores
def errores (codigo):
    if codigo == 0:
        print("Programa finalizado exitosamente (" + codigo + ")")
        exit(codigo)

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

# Opción 4: salir del programa
elif opcion == 4:
    errores(0)