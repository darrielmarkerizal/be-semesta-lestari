#!/bin/bash

# VPS Deployment Script for Semesta Lestari API
# This script automates the deployment process

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Semesta Lestari API - VPS Deployment${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo -e "${RED}Please do not run this script as root${NC}"
   echo "Run as regular user with sudo privileges"
   exit 1
fi

# Function to print step
print_step() {
    echo ""
    echo -e "${YELLOW}>>> $1${NC}"
    echo ""
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: Update system
print_step "Step 1: Updating system packages"
sudo apt update
sudo apt upgrade -y

# Step 2: Install Node.js
print_step "Step 2: Installing Node.js 18 LTS"
if ! command_exists node; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
    echo -e "${GREEN}✓ Node.js installed: $(node --version)${NC}"
else
    echo -e "${GREEN}✓ Node.js already installed: $(node --version)${NC}"
fi

# Step 3: Install MySQL
print_step "Step 3: Installing MySQL"
if ! command_exists mysql; then
    sudo apt install -y mysql-server
    echo -e "${GREEN}✓ MySQL installed${NC}"
    echo -e "${YELLOW}⚠ Please run 'sudo mysql_secure_installation' after this script${NC}"
else
    echo -e "${GREEN}✓ MySQL already installed${NC}"
fi

# Step 4: Install PM2
print_step "Step 4: Installing PM2"
if ! command_exists pm2; then
    sudo npm install -g pm2
    echo -e "${GREEN}✓ PM2 installed${NC}"
else
    echo -e "${GREEN}✓ PM2 already installed${NC}"
fi

# Step 5: Install Nginx
print_step "Step 5: Installing Nginx"
if ! command_exists nginx; then
    sudo apt install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo -e "${GREEN}✓ Nginx installed and started${NC}"
else
    echo -e "${GREEN}✓ Nginx already installed${NC}"
fi

# Step 6: Install Git
print_step "Step 6: Installing Git"
if ! command_exists git; then
    sudo apt install -y git
    echo -e "${GREEN}✓ Git installed${NC}"
else
    echo -e "${GREEN}✓ Git already installed${NC}"
fi

# Step 7: Create application directory
print_step "Step 7: Setting up application directory"
APP_DIR="/var/www/be-semesta-lestari"

if [ ! -d "$APP_DIR" ]; then
    sudo mkdir -p $APP_DIR
    sudo chown -R $USER:$USER $APP_DIR
    echo -e "${GREEN}✓ Application directory created: $APP_DIR${NC}"
else
    echo -e "${GREEN}✓ Application directory exists: $APP_DIR${NC}"
fi

# Step 8: Configure firewall
print_step "Step 8: Configuring firewall"
if command_exists ufw; then
    sudo ufw allow 22
    sudo ufw allow 80
    sudo ufw allow 443
    echo "y" | sudo ufw enable
    echo -e "${GREEN}✓ Firewall configured${NC}"
else
    echo -e "${YELLOW}⚠ UFW not found, skipping firewall configuration${NC}"
fi

# Step 9: Create database setup script
print_step "Step 9: Creating database setup script"
cat > /tmp/setup-db.sql << 'EOF'
CREATE DATABASE IF NOT EXISTS semesta_lestari CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'semesta_user'@'localhost' IDENTIFIED BY 'CHANGE_THIS_PASSWORD';
GRANT ALL PRIVILEGES ON semesta_lestari.* TO 'semesta_user'@'localhost';
FLUSH PRIVILEGES;
EOF

echo -e "${GREEN}✓ Database setup script created at /tmp/setup-db.sql${NC}"
echo -e "${YELLOW}⚠ Edit the password in /tmp/setup-db.sql and run:${NC}"
echo -e "${YELLOW}   sudo mysql < /tmp/setup-db.sql${NC}"

# Step 10: Create .env template
print_step "Step 10: Creating .env template"
cat > $APP_DIR/.env.template << 'EOF'
# Server Configuration
PORT=5000
NODE_ENV=production

# Database Configuration
DB_HOST=localhost
DB_USER=semesta_user
DB_PASSWORD=CHANGE_THIS_PASSWORD
DB_NAME=semesta_lestari
DB_PORT=3306

# JWT Configuration (CHANGE THIS - use a random 32+ character string)
JWT_SECRET=CHANGE_THIS_TO_A_RANDOM_32_PLUS_CHARACTER_STRING
JWT_EXPIRE=7d
JWT_REFRESH_EXPIRE=30d

# Swagger Configuration
SWAGGER_ENABLED=true

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
EOF

echo -e "${GREEN}✓ .env template created at $APP_DIR/.env.template${NC}"
echo -e "${YELLOW}⚠ Copy and edit: cp $APP_DIR/.env.template $APP_DIR/.env${NC}"

# Step 11: Create Nginx configuration
print_step "Step 11: Creating Nginx configuration"
read -p "Enter your domain name (or press Enter to use server IP): " DOMAIN_NAME

if [ -z "$DOMAIN_NAME" ]; then
    DOMAIN_NAME="_"
fi

sudo tee /etc/nginx/sites-available/semesta-api > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN_NAME;

    client_max_body_size 10M;

    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    location /uploads {
        alias $APP_DIR/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location /api-docs {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Enable site
sudo ln -sf /etc/nginx/sites-available/semesta-api /etc/nginx/sites-enabled/

# Test and reload Nginx
sudo nginx -t && sudo systemctl reload nginx

echo -e "${GREEN}✓ Nginx configuration created and enabled${NC}"

# Step 12: Create backup script
print_step "Step 12: Creating backup script"
sudo tee /usr/local/bin/backup-semesta.sh > /dev/null << 'EOF'
#!/bin/bash

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/semesta"
DB_NAME="semesta_lestari"
DB_USER="semesta_user"
DB_PASS="CHANGE_THIS_PASSWORD"
APP_DIR="/var/www/be-semesta-lestari"

mkdir -p $BACKUP_DIR

mysqldump -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $BACKUP_DIR/db_backup_$DATE.sql.gz
tar -czf $BACKUP_DIR/uploads_backup_$DATE.tar.gz -C $APP_DIR uploads

find $BACKUP_DIR -name "db_backup_*.sql.gz" -mtime +7 -delete
find $BACKUP_DIR -name "uploads_backup_*.tar.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
EOF

sudo chmod +x /usr/local/bin/backup-semesta.sh
echo -e "${GREEN}✓ Backup script created at /usr/local/bin/backup-semesta.sh${NC}"
echo -e "${YELLOW}⚠ Edit the DB_PASS in the backup script${NC}"

# Summary
print_step "Installation Complete!"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Next Steps:${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "1. Secure MySQL:"
echo "   ${YELLOW}sudo mysql_secure_installation${NC}"
echo ""
echo "2. Create database and user:"
echo "   ${YELLOW}nano /tmp/setup-db.sql${NC} (edit password)"
echo "   ${YELLOW}sudo mysql < /tmp/setup-db.sql${NC}"
echo ""
echo "3. Upload your application files to:"
echo "   ${YELLOW}$APP_DIR${NC}"
echo ""
echo "4. Configure environment:"
echo "   ${YELLOW}cp $APP_DIR/.env.template $APP_DIR/.env${NC}"
echo "   ${YELLOW}nano $APP_DIR/.env${NC} (edit all values)"
echo ""
echo "5. Install dependencies:"
echo "   ${YELLOW}cd $APP_DIR && npm install --production${NC}"
echo ""
echo "6. Initialize database:"
echo "   ${YELLOW}cd $APP_DIR && npm run init-db${NC}"
echo "   ${YELLOW}node src/scripts/addImageUrlColumns.js${NC}"
echo ""
echo "7. Create uploads directory:"
echo "   ${YELLOW}mkdir -p $APP_DIR/uploads${NC}"
echo "   ${YELLOW}chmod 755 $APP_DIR/uploads${NC}"
echo ""
echo "8. Start application:"
echo "   ${YELLOW}cd $APP_DIR && pm2 start src/server.js --name semesta-api${NC}"
echo "   ${YELLOW}pm2 save${NC}"
echo "   ${YELLOW}pm2 startup${NC} (run the command it outputs)"
echo ""
echo "9. Test your API:"
echo "   ${YELLOW}curl http://localhost:5000/api/health${NC}"
echo ""
echo "10. (Optional) Set up SSL:"
echo "    ${YELLOW}sudo apt install certbot python3-certbot-nginx${NC}"
echo "    ${YELLOW}sudo certbot --nginx -d your-domain.com${NC}"
echo ""
echo -e "${GREEN}========================================${NC}"
echo ""
echo "For detailed instructions, see: VPS_DEPLOYMENT_GUIDE.md"
echo "For checklist, see: DEPLOYMENT_CHECKLIST.md"
echo ""
