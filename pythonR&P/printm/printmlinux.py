# Funciones de printm para Linux (linux)

# Importación de módulos
import cups

# Control de errores + función de salida
def errores (codigo):
    if codigo == 0:
        print("Programa finalizado exitosamente (" + str(codigo) + ")")
        exit(codigo)
    elif codigo == 1:
        print("Ha habido un error general (" + str(codigo) + ")")
        exit(codigo)

# Opción 1: listado de impresoras
def impresoras():
    print("Impresoras registradas en el sistema:")
    conexion = cups.Connection()
    impresoras = conexion.getPrinters()
    for impresora in impresoras:
        print(f"Impresora: {impresora}")
        for atributo, valor in impresoras[impresora].items():
            print(f"{atributo}: {valor}")

    print(f"Tu impresora predeterminada es {conexion.getDefault()}")

# Opción 2:
# Consultar la cola de impresión
def colaImpresion():
    print("Cola")

# Cancelar un trabajo
def cancelar():
    print("Cancelar trabajo")

# Opción 3: imprimir uno o varios documentos
def imprimir():
    print ("Estás en un sistema Linux")