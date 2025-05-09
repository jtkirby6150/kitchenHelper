# Recipe Management Desktop Frontend

This is the desktop frontend for the Recipe Management application, built using Python and PyQt5. The desktop application provides a user-friendly interface for managing recipes, allowing users to create, read, update, and delete recipes seamlessly.

## Features

- User-friendly interface for recipe management
- Integration with the backend API for data persistence
- Support for adding, editing, and deleting recipes
- Display of recipe details including ingredients and instructions

## Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   cd recipe-management-app/desktop-frontend
   ```

2. Create a virtual environment (optional but recommended):
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows use `venv\Scripts\activate`
   ```

3. Install the required dependencies:
   ```
   pip install -r requirements.txt
   ```

## Usage

To run the desktop application, execute the following command:
```
python src/main.py
```

Ensure that the backend server is running to allow the desktop application to communicate with it.

## Troubleshooting

If you encounter any issues, please refer to the troubleshooting guide in the `scripts` directory.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.