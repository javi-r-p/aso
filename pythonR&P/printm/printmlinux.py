# Funciones de printm para Linux (linux)

# Importación de módulos
import cups, subprocess

# Control de errores + función de salida
def errores (codigo):
    if codigo == 0:
        print(f"Programa finalizado exitosamente ({str(codigo)})")
        exit(codigo)
    elif codigo == 1:
        print(f"Ha habido un error general ({str(codigo)})")
        exit(codigo)
    elif codigo == 2:
        print(f"Opción no válida ({str(codigo)})")
        exit(codigo)

conexion = cups.Connection()
impresoras = conexion.getPrinters()

# Opción 1: listado de impresoras
def listadoImpresoras():
    print("Impresoras registradas en el sistema:")
    estados = {0: "desconocido", 3: "disponible", 4: "ocupada", 5: "no disponible"}
    for impresora in impresoras:
        print(" ----- ")
        print(f"Impresora: {impresora}")
        print(f"URI: {impresoras[impresora].get("device-uri", "URI desconocido")}")
        if impresoras[impresora].get("printer-is-shared"):
            print("Compartida: sí")
        else:
            print("Compartida: no")
        print(f"Estado: {estados[impresoras[impresora].get("printer-state", 0)]}")
    print(" ----- -----")
    print(f"Tu impresora predeterminada es {conexion.getDefault()}")

# Opción 2:
# Consultar la cola de impresión
def colaImpresion():
    trabajos = conexion.getJobs()
    if len(trabajos) == 0:
        print("No hay ningún trabajo en la cola de impresión")
        errores(0)
    else:
        for id, trabajo in trabajos.items():
            print(" ----- ")
            print(f"Identificador: {id}")
            print(f"Usuario: {trabajo.get("job-state", "desconocido")}")
            print(f"Nombre: {trabajo.get("title", "desconocido")}")
            print(f"Estado: {trabajo.get("job-state", "desconocido")}")
            print(f"Impresora: {trabajo.get("printer-uri")}")
            print(f"Fecha: {trabajo.get("time-at-creation", "desconocido")}")

# Cancelar un trabajo
def cancelar():
    print("Cancelar trabajo")

# Opción 3: imprimir uno o varios documentos
def imprimir(archivo):
    listadoImpresoras()
    impresora = input("Introduce el número de la impresora que quieres utilizar.\nDeja el campo vacío para utilizar la predeterminada: ")
    if not impresora:
        impresora = conexion.getDefault()
    subprocess.run(["lp", "-d", impresora, archivo])