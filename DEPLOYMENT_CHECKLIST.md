# VPS Deployment Checklist

Use this checklist to ensure you don't miss any steps when deploying to your VPS.

## Pre-Deployment

- [ ] VPS server ready (Ubuntu 20.04/22.04)
- [ ] SSH access configured
- [ ] Domain name configured (optional)
- [ ] Database credentials prepared

## System Setup

- [ ] Connected to VPS via SSH
- [ ] System updated (`sudo apt update && sudo apt upgrade -y`)
- [ ] Node.js 18 installed
- [ ] MySQL installed and secured
- [ ] PM2 installed globally
- [ ] Nginx installed

## Database Setup

- [ ] MySQL root password set
- [ ] Database `semesta_lestari` created
- [ ] Database user `semesta_user` created
- [ ] User privileges granted
- [ ] Database connection tested

## Application Setup

- [ ] Application files uploaded to `/var/www/be-semesta-lestari`
- [ ] Dependencies installed (`npm install --production`)
- [ ] `.env` file created with production values
- [ ] JWT_SECRET is strong (32+ characters)
- [ ] Database credentials in `.env` are correct
- [ ] Uploads directory created (`mkdir uploads`)
- [ ] Uploads directory permissions set (`chmod 755 uploads`)

## Database Initialization

- [ ] Database tables created (`npm run init-db`)
- [ ] Image URL migration run (`node src/scripts/addImageUrlColumns.js`)
- [ ] Initial data seeded (`npm run seed`) - optional

## Application Start

- [ ] Application started with PM2 (`pm2 start src/server.js --name semesta-api`)
- [ ] PM2 configuration saved (`pm2 save`)
- [ ] PM2 startup configured (`pm2 startup`)
- [ ] Application is running (`pm2 status`)
- [ ] No errors in logs (`pm2 logs semesta-api`)

## Nginx Configuration

- [ ] Nginx config file created (`/etc/nginx/sites-available/semesta-api`)
- [ ] Config includes API proxy
- [ ] Config includes uploads serving
- [ ] Config includes api-docs proxy
- [ ] Client max body size set to 10M
- [ ] Site enabled (symlink created)
- [ ] Nginx config tested (`sudo nginx -t`)
- [ ] Nginx restarted (`sudo systemctl restart nginx`)

## Firewall Setup

- [ ] SSH port allowed (22)
- [ ] HTTP port allowed (80)
- [ ] HTTPS port allowed (443)
- [ ] Firewall enabled (`sudo ufw enable`)
- [ ] Firewall status checked (`sudo ufw status`)

## Testing

- [ ] Health check works locally (`curl http://localhost:5000/api/health`)
- [ ] Health check works externally (`curl http://your-domain.com/api/health`)
- [ ] API documentation accessible (`http://your-domain.com/api-docs`)
- [ ] Login endpoint works
- [ ] Image upload works
- [ ] Public endpoints work (`/api/home`, etc.)

## SSL/HTTPS (Recommended)

- [ ] Certbot installed
- [ ] SSL certificate obtained (`sudo certbot --nginx -d your-domain.com`)
- [ ] HTTPS redirect configured
- [ ] Auto-renewal tested (`sudo certbot renew --dry-run`)
- [ ] HTTPS endpoints tested

## Security

- [ ] Default admin password changed
- [ ] Strong JWT_SECRET set
- [ ] Database user has limited privileges (not root)
- [ ] Firewall configured
- [ ] SSL/HTTPS enabled
- [ ] Rate limiting active
- [ ] Swagger disabled in production (optional)

## Backups

- [ ] Backup script created (`/usr/local/bin/backup-semesta.sh`)
- [ ] Backup script tested
- [ ] Backup directory created (`/backups/semesta`)
- [ ] Cron job scheduled (daily at 2 AM)
- [ ] Backup retention configured (7 days)

## Monitoring

- [ ] PM2 monitoring configured
- [ ] Log rotation set up (optional)
- [ ] Uptime monitoring configured (UptimeRobot, etc.) - optional
- [ ] Error tracking configured (Sentry, etc.) - optional

## Documentation

- [ ] API base URL documented
- [ ] Admin credentials documented (securely)
- [ ] Database credentials documented (securely)
- [ ] Backup location documented
- [ ] Update procedure documented

## Post-Deployment

- [ ] All endpoints tested
- [ ] Admin panel accessible
- [ ] Image uploads working
- [ ] Database queries working
- [ ] Logs are clean (no errors)
- [ ] Performance is acceptable
- [ ] Team notified of deployment

## Quick Test Commands

```bash
# Check application status
pm2 status

# Check logs
pm2 logs semesta-api --lines 50

# Check Nginx status
sudo systemctl status nginx

# Check MySQL status
sudo systemctl status mysql

# Test health endpoint
curl http://your-domain.com/api/health

# Test login
curl -X POST "http://your-domain.com/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@semestalestari.com", "password": "admin123"}'

# Check disk space
df -h

# Check memory usage
free -h

# Check running processes
pm2 monit
```

## Emergency Contacts

- VPS Provider Support: _______________
- Domain Registrar: _______________
- Database Admin: _______________
- DevOps Contact: _______________

## Rollback Plan

If deployment fails:

1. Stop the application: `pm2 stop semesta-api`
2. Restore database backup: `mysql -u semesta_user -p semesta_lestari < backup.sql`
3. Restore previous code version
4. Restart application: `pm2 restart semesta-api`
5. Check logs: `pm2 logs semesta-api`

## Notes

Date Deployed: _______________
Deployed By: _______________
Version/Commit: _______________
Issues Encountered: _______________
_______________________________________________
_______________________________________________

## Success Criteria

✅ Application is running without errors
✅ All API endpoints are accessible
✅ Database is connected and working
✅ Images can be uploaded and served
✅ SSL/HTTPS is working (if configured)
✅ Backups are scheduled
✅ Monitoring is active
✅ Documentation is updated

---

**Deployment Status**: ⬜ Not Started | ⬜ In Progress | ⬜ Complete | ⬜ Failed

**Sign-off**: _______________  **Date**: _______________
