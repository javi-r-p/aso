# Funciones de printm para Windows (win32)
# Importanción de módulos
import win32printing, win32print

# Opción 1: listado de impresoras
def listadoImpresoras(todas=True):
    print("Impresoras registradas en el sistema:")
    # Impresoras guardadas
    impresoras = win32print.EnumPrinters(win32print.PRINTER_ENUM_LOCAL | win32print.PRINTER_ENUM_CONNECTIONS)
    i = 1
    for impresora in impresoras:
        print(f"{i}. {impresora[2]}")
        i += 1

    if todas:
        # Impresoras en la red
        # print("Impresoras encontradas en la red")

        # Impresora predeterminada
        print(f"Tu impresora predeterminada es {win32print.GetDefaultPrinter()}")

# Opción 2:
# Consultar la cola de impresión
def colaImpresion():
    listadoImpresoras(False)

# Cancelar un trabajo
def cancelar():
    print("Cancelar trabajo")

# Opción 3: imprimir uno o varios documentos
def imprimir():
    print ("Estás en un sistema Windows")