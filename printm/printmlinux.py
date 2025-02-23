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

# Conexión al servicio cups y obtención de las impresoras
conexion = cups.Connection()
impresoras = conexion.getPrinters()

# Opción 1: listado de impresoras
def listadoImpresoras():
    # Si no hay impresoras se muestra un mensaje por pantalla, en caso contrario, mostrar un listado por pantalla
    if not impresoras:
        print("No se han encontrado impresoras")
        errores(0)
    else:
        # Mostrar impresoras guardadas
        print("Impresoras registradas en el sistema:")
        estados = {0: "desconocido", 3: "disponible", 4: "ocupada", 5: "no disponible"}
        for impresora in impresoras:
            print("-----")
            print(f"Impresora: {impresora}")
            print(f"URI: {impresoras[impresora].get("device-uri", "URI desconocido")}")
            if impresoras[impresora].get("printer-is-shared"):
                print("Compartida: sí")
            else:
                print("Compartida: no")
            print(f"Estado: {estados[impresoras[impresora].get("printer-state", 0)]}")
        print("----- -----")

        # Mostrar impresora predeterminada
        print(f"Tu impresora predeterminada es {conexion.getDefault()}")
        print("----- -----")

# Opción 2: consultar la cola de impresión y/o cancelar un trabajo
def colaImpresion():
    # Obtener cola de impresión
    trabajos = conexion.getJobs()

    # Si no hay trabajos en la cola se muestra un mensaje, en caso contrario, se muestra la cola
    if len(trabajos) == 0:
        print("No hay ningún trabajo en la cola de impresión")
        print("----- -----")
    else:
        for id, trabajo in trabajos.items():
            print("-----")
            print(f"Identificador: {id}")
            print(f"Usuario: {trabajo.get("job-state", "desconocido")}")
            print(f"Nombre: {trabajo.get("title", "desconocido")}")
            print(f"Estado: {trabajo.get("job-state", "desconocido")}")
            print(f"Impresora: {trabajo.get("printer-uri", "desconocido")}")
            print(f"Fecha: {trabajo.get("time-at-creation", "desconocido")}")
        print("----- -----")
        
        # Preguntar por el trabajo que se desea cancelar, si no se desea cancelar ninguno, se deja vacío
        trabajoACancelar = int(input("Introduce el identificador del trabajo que quieres cancelar\nDejar vacío para no cancelar: "))
        if not trabajoACancelar:
            print("No se ha cancelado ningún trabajo")
        else:
            conexion.cancelJob(trabajoACancelar)
            print(f"El trabajo con el identificador {trabajoACancelar} se ha cancelado correctamente.")

# Opción 3: imprimir uno o varios documentos
def imprimir(archivo):
    listadoImpresoras()
    impresora = input("Introduce el nombre de la impresora que quieres utilizar.\nDeja el campo vacío para utilizar la predeterminada: ")
    if not impresora:
        impresora = conexion.getDefault()
    subprocess.run(["lp", "-d", impresora, archivo])