# VPS Quick Commands Reference

## SSH Connection

```bash
# Connect to VPS
ssh root@your-vps-ip
ssh username@your-vps-ip

# Copy files to VPS
scp file.txt username@your-vps-ip:/path/to/destination/

# Copy folder to VPS
scp -r folder/ username@your-vps-ip:/path/to/destination/
```

## PM2 Commands

```bash
# Start application
pm2 start src/server.js --name semesta-api

# Stop application
pm2 stop semesta-api

# Restart application
pm2 restart semesta-api

# Delete from PM2
pm2 delete semesta-api

# View logs (live)
pm2 logs semesta-api

# View last 100 lines
pm2 logs semesta-api --lines 100

# Clear logs
pm2 flush

# View status
pm2 status

# View detailed info
pm2 info semesta-api

# Monitor resources
pm2 monit

# Save PM2 configuration
pm2 save

# Setup startup script
pm2 startup
```

## Nginx Commands

```bash
# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Reload Nginx (no downtime)
sudo systemctl reload nginx

# Stop Nginx
sudo systemctl stop nginx

# Start Nginx
sudo systemctl start nginx

# Check status
sudo systemctl status nginx

# View error logs
sudo tail -f /var/log/nginx/error.log

# View access logs
sudo tail -f /var/log/nginx/access.log
```

## MySQL Commands

```bash
# Login to MySQL
mysql -u root -p
mysql -u semesta_user -p semesta_lestari

# Check MySQL status
sudo systemctl status mysql

# Restart MySQL
sudo systemctl restart mysql

# Stop MySQL
sudo systemctl stop mysql

# Start MySQL
sudo systemctl start mysql

# View MySQL logs
sudo tail -f /var/log/mysql/error.log

# Backup database
mysqldump -u semesta_user -p semesta_lestari > backup.sql

# Restore database
mysql -u semesta_user -p semesta_lestari < backup.sql
```

## Application Management

```bash
# Navigate to app directory
cd /var/www/be-semesta-lestari

# Pull latest code (if using Git)
git pull origin main

# Install dependencies
npm install --production

# Run database migrations
npm run init-db
node src/scripts/addImageUrlColumns.js

# Restart application
pm2 restart semesta-api

# View application logs
pm2 logs semesta-api
```

## File & Directory Commands

```bash
# List files
ls -la

# Change directory
cd /path/to/directory

# Create directory
mkdir directory-name
mkdir -p path/to/nested/directory

# Remove file
rm filename

# Remove directory
rm -rf directory-name

# Copy file
cp source.txt destination.txt

# Move/rename file
mv oldname.txt newname.txt

# View file content
cat filename.txt
less filename.txt
nano filename.txt

# Check disk space
df -h

# Check directory size
du -sh /var/www/be-semesta-lestari

# Find files
find /var/www -name "*.log"

# Change permissions
chmod 755 directory/
chmod 644 file.txt

# Change owner
chown user:group file.txt
chown -R user:group directory/
```

## System Commands

```bash
# Update system
sudo apt update
sudo apt upgrade -y

# Check system resources
top
htop  # (install with: sudo apt install htop)

# Check memory usage
free -h

# Check disk usage
df -h

# Check running processes
ps aux | grep node

# Kill process by PID
kill -9 PID

# Check open ports
sudo netstat -tulpn

# Check specific port
sudo netstat -tulpn | grep 5000

# Reboot system
sudo reboot

# Shutdown system
sudo shutdown -h now
```

## Firewall (UFW) Commands

```bash
# Check firewall status
sudo ufw status

# Enable firewall
sudo ufw enable

# Disable firewall
sudo ufw disable

# Allow port
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 22

# Deny port
sudo ufw deny 8080

# Delete rule
sudo ufw delete allow 80

# Reset firewall
sudo ufw reset
```

## SSL/HTTPS (Certbot) Commands

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com

# Renew certificates
sudo certbot renew

# Test renewal
sudo certbot renew --dry-run

# List certificates
sudo certbot certificates

# Delete certificate
sudo certbot delete --cert-name your-domain.com
```

## Backup & Restore

```bash
# Manual database backup
mysqldump -u semesta_user -p semesta_lestari > backup_$(date +%Y%m%d).sql

# Compress backup
gzip backup_20240219.sql

# Manual uploads backup
tar -czf uploads_backup_$(date +%Y%m%d).tar.gz /var/www/be-semesta-lestari/uploads

# Restore database
mysql -u semesta_user -p semesta_lestari < backup_20240219.sql

# Restore uploads
tar -xzf uploads_backup_20240219.tar.gz -C /var/www/be-semesta-lestari/

# Run backup script
sudo /usr/local/bin/backup-semesta.sh

# View backup files
ls -lh /backups/semesta/
```

## Logs & Monitoring

```bash
# View PM2 logs
pm2 logs semesta-api

# View Nginx error logs
sudo tail -f /var/log/nginx/error.log

# View Nginx access logs
sudo tail -f /var/log/nginx/access.log

# View system logs
sudo journalctl -xe

# View MySQL logs
sudo tail -f /var/log/mysql/error.log

# View last 100 lines of any log
tail -n 100 /path/to/logfile.log

# Follow log in real-time
tail -f /path/to/logfile.log

# Search in logs
grep "error" /var/log/nginx/error.log
```

## Testing API

```bash
# Test health endpoint
curl http://localhost:5000/api/health

# Test with domain
curl http://your-domain.com/api/health

# Test login
curl -X POST "http://localhost:5000/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@semestalestari.com", "password": "admin123"}'

# Test with token
TOKEN="your-token-here"
curl -X GET "http://localhost:5000/api/admin/homepage/vision" \
  -H "Authorization: Bearer $TOKEN"

# Upload image test
curl -X POST "http://localhost:5000/api/admin/upload/vision" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@test.jpg"
```

## Troubleshooting

```bash
# Check if application is running
pm2 status
ps aux | grep node

# Check if port is in use
sudo netstat -tulpn | grep 5000

# Check Nginx configuration
sudo nginx -t

# Check MySQL connection
mysql -u semesta_user -p semesta_lestari -e "SELECT 1"

# Check disk space
df -h

# Check memory
free -h

# Check application errors
pm2 logs semesta-api --err

# Restart everything
pm2 restart semesta-api
sudo systemctl restart nginx
sudo systemctl restart mysql

# Check environment variables
cat /var/www/be-semesta-lestari/.env

# Check file permissions
ls -la /var/www/be-semesta-lestari/uploads
```

## Cron Jobs

```bash
# Edit crontab
crontab -e

# List cron jobs
crontab -l

# Remove all cron jobs
crontab -r

# View cron logs
grep CRON /var/log/syslog

# Common cron schedule examples:
# Every day at 2 AM: 0 2 * * *
# Every hour: 0 * * * *
# Every 30 minutes: */30 * * * *
# Every Monday at 3 AM: 0 3 * * 1
```

## Git Commands (if using Git)

```bash
# Clone repository
git clone https://github.com/username/repo.git

# Pull latest changes
git pull origin main

# Check status
git status

# View commit history
git log --oneline

# Check current branch
git branch

# Switch branch
git checkout branch-name

# Discard local changes
git reset --hard HEAD
```

## Quick Fixes

```bash
# Application won't start
pm2 delete semesta-api
pm2 start src/server.js --name semesta-api
pm2 logs semesta-api

# Port already in use
sudo netstat -tulpn | grep 5000
sudo kill -9 PID

# Permission denied on uploads
sudo chown -R $USER:$USER /var/www/be-semesta-lestari/uploads
chmod 755 /var/www/be-semesta-lestari/uploads

# Nginx won't start
sudo nginx -t
sudo systemctl status nginx
sudo tail -f /var/log/nginx/error.log

# Database connection failed
sudo systemctl status mysql
mysql -u semesta_user -p semesta_lestari
cat /var/www/be-semesta-lestari/.env | grep DB_

# Out of disk space
df -h
du -sh /var/www/be-semesta-lestari/*
sudo apt clean
sudo apt autoremove
```

## Useful Aliases (add to ~/.bashrc)

```bash
# Edit ~/.bashrc
nano ~/.bashrc

# Add these lines:
alias app='cd /var/www/be-semesta-lestari'
alias logs='pm2 logs semesta-api'
alias restart='pm2 restart semesta-api'
alias status='pm2 status'
alias nginx-reload='sudo systemctl reload nginx'
alias nginx-test='sudo nginx -t'

# Apply changes
source ~/.bashrc
```

## Emergency Commands

```bash
# Stop everything
pm2 stop all
sudo systemctl stop nginx

# Start everything
pm2 start all
sudo systemctl start nginx

# Restart server
sudo reboot

# Check what's using memory
ps aux --sort=-%mem | head

# Check what's using CPU
ps aux --sort=-%cpu | head

# Kill all node processes (DANGER!)
pkill -9 node

# Clear system cache (if low on memory)
sudo sync && sudo sysctl -w vm.drop_caches=3
```

## Save This File

Save this file for quick reference when managing your VPS!

```bash
# View this file on VPS
cat VPS_QUICK_COMMANDS.md | less

# Search in this file
grep "nginx" VPS_QUICK_COMMANDS.md
```
