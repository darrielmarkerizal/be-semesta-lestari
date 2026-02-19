# Deployment Guide - Semesta Lestari API

## 🚀 Production Deployment

### Pre-Deployment Checklist

- [ ] Change default admin credentials
- [ ] Set strong JWT_SECRET
- [ ] Configure production database
- [ ] Set NODE_ENV=production
- [ ] Disable Swagger in production (optional)
- [ ] Set up SSL/HTTPS
- [ ] Configure firewall
- [ ] Set up database backups
- [ ] Configure logging
- [ ] Set up monitoring

### Environment Variables for Production

```env
# Server Configuration
PORT=5000
NODE_ENV=production

# Database Configuration (Use production credentials)
DB_HOST=your-production-db-host
DB_USER=your-production-db-user
DB_PASSWORD=strong-production-password
DB_NAME=semesta_lestari
DB_PORT=3306

# JWT Configuration (Use strong secret)
JWT_SECRET=your-super-strong-production-jwt-secret-min-32-chars
JWT_EXPIRE=7d
JWT_REFRESH_EXPIRE=30d

# Swagger Configuration (Disable in production)
SWAGGER_ENABLED=false

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

## 📦 Deployment Options

### Option 1: VPS/Cloud Server (Recommended)

#### 1. Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js (v18 LTS)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install MySQL
sudo apt install -y mysql-server

# Install Nginx
sudo apt install -y nginx

# Install PM2 (Process Manager)
sudo npm install -g pm2
```

#### 2. Deploy Application

```bash
# Clone repository
git clone <your-repo-url>
cd be-semesta-lestari

# Install dependencies
npm install --production

# Configure environment
cp .env.example .env
nano .env  # Edit with production values

# Initialize database
npm run init-db

# Seed initial data (optional)
npm run seed

# Start with PM2
pm2 start src/server.js --name semesta-api

# Save PM2 configuration
pm2 save

# Set PM2 to start on boot
pm2 startup
```

#### 3. Configure Nginx Reverse Proxy

```nginx
# /etc/nginx/sites-available/semesta-api

server {
    listen 80;
    server_name api.senestalestari.org;

    location / {
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
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/semesta-api /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

#### 4. Set Up SSL with Let's Encrypt

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d api.senestalestari.org

# Auto-renewal is configured automatically
```

### Option 2: Docker Deployment

#### 1. Create Dockerfile

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 5000

CMD ["node", "src/server.js"]
```

#### 2. Create docker-compose.yml

```yaml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
      - DB_HOST=db
      - DB_USER=root
      - DB_PASSWORD=your_password
      - DB_NAME=semesta_lestari
      - JWT_SECRET=your-jwt-secret
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=your_password
      - MYSQL_DATABASE=semesta_lestari
    volumes:
      - mysql_data:/var/lib/mysql
    restart: unless-stopped

volumes:
  mysql_data:
```

#### 3. Deploy with Docker

```bash
# Build and start
docker-compose up -d

# Initialize database
docker-compose exec api npm run init-db

# Seed data
docker-compose exec api npm run seed

# View logs
docker-compose logs -f api
```

### Option 3: Platform as a Service (PaaS)

#### Heroku

```bash
# Install Heroku CLI
# Login to Heroku
heroku login

# Create app
heroku create semesta-api

# Add MySQL addon
heroku addons:create cleardb:ignite

# Get database URL
heroku config:get CLEARDB_DATABASE_URL

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=your-jwt-secret
heroku config:set SWAGGER_ENABLED=false

# Deploy
git push heroku main

# Initialize database
heroku run npm run init-db

# Seed data
heroku run npm run seed
```

#### Railway

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Initialize project
railway init

# Add MySQL database
railway add

# Deploy
railway up
```

## 🔒 Security Hardening

### 1. Firewall Configuration

```bash
# Allow SSH, HTTP, HTTPS
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443

# Enable firewall
sudo ufw enable
```

### 2. MySQL Security

```bash
# Run security script
sudo mysql_secure_installation

# Create dedicated database user
mysql -u root -p
CREATE USER 'semesta_user'@'localhost' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON semesta_lestari.* TO 'semesta_user'@'localhost';
FLUSH PRIVILEGES;
```

### 3. Application Security

```bash
# Change default admin password immediately
# Use strong JWT_SECRET (min 32 characters)
# Enable HTTPS only
# Set secure cookie flags
# Implement rate limiting
# Regular security updates
```

## 📊 Monitoring & Logging

### PM2 Monitoring

```bash
# View logs
pm2 logs semesta-api

# Monitor resources
pm2 monit

# View status
pm2 status
```

### Log Rotation

```bash
# Install logrotate
sudo apt install logrotate

# Configure log rotation
sudo nano /etc/logrotate.d/semesta-api
```

```
/path/to/app/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
}
```

## 🔄 Database Backups

### Automated Backup Script

```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/mysql"
DB_NAME="semesta_lestari"
DB_USER="root"
DB_PASS="your_password"

mkdir -p $BACKUP_DIR

mysqldump -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $BACKUP_DIR/backup_$DATE.sql.gz

# Keep only last 7 days
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete
```

### Schedule with Cron

```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /path/to/backup.sh
```

## 🔧 Maintenance

### Update Application

```bash
# Pull latest changes
git pull origin main

# Install dependencies
npm install --production

# Restart application
pm2 restart semesta-api
```

### Database Migrations

```bash
# Backup database first
mysqldump -u root -p semesta_lestari > backup.sql

# Run migrations
# (Add migration scripts as needed)

# Restart application
pm2 restart semesta-api
```

## 📈 Performance Optimization

### 1. Enable Gzip Compression

```nginx
# In Nginx configuration
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css application/json application/javascript;
```

### 2. Database Optimization

```sql
-- Add indexes for frequently queried fields
CREATE INDEX idx_articles_slug ON articles(slug);
CREATE INDEX idx_articles_category ON articles(category);
CREATE INDEX idx_articles_published ON articles(published_at);
```

### 3. Caching (Optional)

```bash
# Install Redis
sudo apt install redis-server

# Configure Redis caching in application
```

## 🚨 Troubleshooting

### Application Won't Start

```bash
# Check logs
pm2 logs semesta-api

# Check port availability
sudo netstat -tulpn | grep 5000

# Check environment variables
pm2 env 0
```

### Database Connection Issues

```bash
# Test MySQL connection
mysql -u root -p

# Check MySQL status
sudo systemctl status mysql

# Restart MySQL
sudo systemctl restart mysql
```

### High Memory Usage

```bash
# Check PM2 status
pm2 status

# Restart application
pm2 restart semesta-api

# Clear logs
pm2 flush
```

## 📞 Support & Monitoring

### Health Check Endpoint

```bash
# Monitor API health
curl https://api.senestalestari.org/api/health
```

### Uptime Monitoring

Use services like:
- UptimeRobot
- Pingdom
- StatusCake

### Error Tracking

Consider integrating:
- Sentry
- Rollbar
- LogRocket

## ✅ Post-Deployment Checklist

- [ ] Application is running
- [ ] Database is accessible
- [ ] SSL certificate is active
- [ ] Firewall is configured
- [ ] Backups are scheduled
- [ ] Monitoring is set up
- [ ] Logs are rotating
- [ ] Default credentials changed
- [ ] API is accessible via domain
- [ ] Health check endpoint works
- [ ] Swagger docs accessible (if enabled)
- [ ] Rate limiting is working
- [ ] Error handling is working

## 🎉 Deployment Complete!

Your Semesta Lestari API is now live in production!

**API URL**: https://api.senestalestari.org
**Health Check**: https://api.senestalestari.org/api/health
**Documentation**: https://api.senestalestari.org/api-docs (if enabled)

Remember to:
- Monitor logs regularly
- Keep dependencies updated
- Backup database regularly
- Monitor server resources
- Review security regularly
