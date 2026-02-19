# VPS Deployment Guide - Step by Step

## Prerequisites

- A VPS server (Ubuntu 20.04/22.04 recommended)
- Domain name (optional but recommended)
- SSH access to your VPS
- Root or sudo access

## Step 1: Connect to Your VPS

```bash
ssh root@your-vps-ip
# or
ssh your-username@your-vps-ip
```

## Step 2: Update System

```bash
sudo apt update
sudo apt upgrade -y
```

## Step 3: Install Node.js

```bash
# Install Node.js 18 LTS
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
node --version  # Should show v18.x.x
npm --version
```

## Step 4: Install MySQL

```bash
# Install MySQL Server
sudo apt install -y mysql-server

# Secure MySQL installation
sudo mysql_secure_installation
```

Follow the prompts:
- Set root password: YES (choose a strong password)
- Remove anonymous users: YES
- Disallow root login remotely: YES
- Remove test database: YES
- Reload privilege tables: YES

## Step 5: Create Database and User

```bash
# Login to MySQL
sudo mysql -u root -p

# In MySQL prompt, run these commands:
```

```sql
-- Create database
CREATE DATABASE semesta_lestari CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user (replace 'your_password' with a strong password)
CREATE USER 'semesta_user'@'localhost' IDENTIFIED BY 'your_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON semesta_lestari.* TO 'semesta_user'@'localhost';

-- Apply changes
FLUSH PRIVILEGES;

-- Exit MySQL
EXIT;
```

## Step 6: Install PM2 (Process Manager)

```bash
sudo npm install -g pm2
```

## Step 7: Install Nginx (Web Server)

```bash
sudo apt install -y nginx

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

## Step 8: Upload Your Application

### Option A: Using Git (Recommended)

```bash
# Install Git if not installed
sudo apt install -y git

# Navigate to web directory
cd /var/www

# Clone your repository
sudo git clone https://github.com/your-username/be-semesta-lestari.git
# or if you haven't pushed to GitHub yet, use Option B

# Set permissions
sudo chown -R $USER:$USER /var/www/be-semesta-lestari
```

### Option B: Using SCP (from your local machine)

```bash
# On your LOCAL machine, run:
cd /path/to/your/project
tar -czf be-semesta-lestari.tar.gz .

# Upload to VPS
scp be-semesta-lestari.tar.gz root@your-vps-ip:/var/www/

# On VPS, extract:
cd /var/www
sudo mkdir be-semesta-lestari
sudo tar -xzf be-semesta-lestari.tar.gz -C be-semesta-lestari
sudo chown -R $USER:$USER be-semesta-lestari
```

### Option C: Using SFTP Client

Use FileZilla, WinSCP, or Cyberduck to upload files to `/var/www/be-semesta-lestari`

## Step 9: Configure Application

```bash
cd /var/www/be-semesta-lestari

# Install dependencies
npm install --production

# Create .env file
nano .env
```

Add this configuration (adjust values):

```env
# Server Configuration
PORT=5000
NODE_ENV=production

# Database Configuration
DB_HOST=localhost
DB_USER=semesta_user
DB_PASSWORD=your_password
DB_NAME=semesta_lestari
DB_PORT=3306

# JWT Configuration (generate a random 32+ character string)
JWT_SECRET=your-super-secret-jwt-key-min-32-characters-long
JWT_EXPIRE=7d
JWT_REFRESH_EXPIRE=30d

# Swagger Configuration
SWAGGER_ENABLED=true

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

Save and exit (Ctrl+X, then Y, then Enter)

## Step 10: Initialize Database

```bash
# Run database initialization
npm run init-db

# Run migration for image_url columns
node src/scripts/addImageUrlColumns.js

# Seed initial data (optional)
npm run seed
```

## Step 11: Create Uploads Directory

```bash
# Create uploads directory with proper permissions
mkdir -p uploads
chmod 755 uploads
```

## Step 12: Start Application with PM2

```bash
# Start the application
pm2 start src/server.js --name semesta-api

# Save PM2 configuration
pm2 save

# Set PM2 to start on system boot
pm2 startup
# Copy and run the command that PM2 outputs

# Check status
pm2 status
pm2 logs semesta-api
```

## Step 13: Configure Nginx as Reverse Proxy

```bash
# Create Nginx configuration
sudo nano /etc/nginx/sites-available/semesta-api
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com;  # Replace with your domain or VPS IP

    # Increase upload size limit for images
    client_max_body_size 10M;

    # API endpoints
    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Serve uploaded images
    location /uploads {
        alias /var/www/be-semesta-lestari/uploads;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # API documentation
    location /api-docs {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Save and exit.

```bash
# Enable the site
sudo ln -s /etc/nginx/sites-available/semesta-api /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# If test is successful, restart Nginx
sudo systemctl restart nginx
```

## Step 14: Configure Firewall

```bash
# Allow SSH (important - don't lock yourself out!)
sudo ufw allow 22

# Allow HTTP and HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

## Step 15: Test Your API

```bash
# Test from VPS
curl http://localhost:5000/api/health

# Test from outside (replace with your domain or IP)
curl http://your-domain.com/api/health
```

You should see:
```json
{
  "success": true,
  "message": "API is healthy",
  "data": {
    "status": "OK",
    "timestamp": "..."
  }
}
```

## Step 16: Set Up SSL (HTTPS) - Optional but Recommended

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate (replace with your domain)
sudo certbot --nginx -d your-domain.com

# Follow the prompts:
# - Enter email address
# - Agree to terms
# - Choose whether to redirect HTTP to HTTPS (recommended: Yes)

# Test auto-renewal
sudo certbot renew --dry-run
```

## Step 17: Change Default Admin Password

```bash
# Login to your API
curl -X POST "http://your-domain.com/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@semestalestari.com",
    "password": "admin123"
  }'

# Use the token to change password
# (Implement password change endpoint or update directly in database)
```

## Step 18: Set Up Automated Backups

```bash
# Create backup script
sudo nano /usr/local/bin/backup-semesta.sh
```

Add this content:

```bash
#!/bin/bash

# Configuration
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/semesta"
DB_NAME="semesta_lestari"
DB_USER="semesta_user"
DB_PASS="your_password"
APP_DIR="/var/www/be-semesta-lestari"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $BACKUP_DIR/db_backup_$DATE.sql.gz

# Backup uploads folder
tar -czf $BACKUP_DIR/uploads_backup_$DATE.tar.gz -C $APP_DIR uploads

# Keep only last 7 days of backups
find $BACKUP_DIR -name "db_backup_*.sql.gz" -mtime +7 -delete
find $BACKUP_DIR -name "uploads_backup_*.tar.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
```

Save and exit.

```bash
# Make script executable
sudo chmod +x /usr/local/bin/backup-semesta.sh

# Test the script
sudo /usr/local/bin/backup-semesta.sh

# Schedule daily backups at 2 AM
sudo crontab -e

# Add this line:
0 2 * * * /usr/local/bin/backup-semesta.sh >> /var/log/semesta-backup.log 2>&1
```

## Useful PM2 Commands

```bash
# View logs
pm2 logs semesta-api

# Restart application
pm2 restart semesta-api

# Stop application
pm2 stop semesta-api

# Start application
pm2 start semesta-api

# Monitor resources
pm2 monit

# View detailed info
pm2 info semesta-api

# Clear logs
pm2 flush
```

## Updating Your Application

```bash
# Navigate to app directory
cd /var/www/be-semesta-lestari

# Pull latest changes (if using Git)
git pull origin main

# Or upload new files via SCP/SFTP

# Install new dependencies
npm install --production

# Run any new migrations
node src/scripts/addImageUrlColumns.js

# Restart application
pm2 restart semesta-api

# Check logs
pm2 logs semesta-api
```

## Troubleshooting

### Application won't start

```bash
# Check logs
pm2 logs semesta-api

# Check if port is in use
sudo netstat -tulpn | grep 5000

# Check environment variables
cat .env
```

### Database connection error

```bash
# Test MySQL connection
mysql -u semesta_user -p semesta_lestari

# Check MySQL status
sudo systemctl status mysql

# Restart MySQL
sudo systemctl restart mysql
```

### Nginx error

```bash
# Check Nginx error log
sudo tail -f /var/log/nginx/error.log

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

### Can't upload images

```bash
# Check uploads directory permissions
ls -la /var/www/be-semesta-lestari/uploads

# Fix permissions
chmod 755 /var/www/be-semesta-lestari/uploads
chown -R $USER:$USER /var/www/be-semesta-lestari/uploads
```

## Your API is Now Live! 🎉

- **API Base URL**: `http://your-domain.com/api` (or `https://` if SSL is configured)
- **Health Check**: `http://your-domain.com/api/health`
- **API Documentation**: `http://your-domain.com/api-docs`
- **Admin Login**: `POST http://your-domain.com/api/admin/auth/login`

## Next Steps

1. Test all endpoints
2. Change default admin password
3. Set up monitoring (UptimeRobot, etc.)
4. Configure domain DNS if not done
5. Set up regular backups
6. Monitor logs regularly

## Security Checklist

- [ ] Changed default admin password
- [ ] Using strong JWT_SECRET
- [ ] Firewall configured
- [ ] SSL/HTTPS enabled
- [ ] Database user has limited privileges
- [ ] Regular backups scheduled
- [ ] Logs are being monitored
- [ ] Rate limiting is active

## Support

If you encounter issues:
1. Check PM2 logs: `pm2 logs semesta-api`
2. Check Nginx logs: `sudo tail -f /var/log/nginx/error.log`
3. Check MySQL logs: `sudo tail -f /var/log/mysql/error.log`
4. Verify environment variables in `.env`
5. Ensure all services are running: `pm2 status`, `sudo systemctl status nginx`, `sudo systemctl status mysql`
