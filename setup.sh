#!/bin/bash

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Install dependencies
log "Installing dependencies..."
if ! sudo apt update && sudo apt install -y python3 python3-pip postgresql postgresql-contrib; then
    log "Error: Failed to install dependencies."
    exit 1
fi

# Set up PostgreSQL
log "Setting up PostgreSQL..."
if ! sudo systemctl start postgresql; then
    log "Error: Failed to start PostgreSQL."
    exit 1
fi

if ! sudo -u postgres psql -c "CREATE DATABASE kitchenhelper;" 2>/dev/null; then
    log "Warning: Database 'kitchenhelper' already exists."
fi

if ! sudo -u postgres psql -c "CREATE USER kitchenuser WITH PASSWORD 'kitchenpass';" 2>/dev/null; then
    log "Warning: User 'kitchenuser' already exists."
fi

if ! sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE kitchenhelper TO kitchenuser;"; then
    log "Error: Failed to grant privileges."
    exit 1
fi

# Install Python dependencies
log "Installing Python dependencies..."
if ! pip3 install -r ../backend/requirements.txt; then
    log "Error: Failed to install Python dependencies."
    exit 1
fi

# Environment setup
log "Creating .env file..."
cat <<EOL > ../backend/.env
DATABASE_URL=postgresql://kitchenuser:kitchenpass@localhost/kitchenhelper
EOL

log "Setup completed successfully."