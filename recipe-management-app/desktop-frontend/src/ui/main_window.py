from PyQt5.QtWidgets import QApplication, QMainWindow, QAction, QFileDialog, QMessageBox
import sys

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Recipe Management App")
        self.setGeometry(100, 100, 800, 600)
        self.init_ui()

    def init_ui(self):
        menubar = self.menuBar()
        file_menu = menubar.addMenu('File')

        open_action = QAction('Open', self)
        open_action.triggered.connect(self.open_file)
        file_menu.addAction(open_action)

        save_action = QAction('Save', self)
        save_action.triggered.connect(self.save_file)
        file_menu.addAction(save_action)

        exit_action = QAction('Exit', self)
        exit_action.triggered.connect(self.close)
        file_menu.addAction(exit_action)

    def open_file(self):
        options = QFileDialog.Options()
        file_name, _ = QFileDialog.getOpenFileName(self, "Open Recipe File", "", "All Files (*);;Text Files (*.txt)", options=options)
        if file_name:
            try:
                with open(file_name, 'r') as file:
                    content = file.read()
                    QMessageBox.information(self, "File Content", content)
            except Exception as e:
                QMessageBox.critical(self, "Error", f"Failed to open file: {str(e)}")

    def save_file(self):
        options = QFileDialog.Options()
        file_name, _ = QFileDialog.getSaveFileName(self, "Save Recipe File", "", "All Files (*);;Text Files (*.txt)", options=options)
        if file_name:
            try:
                with open(file_name, 'w') as file:
                    file.write("Sample Recipe Content")
                    QMessageBox.information(self, "Success", "File saved successfully.")
            except Exception as e:
                QMessageBox.critical(self, "Error", f"Failed to save file: {str(e)}")

if __name__ == "__main__":
    app = QApplication(sys.argv)
    main_window = MainWindow()
    main_window.show()
    sys.exit(app.exec_())