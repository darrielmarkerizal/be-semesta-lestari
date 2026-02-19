# Visitor Tracking - Quick Reference

## How It Works
When someone accesses the homepage (`/api/home`), their IP address is automatically tracked. One IP = one visitor per day.

## Key Endpoints

### Track Visitor (Automatic)
```bash
GET /api/home
```
No authentication required. Visitor is tracked automatically.

### Get Visitor Statistics
```bash
GET /api/admin/statistics
Authorization: Bearer {token}
```

**Response includes**:
```json
{
  "visitors_last_7_days": [
    {"date": "2026-02-13", "count": 0},
    {"date": "2026-02-14", "count": 0},
    {"date": "2026-02-15", "count": 0},
    {"date": "2026-02-16", "count": 0},
    {"date": "2026-02-17", "count": 0},
    {"date": "2026-02-18", "count": 0},
    {"date": "2026-02-19", "count": 1}
  ]
}
```

## Database Table

### visitors
```sql
id | ip_address | user_agent | visited_date | visit_count | created_at | updated_at
```

**Key Points**:
- `ip_address`: Visitor's IP (IPv4 or IPv6)
- `visited_date`: Date of visit (YYYY-MM-DD)
- `visit_count`: Number of times this IP visited on this date
- UNIQUE constraint on (ip_address, visited_date)

## Quick Queries

### View today's visitors
```sql
SELECT * FROM visitors WHERE visited_date = CURDATE();
```

### Count unique visitors today
```sql
SELECT COUNT(DISTINCT ip_address) FROM visitors WHERE visited_date = CURDATE();
```

### Last 7 days visitor count
```sql
SELECT 
  visited_date,
  COUNT(DISTINCT ip_address) as visitors
FROM visitors
WHERE visited_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY visited_date;
```

## Testing

### Run test script
```bash
./test_visitor_tracking.sh
```

### Manual test
```bash
# 1. Access homepage
curl http://localhost:3000/api/home

# 2. Login as admin
curl -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}'

# 3. Get statistics (use token from step 2)
curl http://localhost:3000/api/admin/statistics \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Important Notes

1. **One IP = One Visitor per Day**: Same IP visiting multiple times on the same day counts as 1 visitor
2. **Automatic Tracking**: No need to call any special endpoint - just access homepage
3. **Asynchronous**: Tracking doesn't slow down homepage response
4. **7-Day Window**: Statistics always show last 7 days (including today)
5. **Missing Days**: Days with no visitors show `count: 0`

## Files
- Model: `src/models/Visitor.js`
- Controller: `src/controllers/homeController.js` (tracking)
- Controller: `src/controllers/statisticsController.js` (reporting)
- Test: `test_visitor_tracking.sh`
- Docs: `VISITOR_TRACKING_SUMMARY.md`
