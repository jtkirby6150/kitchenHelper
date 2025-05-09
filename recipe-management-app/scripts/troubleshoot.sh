#!/bin/bash

echo "Troubleshooting Script for Recipe Management App"

# Check if PostgreSQL is running
if ! systemctl is-active --quiet postgresql; then
    echo "PostgreSQL is not running. Starting PostgreSQL..."
    sudo systemctl start postgresql
else
    echo "PostgreSQL is running."
fi

# Check if the backend server is running
if ! pgrep -f "uvicorn" > /dev/null; then
    echo "Backend server is not running. Starting backend server..."
    cd backend/app && uvicorn main:app --host 0.0.0.0 --port 8000 &
else
    echo "Backend server is running."
fi

# Check if the frontend is built
if [ ! -d "web-frontend/dist" ]; then
    echo "Web frontend is not built. Building web frontend..."
    cd web-frontend && npm install && npm run build
else
    echo "Web frontend is built."
fi

# Check for common Python package issues
echo "Checking for missing Python packages..."
pip check

echo "Troubleshooting completed."