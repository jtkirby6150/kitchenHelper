<#
.SYNOPSIS
This script automates the setup process for the Recipe Management App on Windows.

.DESCRIPTION
The script installs dependencies, configures PostgreSQL, and sets up the application environment.

.PARAMETER Environment
Specifies the environment (e.g., development, staging, production). Default is 'development'.

.PARAMETER BackendPort
Specifies the port for the backend. Default is 8000.

.PARAMETER WebPort
Specifies the port for the web frontend. Default is 3000.

#>

param (
    [string]$Environment = "development",
    [int]$BackendPort = 8000,
    [int]$WebPort = 3000
)

Write-Host "Setup started at $(Get-Date)" -ForegroundColor Green
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host "Backend Port: $BackendPort" -ForegroundColor Yellow
Write-Host "Web Port: $WebPort" -ForegroundColor Yellow

# Function to check if a command exists
function Test-Command {
    param (
        [string]$Command
    )
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Validate dependencies
Write-Host "Validating dependencies..." -ForegroundColor Yellow
if (-not (Test-Command python)) {
    Write-Host "Python is not installed. Please install Python 3.10+ from https://www.python.org/downloads/" -ForegroundColor Red
    exit 1
}
if (-not (Test-Command docker)) {
    Write-Host "Docker is not installed. Please install Docker Desktop from https://www.docker.com/products/docker-desktop/" -ForegroundColor Red
    exit 1
}
if (-not (Test-Command docker-compose)) {
    Write-Host "Docker Compose is not installed. It is included with Docker Desktop. Please ensure Docker Desktop is installed." -ForegroundColor Red
    exit 1
}
if (-not (Test-Command node)) {
    Write-Host "Node.js is not installed. Please install Node.js 16+ from https://nodejs.org/" -ForegroundColor Red
    exit 1
}
if (-not (Test-Command npm)) {
    Write-Host "npm is not installed. It is included with Node.js. Please ensure Node.js is installed." -ForegroundColor Red
    exit 1
}
Write-Host "All dependencies are validated." -ForegroundColor Green

# Install backend dependencies
Write-Host "Installing backend dependencies..." -ForegroundColor Yellow
pip install -r ../backend/requirements.txt

# Install frontend dependencies
Write-Host "Installing frontend dependencies..." -ForegroundColor Yellow
cd ../web-frontend
npm install
npm run build
cd ..

# Create Docker Compose configuration
Write-Host "Creating Docker Compose configuration..." -ForegroundColor Yellow
$dockerComposeContent = @"
version: '3.8'

services:
  backend:
    build:
      context: ./backend
    volumes:
      - ./backend:/app
    ports:
      - "$BackendPort:8000"
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
      - "$WebPort:3000"
    depends_on:
      - backend

volumes:
  db_data:
"@
$dockerComposeContent | Out-File -FilePath ../docker-compose.yml -Encoding utf8
Write-Host "Docker Compose configuration created successfully." -ForegroundColor Green

Write-Host "Setup completed successfully!" -ForegroundColor Green
