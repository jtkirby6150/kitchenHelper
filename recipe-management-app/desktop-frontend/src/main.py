from PyQt5 import QtWidgets
import sys

class MainWindow(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Recipe Management App")
        self.setGeometry(100, 100, 800, 600)

        # Set up the UI components here
        self.init_ui()

    def init_ui(self):
        # Placeholder for UI initialization
        pass

def main():
    app = QtWidgets.QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()