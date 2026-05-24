#!/bin/bash

# NeuroScan AI - Automated Setup Script
# ======================================

echo "🧠 NEUROSCAN AI - Setup Wizard"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Python version
echo "📌 Checking Python version..."
python_version=$(python3 --version 2>&1 | grep -Po '(?<=Python )\d+\.\d+')
if (( $(echo "$python_version >= 3.8" | bc -l) )); then
    echo -e "${GREEN}✓ Python $python_version detected${NC}"
else
    echo -e "${RED}✗ Python 3.8+ required. Found: $python_version${NC}"
    exit 1
fi

# Check MySQL
echo "📌 Checking MySQL..."
if command -v mysql &> /dev/null; then
    echo -e "${GREEN}✓ MySQL detected${NC}"
else
    echo -e "${RED}✗ MySQL not found. Please install MySQL first${NC}"
    exit 1
fi

# Create virtual environment
echo "📌 Creating virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install dependencies
echo "📌 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Create necessary directories
echo "📌 Creating project directories..."
mkdir -p static/uploads
mkdir -p models
mkdir -p logs
touch static/uploads/.gitkeep
touch models/.gitkeep

# Setup database
echo "📌 Setting up database..."
read -p "Enter MySQL root password: " mysql_password

mysql -u root -p$mysql_password << EOF
CREATE DATABASE IF NOT EXISTS neuroai_db;
USE neuroai_db;

SOURCE database/schema.sql;

SHOW TABLES;
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Database setup complete${NC}"
else
    echo -e "${RED}✗ Database setup failed${NC}"
    exit 1
fi

# Create .env file
echo "📌 Creating .env file..."
cat > .env << EOF
# Database Configuration
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=$mysql_password
DB_NAME=neuroai_db

# Flask Configuration
SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_hex(32))')
FLASK_DEBUG=True
FLASK_PORT=5000

# Upload Configuration
MAX_CONTENT_LENGTH=16777216
UPLOAD_FOLDER=static/uploads
EOF

echo -e "${GREEN}✓ .env file created${NC}"

# Create logs directory
mkdir -p logs
touch logs/app.log

# Setup complete
echo ""
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo ""
echo "To start the application:"
echo "  1. Activate virtual environment: source venv/bin/activate"
echo "  2. Run: python app.py"
echo ""
echo "Default credentials:"
echo "  Admin:   admin / admin123"
echo "  Doctor:  doctor@neuroscan.ai / doctor123"
echo "  Patient: patient@neuroscan.ai / patient123"
echo ""
echo "Access at: http://localhost:5000"