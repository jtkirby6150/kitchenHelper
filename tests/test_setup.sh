# KitchenHelper

## App Overview
KitchenHelper is a cross-platform application that allows users to search, display, manage, and print detailed recipe information. It includes features such as:
- Ingredient tracking
- Serving size adjustments
- Cook/prep times
- Instructions
- Cuisine categorization
- Dietary tags

## Key Features
- Store and retrieve recipes from a PostgreSQL database.
- Advanced search functionality by ingredient, cuisine, dietary tags, and more.
- Print-friendly recipe views for easy sharing.
- Supports both Windows and Linux platforms.
- Automatic setup via `setup.py` for seamless installation.
- Built-in troubleshooting and self-healing checks.

## Folder Structure
```
recipe-management-app
├── backend               # FastAPI backend for API and database management
├── web-frontend          # Vue.js web application
├── desktop-frontend      # PyQt5 desktop application
├── scripts               # Automation scripts for setup and troubleshooting
├── tests                 # Automated tests for setup and functionality
├── docker-compose.yml    # Docker configuration for containerized deployment
└── README.md             # Project overview and instructions
```

## Requirements
- Python 3.10+
- PostgreSQL (installed via `setup.py`)
- pgAdmin 4 (optional, for manual database management)
- Dependencies (installed automatically):
  - psycopg2
  - PyQt5
  - FastAPI
  - SQLAlchemy
  - Vue.js

## Installation Instructions
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd recipe-management-app/scripts
   ```
2. Run the setup script:
   - **Linux**: `sudo python3 setup.py`
   - **Windows**: Run `setup.py` as an administrator.
3. The setup script will:
   - Install all required dependencies.
   - Install PostgreSQL and pgAdmin 4 (if not already installed).
   - Create the database and tables.
   - Build and launch the application.

## Usage
To launch the app after setup:
- **Linux**: Run `python3 recipeApp/main.py` for the desktop app or `npm run dev` in `web-frontend` for the web app.
- **Windows**: Double-click `main.py` in the `desktop-frontend/src` folder or use `npm run dev` in `web-frontend`.

## Troubleshooting

### Registering a Local PostgreSQL Server in pgAdmin 4

#### Ubuntu
1. **Install and Start PostgreSQL and pgAdmin 4**:
   - Install PostgreSQL:
     ```bash
     sudo apt update && sudo apt install postgresql postgresql-contrib
     ```
   - Install pgAdmin 4:
     ```bash
     sudo apt install pgadmin4
     ```
   - Verify PostgreSQL is running:
     ```bash
     sudo systemctl status postgresql
     ```
     If not running, start it:
     ```bash
     sudo systemctl start postgresql
     ```
   - Set a password for the `postgres` user:
     ```bash
     sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'YourSecretPassword';"
     ```

2. **Launch pgAdmin 4 and Register the Server**:
   - Open pgAdmin 4 from your application menu or run:
     ```bash
     pgadmin4
     ```
   - In the pgAdmin interface, right-click on `Servers` in the left panel and select `Register > Server`.
   - Fill in the following details:
     - **Name**: Local PostgreSQL
     - **Host**: `localhost`
     - **Port**: `5432`
     - **Maintenance Database**: `postgres`
     - **Username**: `postgres`
     - **Password**: The password you set earlier.
   - Save and connect.

3. **Common Errors and Fixes**:
   - **PostgreSQL not running?**
     Run: `sudo systemctl start postgresql`.
   - **Authentication failed?**
     Reset the password for the `postgres` user:
     ```bash
     sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'NewPassword';"
     ```
   - **No `pg_hba.conf` entry for host?**
     Edit the `pg_hba.conf` file to allow connections from `localhost`:
     ```
     host    all             all             127.0.0.1/32            scram-sha-256
     ```
     Restart PostgreSQL after making changes:
     ```bash
     sudo systemctl restart postgresql
     ```

#### Windows
1. **Install and Run PostgreSQL and pgAdmin 4**:
   - Install PostgreSQL using the official installer from [postgresql.org](https://www.postgresql.org/download/).
   - During installation, set a password for the `postgres` user and use the default port `5432`.
   - Ensure the PostgreSQL service is running:
     - Open `Services` (Win + R, type `services.msc`).
     - Locate `PostgreSQL` and ensure its status is "Running". If not, start it.

2. **Launch pgAdmin 4 and Register the Server**:
   - Open pgAdmin 4 from the Start Menu under the PostgreSQL folder.
   - In the pgAdmin interface, right-click on `Servers` in the left panel and select `Register > Server`.
   - Fill in the following details:
     - **Name**: Local PostgreSQL
     - **Host**: `localhost`
     - **Port**: `5432`
     - **Maintenance Database**: `postgres`
     - **Username**: `postgres`
     - **Password**: The password you set during installation.
   - Save and connect.

3. **Common Errors and Fixes**:
   - **PostgreSQL not running?**
     Start the PostgreSQL service via `services.msc`.
   - **Authentication failed?**
     Reset the password for the `postgres` user using the SQL Shell (psql):
     ```sql
     ALTER USER postgres PASSWORD 'NewPassword';
     ```
   - **No `pg_hba.conf` entry for host?**
     Edit the `pg_hba.conf` file to allow connections from `localhost`:
     ```
     host    all             all             127.0.0.1/32            md5
     ```
     Restart PostgreSQL after making changes.

## Automated Testing of Setup Script

### [test_setup.sh](tests/test_setup.sh)
```bash
#!/bin/bash

# Test the setup script in different environments
LOG_FILE="test_setup_$(date '+%Y%m%d_%H%M%S').log"
exec > >(tee -a "$LOG_FILE") 2>&1

test_setup() {
    local ENV=$1
    local BACKEND_PORT=$2
    local WEB_PORT=$3

    echo "Testing setup script with ENV=$ENV, BACKEND_PORT=$BACKEND_PORT, WEB_PORT=$WEB_PORT"
    bash ../scripts/setup.sh --env "$ENV" --backend-port "$BACKEND_PORT" --web-port "$WEB_PORT"
    if [[ $? -ne 0 ]]; then
        echo "Test failed for ENV=$ENV, BACKEND_PORT=$BACKEND_PORT, WEB_PORT=$WEB_PORT"
        exit 1
    fi
    echo "Test passed for ENV=$ENV, BACKEND_PORT=$BACKEND_PORT, WEB_PORT=$WEB_PORT"
}

# Run tests
test_setup "development" 8000 3000
test_setup "staging" 8080 4000
test_setup "production" 80 443

echo "All tests passed!"
```

## Author / License
Created by James Kirby  
(c) 2025 Licensed under MIT
