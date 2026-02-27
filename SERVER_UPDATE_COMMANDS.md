# Server Update - Quick Commands

## 🚀 Quick Update (Most Common)

```bash
# SSH to server
ssh user@your-vps-ip

# Navigate to app
cd /var/www/be-semesta-lestari

# Backup database
mysqldump -u semesta_user -p semesta_lestari > ~/backups/backup_$(date +%Y%m%d_%H%M%S).sql

# Pull latest code
git pull origin main

# Install dependencies
npm install --production

# Update database schema
node src/scripts/initDatabase.js

# Restart app
pm2 restart semesta-api

# Check logs
pm2 logs semesta-api --lines 20
```

---

## 📦 Update Scenarios

### 1. Code Changes Only (No Database Changes)

```bash
ssh user@your-vps-ip
cd /var/www/be-semesta-lestari
git pull origin main
npm install --production
pm2 restart semesta-api
```

### 2. Database Schema Changes Only

```bash
ssh user@your-vps-ip
cd /var/www/be-semesta-lestari
mysqldump -u semesta_user -p semesta_lestari > ~/backups/backup_$(date +%Y%m%d_%H%M%S).sql
node src/scripts/initDatabase.js
pm2 restart semesta-api
```

### 3. Seed Data Update Only

```bash
ssh user@your-vps-ip
cd /var/www/be-semesta-lestari
npm run seed
pm2 restart semesta-api
```

### 4. Full Update (Code + Database + Seed)

```bash
ssh user@your-vps-ip
cd /var/www/be-semesta-lestari
mysqldump -u semesta_user -p semesta_lestari > ~/backups/backup_$(date +%Y%m%d_%H%M%S).sql
git pull origin main
npm install --production
node src/scripts/initDatabase.js
npm run seed
pm2 restart semesta-api
pm2 logs semesta-api --lines 20
```

---

## 🔧 Database Commands

### Backup Database

```bash
# Standard backup
mysqldump -u semesta_user -p semesta_lestari > ~/backups/backup_$(date +%Y%m%d_%H%M%S).sql

# Compressed backup
mysqldump -u semesta_user -p semesta_lestari | gzip > ~/backups/backup_$(date +%Y%m%d_%H%M%S).sql.gz
```

### Restore Database

```bash
# From standard backup
mysql -u semesta_user -p semesta_lestari < ~/backups/backup_FILE.sql

# From compressed backup
gunzip < ~/backups/backup_FILE.sql.gz | mysql -u semesta_user -p semesta_lestari
```

### Check Database

```bash
# Login to MySQL
mysql -u semesta_user -p semesta_lestari

# Show tables
SHOW TABLES;

# Describe table structure
DESCRIBE users;
DESCRIBE leadership_section;

# Check data
SELECT * FROM users;
SELECT * FROM leadership_section;

# Exit
EXIT;
```

---

## 🔄 PM2 Commands

```bash
# Restart app
pm2 restart semesta-api

# Stop app
pm2 stop semesta-api

# Start app
pm2 start semesta-api

# View status
pm2 status

# View logs (real-time)
pm2 logs semesta-api

# View last 50 lines
pm2 logs semesta-api --lines 50 --nostream

# Clear logs
pm2 flush

# Monitor resources
pm2 monit

# Save PM2 state
pm2 save
```

---

## 📁 File Upload Commands

### From Local Machine to Server

```bash
# Upload single file
scp local-file.js user@your-vps-ip:/var/www/be-semesta-lestari/src/scripts/

# Upload directory
scp -r src/ user@your-vps-ip:/var/www/be-semesta-lestari/

# Upload with compression
tar -czf update.tar.gz src/
scp update.tar.gz user@your-vps-ip:/tmp/
ssh user@your-vps-ip "cd /var/www/be-semesta-lestari && tar -xzf /tmp/update.tar.gz"
```

---

## 🧪 Testing Commands

```bash
# Test health endpoint
curl http://localhost:5000/api/health

# Test specific endpoint
curl http://localhost:5000/api/about/leadership

# Test admin login
curl -X POST http://localhost:5000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}'

# Test from outside (replace with your domain)
curl http://your-domain.com/api/health
```

---

## 🔍 Monitoring Commands

```bash
# Check disk space
df -h

# Check memory usage
free -h

# Check CPU usage
top

# Check app directory size
du -sh /var/www/be-semesta-lestari

# Check uploads directory size
du -sh /var/www/be-semesta-lestari/uploads

# Check MySQL status
sudo systemctl status mysql

# Check Nginx status
sudo systemctl status nginx

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

---

## 🛠️ Migration Scripts

```bash
# Run specific migration
cd /var/www/be-semesta-lestari

# Add history subtitle
node src/scripts/addHistorySubtitle.js

# Add partners image_url
node src/scripts/addPartnersImageUrl.js

# Cleanup duplicates
node src/scripts/cleanupHistorySectionDuplicates.js

# Initialize database
node src/scripts/initDatabase.js

# Seed database
npm run seed
```

---

## 🚨 Emergency Commands

### Rollback Database

```bash
# Stop app
pm2 stop semesta-api

# Restore database
mysql -u semesta_user -p semesta_lestari < ~/backups/backup_LATEST.sql

# Start app
pm2 start semesta-api
```

### Rollback Code

```bash
cd /var/www/be-semesta-lestari

# View commit history
git log --oneline

# Rollback to specific commit
git reset --hard COMMIT_HASH

# Restart app
pm2 restart semesta-api
```

### Restart Everything

```bash
# Restart MySQL
sudo systemctl restart mysql

# Restart Nginx
sudo systemctl restart nginx

# Restart app
pm2 restart semesta-api

# Check all services
sudo systemctl status mysql
sudo systemctl status nginx
pm2 status
```

---

## 📋 Pre-Update Checklist

- [ ] Backup database
- [ ] Check disk space: `df -h`
- [ ] Check current app status: `pm2 status`
- [ ] Note current commit: `git log -1`
- [ ] Test locally first
- [ ] Plan rollback strategy

---

## 📋 Post-Update Checklist

- [ ] Check PM2 status: `pm2 status`
- [ ] Check logs: `pm2 logs semesta-api --lines 50`
- [ ] Test health endpoint: `curl http://localhost:5000/api/health`
- [ ] Test key endpoints
- [ ] Monitor for 5-10 minutes
- [ ] Save PM2 state: `pm2 save`

---

## 🔐 Environment Variables

```bash
# View current .env
cat /var/www/be-semesta-lestari/.env

# Edit .env
nano /var/www/be-semesta-lestari/.env

# After editing .env, restart app
pm2 restart semesta-api
```

---

## 📞 Quick Troubleshooting

### App won't start

```bash
pm2 logs semesta-api --lines 100
pm2 restart semesta-api
```

### Database connection error

```bash
mysql -u semesta_user -p semesta_lestari -e "SELECT 1;"
sudo systemctl restart mysql
```

### Port already in use

```bash
sudo netstat -tulpn | grep 5000
pm2 restart semesta-api
```

### Out of disk space

```bash
df -h
pm2 flush  # Clear PM2 logs
sudo journalctl --vacuum-time=7d  # Clear system logs
```

---

## 📚 Useful Aliases (Optional)

Add to `~/.bashrc`:

```bash
# Add these lines
alias semesta-cd='cd /var/www/be-semesta-lestari'
alias semesta-logs='pm2 logs semesta-api'
alias semesta-restart='pm2 restart semesta-api'
alias semesta-status='pm2 status semesta-api'
alias semesta-backup='mysqldump -u semesta_user -p semesta_lestari > ~/backups/backup_$(date +%Y%m%d_%H%M%S).sql'

# Reload bashrc
source ~/.bashrc
```

Then use:
```bash
semesta-cd
semesta-logs
semesta-restart
semesta-status
semesta-backup
```

---

## 🎯 Most Common Update Flow

```bash
# 1. SSH to server
ssh user@your-vps-ip

# 2. Navigate to app
cd /var/www/be-semesta-lestari

# 3. Backup
mysqldump -u semesta_user -p semesta_lestari > ~/backups/backup_$(date +%Y%m%d_%H%M%S).sql

# 4. Update code
git pull origin main

# 5. Install dependencies
npm install --production

# 6. Update database
node src/scripts/initDatabase.js

# 7. Restart
pm2 restart semesta-api

# 8. Verify
pm2 logs semesta-api --lines 20
curl http://localhost:5000/api/health

# Done! ✅
```

---

## 📖 Full Documentation

For detailed explanations, see:
- `DATABASE_UPDATE_GUIDE.md` - Complete database update guide
- `VPS_DEPLOYMENT_GUIDE.md` - Initial deployment guide
- `VPS_QUICK_COMMANDS.md` - General VPS commands
