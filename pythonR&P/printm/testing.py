'''
# 1
import sys
from PyQt5.QtWidgets import QApplication, QMainWindow

class MyApp(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("My First PyQt Application")
        self.setGeometry(100, 100, 600, 400)

def main():
    app = QApplication(sys.argv)
    window = MyApp()
    window.show()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()

# 2
import sys
from PyQt5.QtWidgets import QApplication, QMainWindow, QPushButton

class MyApp(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("My First PyQt Application")
        self.setGeometry(100, 100, 600, 400)
        
        self.button = QPushButton("Click Me", self)
        self.button.move(250, 180)
        self.button.clicked.connect(self.on_click)

    def on_click(self):
        print("Button clicked!")

def main():
    app = QApplication(sys.argv)
    window = MyApp()
    window.show()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()

# 3
import win32print

# Path to the file you want to print
file_path = "C:\\path\\to\\your\\file.txt"

# Specify the printer name
printer_name = "Your Printer Name"

# Set the specific printer as the default printer for the print job
hPrinter = win32print.OpenPrinter(printer_name)
hJob = win32print.StartDocPrinter(hPrinter, 1, ("Print Job", None, "RAW"))
win32print.StartPagePrinter(hPrinter)

with open(file_path, "rb") as file:
    raw_data = file.read()
    win32print.WritePrinter(hPrinter, raw_data)

win32print.EndPagePrinter(hPrinter)
win32print.EndDocPrinter(hPrinter)
win32print.ClosePrinter(hPrinter)

print(f"Printing {file_path} on {printer_name}")

# 4
import win32print

# Path to the file you want to print
file_path = "C:\\path\\to\\your\\file.txt"

# Specify the printer name
printer_name = "Your Printer Name"

try:
    # Open the specific printer
    hPrinter = win32print.OpenPrinter(printer_name)
    try:
        # Start a print job
        hJob = win32print.StartDocPrinter(hPrinter, 1, ("Print Job", None, "RAW"))
        win32print.StartPagePrinter(hPrinter)

        with open(file_path, "rb") as file:
            raw_data = file.read()
            win32print.WritePrinter(hPrinter, raw_data)

        win32print.EndPagePrinter(hPrinter)
        win32print.EndDocPrinter(hPrinter)
    finally:
        # Close the printer handle
        win32print.ClosePrinter(hPrinter)
    print(f"Printing {file_path} on {printer_name}")
except Exception as e:
    print(f"Failed to print: {e}")
'''
# 5
import cups

def getPrinter():
    conn = cups.Connection()
    printers = conn.getPrinters()

    for printer in printers:
        print(f"Printer: {printer}")
        for attribute, value in printers[printer].items():
            print(f"{attribute}: {value}")

getPrinter()