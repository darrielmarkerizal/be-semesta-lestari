# Database & Seeder Update Guide for VPS

This guide explains how to update your database schema and seed data on your production VPS server.

---

## Quick Reference

### Update Database Schema Only
```bash
ssh user@your-vps-ip
cd /var/www/be-semesta-lestari
node src/scripts/initDatabase.js
pm2 restart semesta-api
```

### Update Seed Data Only
```bash
ssh user@your-vps-ip
cd /var/www/be-semesta-lestari
npm run seed
pm2 restart semesta-api
```

### Full Update (Schema + Seed)
```bash
ssh user@your-vps-ip
cd /var/www/be-semesta-lestari
git pull origin main
npm install --production
node src/scripts/initDatabase.js
npm run seed
pm2 restart semesta-api
```

---

## Detailed Step-by-Step Guide

### Step 1: Backup Current Database

**ALWAYS backup before making changes!**

```bash
# SSH into your VPS
ssh user@your-vps-ip

# Create backup directory
mkdir -p ~/backups

# Backup database
mysqldump -u semesta_user -p semesta_lestari > ~/backups/backup_$(date +%Y%m%d_%H%M%S).sql

# Verify backup was created
ls -lh ~/backups/
```

**Alternative: Backup with compression**
```bash
mysqldump -u semesta_user -p semesta_lestari | gzip > ~/backups/backup_$(date +%Y%m%d_%H%M%S).sql.gz
```

---

### Step 2: Upload New Code to Server

#### Option A: Using Git (Recommended)

```bash
# Navigate to application directory
cd /var/www/be-semesta-lestari

# Check current status
git status

# Pull latest changes
git pull origin main

# If you have local changes, stash them first
git stash
git pull origin main
git stash pop
```

#### Option B: Using SCP (from local machine)

```bash
# On your LOCAL machine:
cd /path/to/your/project

# Upload specific files
scp src/scripts/initDatabase.js user@your-vps-ip:/var/www/be-semesta-lestari/src/scripts/
scp src/scripts/seedDatabase.js user@your-vps-ip:/var/www/be-semesta-lestari/src/scripts/

# Or upload entire src directory
scp -r src/ user@your-vps-ip:/var/www/be-semesta-lestari/
```

#### Option C: Using SFTP Client

Use FileZilla, WinSCP, or Cyberduck:
1. Connect to your VPS
2. Navigate to `/var/www/be-semesta-lestari`
3. Upload updated files

---

### Step 3: Install Dependencies (if needed)

```bash
cd /var/www/be-semesta-lestari

# Install/update dependencies
npm install --production

# Check for vulnerabilities
npm audit
```

---

### Step 4: Update Database Schema

#### Method 1: Full Schema Initialization (Safe - Won't Delete Data)

```bash
cd /var/www/be-semesta-lestari

# Run database initialization
node src/scripts/initDatabase.js
```

This script:
- Creates tables if they don't exist
- Adds missing columns to existing tables
- Does NOT delete existing data
- Safe to run multiple times

#### Method 2: Run Specific Migration Scripts

If you have specific migration scripts (like adding columns):

```bash
# Example: Add history subtitle column
node src/scripts/addHistorySubtitle.js

# Example: Add partners image_url column
node src/scripts/addPartnersImageUrl.js

# Example: Cleanup duplicates
node src/scripts/cleanupHistorySectionDuplicates.js
```

#### Method 3: Manual SQL Updates

For custom changes:

```bash
# Login to MySQL
mysql -u semesta_user -p semesta_lestari

# Run your SQL commands
ALTER TABLE users ADD COLUMN new_field VARCHAR(255);

# Exit
EXIT;
```

---

### Step 5: Update Seed Data

#### Option 1: Full Reseed (Careful - May Overwrite Data)

```bash
cd /var/www/be-semesta-lestari

# Run seeder
npm run seed
```

**Warning**: This may overwrite existing data. Check `seedDatabase.js` to see what it does.

#### Option 2: Selective Seeding

Edit `src/scripts/seedDatabase.js` to only seed specific tables:

```bash
# Edit the seeder
nano src/scripts/seedDatabase.js

# Comment out sections you don't want to reseed
# For example, comment out user seeding if you have real users

# Run the modified seeder
npm run seed
```

#### Option 3: Manual Data Insert

```bash
# Login to MySQL
mysql -u semesta_user -p semesta_lestari

# Insert specific data
INSERT INTO leadership_section (title, subtitle, image_url, is_active) 
VALUES ('Our Leadership', 'Meet the team', '/uploads/leadership.jpg', 1);

# Exit
EXIT;
```

---

### Step 6: Verify Database Changes

```bash
# Login to MySQL
mysql -u semesta_user -p semesta_lestari

# Check table structure
DESCRIBE users;
DESCRIBE leadership_section;
DESCRIBE history;

# Check data
SELECT * FROM leadership_section;
SELECT * FROM users LIMIT 5;

# Exit
EXIT;
```

---

### Step 7: Restart Application

```bash
# Restart the application
pm2 restart semesta-api

# Check status
pm2 status

# Monitor logs for errors
pm2 logs semesta-api --lines 50

# If everything looks good, save PM2 state
pm2 save
```

---

### Step 8: Test the API

```bash
# Test health endpoint
curl http://localhost:5000/api/health

# Test a specific endpoint (example: leadership)
curl http://localhost:5000/api/about/leadership

# Test admin login
curl -X POST http://localhost:5000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@semestalestari.com",
    "password": "admin123"
  }'
```

---

## Common Scenarios

### Scenario 1: Adding a New Table

```bash
# 1. Backup database
mysqldump -u semesta_user -p semesta_lestari > ~/backups/backup_before_new_table.sql

# 2. Upload updated initDatabase.js
# (use git pull or scp)

# 3. Run initialization
cd /var/www/be-semesta-lestari
node src/scripts/initDatabase.js

# 4. Verify table was created
mysql -u semesta_user -p semesta_lestari -e "SHOW TABLES;"

# 5. Restart app
pm2 restart semesta-api
```

### Scenario 2: Adding a Column to Existing Table

```bash
# 1. Backup database
mysqldump -u semesta_user -p semesta_lestari > ~/backups/backup_before_column.sql

# 2. Create migration script (example: addNewColumn.js)
cd /var/www/be-semesta-lestari
nano src/scripts/addNewColumn.js
```

```javascript
// src/scripts/addNewColumn.js
const db = require('../config/db');

async function addNewColumn() {
  try {
    await db.query(`
      ALTER TABLE history 
      ADD COLUMN IF NOT EXISTS subtitle VARCHAR(255) AFTER title
    `);
    console.log('✓ Column added successfully');
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    process.exit();
  }
}

addNewColumn();
```

```bash
# 3. Run migration
node src/scripts/addNewColumn.js

# 4. Restart app
pm2 restart semesta-api
```

### Scenario 3: Updating Seed Data Only

```bash
# 1. Backup database (optional for seed data)
mysqldump -u semesta_user -p semesta_lestari > ~/backups/backup_before_seed.sql

# 2. Upload updated seedDatabase.js
git pull origin main
# or use scp

# 3. Run seeder
cd /var/www/be-semesta-lestari
npm run seed

# 4. Restart app
pm2 restart semesta-api
```

### Scenario 4: Complete Database Reset (DANGEROUS)

**⚠️ WARNING: This will DELETE ALL DATA!**

```bash
# 1. BACKUP EVERYTHING
mysqldump -u semesta_user -p semesta_lestari > ~/backups/backup_full_$(date +%Y%m%d_%H%M%S).sql
tar -czf ~/backups/uploads_$(date +%Y%m%d_%H%M%S).tar.gz /var/www/be-semesta-lestari/uploads

# 2. Drop and recreate database
mysql -u semesta_user -p -e "DROP DATABASE semesta_lestari;"
mysql -u semesta_user -p -e "CREATE DATABASE semesta_lestari CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 3. Initialize schema
cd /var/www/be-semesta-lestari
node src/scripts/initDatabase.js

# 4. Seed data
npm run seed

# 5. Restart app
pm2 restart semesta-api
```

---

## Rollback Procedures

### Rollback Database Changes

```bash
# 1. Stop application
pm2 stop semesta-api

# 2. Restore from backup
mysql -u semesta_user -p semesta_lestari < ~/backups/backup_YYYYMMDD_HHMMSS.sql

# Or if compressed:
gunzip < ~/backups/backup_YYYYMMDD_HHMMSS.sql.gz | mysql -u semesta_user -p semesta_lestari

# 3. Restart application
pm2 start semesta-api
```

### Rollback Code Changes

```bash
# If using Git
cd /var/www/be-semesta-lestari
git log --oneline  # Find the commit to rollback to
git reset --hard COMMIT_HASH
pm2 restart semesta-api

# Or restore from backup
cd /var/www
rm -rf be-semesta-lestari
tar -xzf ~/backups/app_backup_YYYYMMDD.tar.gz
pm2 restart semesta-api
```

---

## Automated Update Script

Create a script for easier updates:

```bash
# Create update script
nano ~/update-semesta.sh
```

```bash
#!/bin/bash

# Configuration
APP_DIR="/var/www/be-semesta-lestari"
BACKUP_DIR="$HOME/backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo "=== Semesta Lestari Update Script ==="
echo ""

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
echo "1. Backing up database..."
mysqldump -u semesta_user -p semesta_lestari | gzip > $BACKUP_DIR/db_backup_$DATE.sql.gz
echo "✓ Database backed up to: $BACKUP_DIR/db_backup_$DATE.sql.gz"
echo ""

# Navigate to app directory
cd $APP_DIR

# Pull latest code
echo "2. Pulling latest code..."
git pull origin main
echo "✓ Code updated"
echo ""

# Install dependencies
echo "3. Installing dependencies..."
npm install --production
echo "✓ Dependencies installed"
echo ""

# Update database schema
echo "4. Updating database schema..."
node src/scripts/initDatabase.js
echo "✓ Database schema updated"
echo ""

# Optional: Run seeder (commented out by default)
# echo "5. Seeding data..."
# npm run seed
# echo "✓ Data seeded"
# echo ""

# Restart application
echo "5. Restarting application..."
pm2 restart semesta-api
echo "✓ Application restarted"
echo ""

# Show status
echo "6. Application status:"
pm2 status semesta-api
echo ""

# Show recent logs
echo "7. Recent logs:"
pm2 logs semesta-api --lines 20 --nostream
echo ""

echo "=== Update Complete ==="
echo "Backup location: $BACKUP_DIR/db_backup_$DATE.sql.gz"
```

```bash
# Make script executable
chmod +x ~/update-semesta.sh

# Run the script
~/update-semesta.sh
```

---

## Monitoring & Verification

### Check Database Status

```bash
# Check MySQL status
sudo systemctl status mysql

# Check database size
mysql -u semesta_user -p -e "
  SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
  FROM information_schema.tables
  WHERE table_schema = 'semesta_lestari'
  GROUP BY table_schema;
"

# Check table row counts
mysql -u semesta_user -p semesta_lestari -e "
  SELECT 
    table_name,
    table_rows
  FROM information_schema.tables
  WHERE table_schema = 'semesta_lestari'
  ORDER BY table_name;
"
```

### Check Application Logs

```bash
# Real-time logs
pm2 logs semesta-api

# Last 100 lines
pm2 logs semesta-api --lines 100 --nostream

# Error logs only
pm2 logs semesta-api --err

# Clear old logs
pm2 flush
```

---

## Troubleshooting

### Error: "Table already exists"

This is usually safe to ignore. The script tries to create tables that may already exist.

### Error: "Column already exists"

Safe to ignore. The migration script is trying to add a column that's already there.

### Error: "Access denied for user"

```bash
# Check database credentials in .env
cat /var/www/be-semesta-lestari/.env | grep DB_

# Test MySQL connection
mysql -u semesta_user -p semesta_lestari -e "SELECT 1;"
```

### Error: "Cannot connect to database"

```bash
# Check if MySQL is running
sudo systemctl status mysql

# Restart MySQL
sudo systemctl restart mysql

# Check MySQL error log
sudo tail -f /var/log/mysql/error.log
```

### Application won't start after update

```bash
# Check PM2 logs
pm2 logs semesta-api --lines 50

# Try restarting
pm2 restart semesta-api

# If still failing, rollback
mysql -u semesta_user -p semesta_lestari < ~/backups/backup_LATEST.sql
pm2 restart semesta-api
```

---

## Best Practices

1. **Always backup before updates**
2. **Test updates on local/staging first**
3. **Update during low-traffic periods**
4. **Monitor logs after updates**
5. **Keep backups for at least 7 days**
6. **Document custom changes**
7. **Use version control (Git)**
8. **Test API endpoints after updates**

---

## Quick Commands Reference

```bash
# Backup database
mysqldump -u semesta_user -p semesta_lestari > ~/backups/backup_$(date +%Y%m%d_%H%M%S).sql

# Restore database
mysql -u semesta_user -p semesta_lestari < ~/backups/backup_FILE.sql

# Update schema
node src/scripts/initDatabase.js

# Seed data
npm run seed

# Restart app
pm2 restart semesta-api

# View logs
pm2 logs semesta-api

# Check status
pm2 status
```

---

## Support

If you encounter issues:
1. Check PM2 logs: `pm2 logs semesta-api`
2. Check MySQL logs: `sudo tail -f /var/log/mysql/error.log`
3. Verify .env configuration
4. Test database connection
5. Rollback if necessary
