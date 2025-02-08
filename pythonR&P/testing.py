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