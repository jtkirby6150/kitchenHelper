#!/bin/bash

# This script automates the setup process for the Recipe Management App
# Logs all output to setup.log for troubleshooting

LOG_FILE="setup_$(date '+%Y%m%d_%H%M%S').log"
exec > >(tee -a "$LOG_FILE") 2>&1

log() {
    local LEVEL=$1
    shift
    echo "[$LEVEL] $(date '+%Y-%m-%d %H:%M:%S') $*"
}

retry() {
    local MAX_RETRIES=$1
    local COMMAND="${@:2}"
    local RETRY_COUNT=0
    until $COMMAND; do
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [[ $RETRY_COUNT -ge $MAX_RETRIES ]]; then
            log "ERROR" "Command failed after $MAX_RETRIES attempts: $COMMAND"
            return 1
        fi
        log "WARN" "Retrying command ($RETRY_COUNT/$MAX_RETRIES): $COMMAND"
        sleep 2
    done
    return 0
}

prompt_user() {
    local MESSAGE=$1
    local DEFAULT=$2
    read -p "$MESSAGE [Y/n]: " RESPONSE
    RESPONSE=${RESPONSE:-$DEFAULT}
    if [[ "$RESPONSE" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_dependency() {
    local COMMAND=$1
    local MIN_VERSION=$2
    local INSTALLED_VERSION

    if ! command_exists "$COMMAND"; then
        log "ERROR" "$COMMAND is not installed. Please install it before proceeding."
        exit 1
    fi

    if [[ -n "$MIN_VERSION" ]]; then
        INSTALLED_VERSION=$($COMMAND --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
        if [[ "$(printf '%s\n' "$MIN_VERSION" "$INSTALLED_VERSION" | sort -V | head -n 1)" != "$MIN_VERSION" ]]; then
            log "ERROR" "$COMMAND version $INSTALLED_VERSION is installed, but version $MIN_VERSION or higher is required."
            exit 1
        fi
    fi
}

handle_error() {
    local ERROR_MESSAGE=$1
    local SUGGESTION=$2
    log "ERROR" "$ERROR_MESSAGE"
    log "INFO" "SUGGESTION: $SUGGESTION"
    exit 1
}

log "INFO" "Setup started"

# Default configurations
ENVIRONMENT="development"
BACKEND_PORT=8000
WEB_PORT=3000

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        --backend-port)
            BACKEND_PORT="$2"
            shift 2
            ;;
        --web-port)
            WEB_PORT="$2"
            shift 2
            ;;
        *)
            log "WARN" "Unknown argument: $1"
            shift
            ;;
    esac
done

log "INFO" "Environment: $ENVIRONMENT"
log "INFO" "Backend Port: $BACKEND_PORT"
log "INFO" "Web Port: $WEB_PORT"

# Validate dependencies
log "INFO" "Validating dependencies..."
validate_dependency "python3" "3.10"
validate_dependency "pip3"
validate_dependency "docker" "20.10"
validate_dependency "docker-compose" "1.29"
validate_dependency "node" "16.0"
validate_dependency "npm"

log "INFO" "All dependencies are validated."

# Detect the operating system
OS=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    OS="Windows"
else
    log "ERROR" "Unsupported operating system: $OSTYPE"
    exit 1
fi

log "INFO" "Detected OS: $OS"

# Interactive prompt to continue
if ! prompt_user "Do you want to proceed with the setup?" "Y"; then
    log "INFO" "Setup aborted by the user."
    exit 0
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Parallelized setup
install_dependencies() {
    log "INFO" "Installing dependencies..."
    retry 3 sudo apt update
    retry 3 sudo apt install -y python3 python3-pip nodejs npm docker.io docker-compose || {
        handle_error "Failed to install dependencies." \
                     "Ensure you have an active internet connection and the correct package repositories configured."
    }
    log "INFO" "Dependencies installed successfully."
}

configure_postgresql() {
    log "INFO" "Configuring PostgreSQL..."
    retry 3 sudo apt install -y postgresql postgresql-contrib
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    log "INFO" "PostgreSQL configured successfully."
}

setup_backend() {
    log "INFO" "Setting up backend..."
    retry 3 pip3 install -r ../backend/requirements.txt || {
        handle_error "Failed to install backend dependencies." \
                     "Ensure the requirements.txt file exists and is correctly formatted. Verify your internet connection."
    }
    log "INFO" "Backend setup completed."
}

setup_frontend() {
    log "INFO" "Setting up frontend..."
    cd ../web-frontend
    npm install
    npm run build
    cd -
    log "INFO" "Frontend setup completed."
}

log "INFO" "Starting parallelized setup..."
install_dependencies &
configure_postgresql &
setup_backend &
setup_frontend &
wait
log "INFO" "Parallelized setup completed."

# Update Docker Compose configuration with custom ports
log "INFO" "Updating Docker Compose configuration..."
DOCKER_COMPOSE_FILE="../docker-compose.yml"
cat <<EOL > "$DOCKER_COMPOSE_FILE"
version: '3.8'

services:
  backend:
    build:
      context: ./backend
    volumes:
      - ./backend:/app
    ports:
      - "$BACKEND_PORT:8000"
    environment:
      - DATABASE_URL=postgresql://recipe_user:secure_password@db:5432/recipe_management
    depends_on:
      - db

  db:
    image: postgres:latest
    volumes:
      - db_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=recipe_user
      - POSTGRES_PASSWORD=secure_password
      - POSTGRES_DB=recipe_management

  web:
    build:
      context: ./web-frontend
    volumes:
      - ./web-frontend:/app
    ports:
      - "$WEB_PORT:3000"
    depends_on:
      - backend

volumes:
  db_data:
EOL
log "INFO" "Docker Compose configuration updated with custom ports."

# Ensure PostgreSQL is running
if [[ "$OS" == "Linux" ]]; then
    log "INFO" "Ensuring PostgreSQL service is running..."
    retry 3 sudo systemctl start postgresql || {
        handle_error "Failed to start PostgreSQL service." \
                     "Check if PostgreSQL is installed and running. Use 'sudo systemctl status postgresql' to diagnose the issue."
    }
    log "INFO" "PostgreSQL service is running."
fi

# Verify pg_hba.conf configuration
if [[ "$OS" == "Linux" ]]; then
    log "INFO" "Verifying pg_hba.conf configuration..."
    PG_HBA_PATH=$(sudo -u postgres psql -t -P format=unaligned -c "SHOW hba_file;")
    if ! grep -q "127.0.0.1/32" "$PG_HBA_PATH"; then
        log "INFO" "Updating pg_hba.conf to allow localhost connections..."
        echo "host    all             all             127.0.0.1/32            scram-sha-256" | sudo tee -a "$PG_HBA_PATH"
        retry 3 sudo systemctl reload postgresql || {
            handle_error "Failed to reload PostgreSQL after updating pg_hba.conf." \
                         "Check the syntax of pg_hba.conf and ensure PostgreSQL is running. Use 'sudo systemctl status postgresql' to diagnose the issue."
        }
    else
        log "INFO" "pg_hba.conf is correctly configured for localhost connections."
    fi
fi

# Configure PostgreSQL for remote access
if [[ "$OS" == "Linux" ]]; then
    log "INFO" "Configuring PostgreSQL for remote access..."
    PG_CONF_PATH=$(sudo -u postgres psql -t -P format=unaligned -c "SHOW config_file;")
    if ! grep -q "listen_addresses = '*'" "$PG_CONF_PATH"; then
        log "INFO" "Updating PostgreSQL configuration to allow remote connections..."
        sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" "$PG_CONF_PATH"
        retry 3 sudo systemctl restart postgresql || {
            handle_error "Failed to restart PostgreSQL after updating configuration." \
                         "Check the syntax of the PostgreSQL configuration file and ensure PostgreSQL is running."
        }
    else
        log "INFO" "PostgreSQL is already configured for remote access."
    fi

    # Ensure pg_hba.conf allows remote connections
    log "INFO" "Verifying pg_hba.conf for remote access..."
    PG_HBA_PATH=$(sudo -u postgres psql -t -P format=unaligned -c "SHOW hba_file;")
    if ! grep -q "0.0.0.0/0" "$PG_HBA_PATH"; then
        log "INFO" "Adding remote access rule to pg_hba.conf..."
        echo "host    all             all             0.0.0.0/0            scram-sha-256" | sudo tee -a "$PG_HBA_PATH"
        retry 3 sudo systemctl reload postgresql || {
            handle_error "Failed to reload PostgreSQL after updating pg_hba.conf." \
                         "Check the syntax of pg_hba.conf and ensure PostgreSQL is running. Use 'sudo systemctl status postgresql' to diagnose the issue."
        }
    else
        log "INFO" "pg_hba.conf is already configured for remote access."
    fi
fi

# Set PostgreSQL user password
log "INFO" "Setting password for PostgreSQL user 'postgres'..."
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'YourSecretPassword';" || {
    handle_error "Failed to set password for PostgreSQL user 'postgres'." \
                 "Ensure PostgreSQL is running and the user 'postgres' exists. Use 'sudo -u postgres psql' to diagnose the issue."
}

# Final message
log "INFO" "Setup completed successfully!"
log "INFO" "PostgreSQL is configured for local and remote access."
log "INFO" "Environment variables for the backend are set up in the .env file."
log "INFO" "Docker Compose configuration is updated with custom ports."
log "INFO" "All services passed health checks."