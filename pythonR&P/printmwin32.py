# Funciones de printm para Windows (win32)
# Importanción de módulos
import win32printing, win32print, win32api

# Control de errores + función de salida
def errores (codigo):
    if codigo != 0:
        print("ERRORES: ")
    if codigo == 0:
        print("Programa finalizado exitosamente (" + str(codigo) + ")")
        exit(codigo)
    elif codigo == 1:
        print("No hay ninguna impresora (" + str(codigo) + ")")
        exit(codigo)

# Opción 1: listado de impresoras
def impresoras(impresora = "todas"):
    print("Impresoras registradas en el sistema:")
    # Buscar si el sistema tiene alguna impresora
    impresoras = win32print.EnumPrinters(win32print.PRINTER_ENUM_LOCAL | win32print.PRINTER_ENUM_CONNECTIONS)
    if not impresoras:
        errores(1)

    if impresora == "todas":
        # Impresoras guardadas
        i = 1
        for impresora in impresoras:
            print(f"{i}. {impresora[2]}")
            i += 1

        # Impresora predeterminada
        print(f"Tu impresora predeterminada es {win32print.GetDefaultPrinter()}")
    
    elif impresora == "predeterminada":
        # Impresora predeterminada
        print(f"Tu impresora predeterminada es {win32print.GetDefaultPrinter()}")


# Opción 2:
# Consultar la cola de impresión
def colaImpresion():
    impresoras()

# Cancelar un trabajo
def cancelar():
    cancelar = input("¿Quieres cancelar algún trabajo? s/N ")
    if not cancelar or cancelar == "N" or cancelar == "n":
        cancelar = "n"
        print("No se ha cancelado ningún trabajo.")
        errores(0)
    elif cancelar == "s" or cancelar == "S":
        trabajoACancelar = int(input("Introduce el número del trabajo que quieres cancelar: "))
        cancelar(trabajoACancelar)

# Opción 3: imprimir uno o varios documentos
def imprimir(archivo):
    print("Imprimiendo documento")
    win32api.ShellExecute(0, "print", archivo, None, ".", 0)