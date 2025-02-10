# Funciones de printm para Linux (linux)

# Control de errores + función de salida
def errores (codigo):
    if codigo == 0:
        print("Programa finalizado exitosamente (" + str(codigo) + ")")
        exit(codigo)
    elif codigo == 1:
        print("Ha habido un error general (" + str(codigo) + ")")
        exit(codigo)

# Opción 1: listado de impresoras
def listadoImpresoras():
    print("Impresoras registradas en el sistema:")

    print("Impresoras encontradas en la red:")

    print("Tu impresora predeterminada es ")

# Opción 2:
# Consultar la cola de impresión
def colaImpresion():
    print("Cola")

# Cancelar un trabajo
def cancelar():
    print("Cancelar trabajo")

# Opción 3: imprimir uno o varios documentos
def imprimir():
    print ("Estás en un sistema Windows")