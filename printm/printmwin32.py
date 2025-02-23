# Funciones de printm para Windows (win32)
# Importanción de módulos
import win32print, win32api

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

# Opción 1: listado de impresoras
def listadoImpresoras():
    print("Impresoras registradas en el sistema:")
    # Buscar si el sistema tiene alguna impresora
    impresoras = win32print.EnumPrinters(win32print.PRINTER_ENUM_LOCAL | win32print.PRINTER_ENUM_CONNECTIONS)
    if not impresoras:
        print("No se han encontrado impresoras")
        errores(0)
    else:
        # Mostrar impresoras guardadas
        i = 1
        for impresora in impresoras:
            print(f"{i}. {impresora[2]}")
            i += 1

        # Mostrar impresora predeterminada
        print("----- -----")
        print(f"Tu impresora predeterminada es {win32print.GetDefaultPrinter()}")
    print("----- -----")

# Opción 2: consultar la cola de impresión y/o cancelar un trabajo
def colaImpresion():
    # Abrir impresora predeterminada
    impresora = win32print.GetDefaultPrinter()
    impresora = win32print.OpenPrinter(impresora)
    trabajos = win32print.EnumJobs(impresora, 0, -1, 1)

    # Si no hay trabajos en la cola se muestra un mensaje, en caso contrario, se muestra la cola
    if len(trabajos) == 0:
        print("No hay ningún trabajo en la cola de impresión")
    else:
        for trabajo in trabajos:
            print("-----")
            print(f"Identificador: {trabajo.get("JobId", "Desconocido")}")
            print(f"Usuario: {trabajo.get("UserName", "Desconocido")}")
            print(f"Documento: {trabajo.get("pDocument", "Desconocido")}")
            print(f"Estado: {trabajo.get("Status", "Desconocido")}")
        print("----- -----")
        
        # Preguntar por el trabajo que se desea cancelar, si no se desea cancelar ninguno, se deja vacío
        trabajoACancelar = int(input("Introduce el identificador del trabajo que quieres cancelar\nDejar vacío para no cancelar: "))
        if not trabajoACancelar:
            print("No se ha cancelado ningún trabajo")
        else:
            win32print.SetJob(impresora, trabajoACancelar, 0, None, win32print.JOB_CONTROL_CANCEL)
            print(f"El trabajo con el identificador {trabajoACancelar} se ha cancelado correctamente.")

    # Cerrar la impresora
    win32print.ClosePrinter(impresora)
    print("----- -----")

# Opción 3: imprimir uno o varios documentos
def imprimir(archivo):
    print("Imprimiendo documento")
    win32api.ShellExecute(0, "print", archivo, None, ".", 0)