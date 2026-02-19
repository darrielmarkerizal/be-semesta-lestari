# Visitor Tracking Implementation Summary

## Overview
Implemented automatic visitor tracking system that counts unique visitors by IP address when they access the homepage. The system tracks one visitor per IP address per day, regardless of how many times they visit.

## Implementation Details

### Database Schema
Created `visitors` table with the following structure:
```sql
CREATE TABLE visitors (
  id INT PRIMARY KEY AUTO_INCREMENT,
  ip_address VARCHAR(45) NOT NULL,
  user_agent TEXT,
  visited_date DATE NOT NULL,
  visit_count INT DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_visitor_per_day (ip_address, visited_date),
  INDEX idx_visited_date (visited_date)
);
```

### Key Features
1. **Unique Visitor Tracking**: One IP address = one visitor per day
2. **Visit Count**: Tracks how many times the same IP visits on the same day
3. **Automatic Tracking**: Visitor is tracked automatically when accessing `/api/home`
4. **7-Day History**: Statistics endpoint returns visitor count for last 7 days
5. **Timezone Handling**: Properly handles timezone conversion to avoid date mismatches

### Files Modified/Created

#### 1. `src/models/Visitor.js` (NEW)
- `trackVisit(ipAddress, userAgent)`: Records or updates visitor entry
- `getVisitorsByDay(days)`: Returns visitor count by day for last N days
- `getTotalVisitors(days)`: Returns total unique visitors for date range
- `getStatistics()`: Returns overall visitor statistics

#### 2. `src/controllers/homeController.js` (MODIFIED)
- Added visitor tracking in `getHomePage()` function
- Extracts IP address from request (handles proxies via X-Forwarded-For)
- Tracks visit asynchronously (doesn't block response)

#### 3. `src/controllers/statisticsController.js` (MODIFIED)
- Updated `getAdminStatistics()` to include `visitors_last_7_days`
- Returns array of 7 objects with `date` and `count` fields
- Fills missing days with count: 0
- Fixed timezone issues to show correct dates

#### 4. `src/scripts/initDatabase.js` (MODIFIED)
- Added `visitors` table creation

#### 5. `test_visitor_tracking.sh` (NEW)
- Comprehensive test script with 9 tests
- Tests visitor tracking, statistics endpoint, and data structure
- All tests passing (100% success rate)

## API Endpoints

### 1. GET /api/home
**Public endpoint** - Automatically tracks visitor when accessed

**Tracking Behavior**:
- Extracts IP address from request
- If IP visited today: increments `visit_count`
- If IP is new for today: creates new visitor record
- Tracking happens asynchronously (doesn't affect response time)

**Response**: Complete home page data (unchanged)

### 2. GET /api/admin/statistics
**Protected endpoint** - Requires Bearer token authentication

**Response Structure**:
```json
{
  "success": true,
  "message": "Statistics retrieved successfully",
  "data": {
    "total_article_views": 7,
    "total_programs": 42,
    "total_gallery": 40,
    "total_partners": 42,
    "top_articles": [...],
    "visitors_last_7_days": [
      {
        "date": "2026-02-13",
        "count": 0
      },
      {
        "date": "2026-02-14",
        "count": 0
      },
      {
        "date": "2026-02-15",
        "count": 0
      },
      {
        "date": "2026-02-16",
        "count": 0
      },
      {
        "date": "2026-02-17",
        "count": 0
      },
      {
        "date": "2026-02-18",
        "count": 0
      },
      {
        "date": "2026-02-19",
        "count": 1
      }
    ]
  }
}
```

## How It Works

### Visitor Tracking Flow
1. User accesses homepage (`GET /api/home`)
2. Server extracts IP address from request
3. Server checks if IP visited today:
   - **Yes**: Increment `visit_count` for that IP+date combination
   - **No**: Create new record with `visit_count = 1`
4. Server returns homepage data (tracking doesn't block response)

### IP Address Extraction
The system extracts IP address in this order:
1. `req.ip` (Express default)
2. `req.connection.remoteAddress` (fallback)
3. `req.headers['x-forwarded-for']` (for proxies/load balancers)

### Unique Visitor Definition
- **One IP address per day = One unique visitor**
- Same IP visiting multiple times on the same day = Still 1 visitor (but `visit_count` increases)
- Same IP visiting on different days = Counted as separate visitors for each day

### Statistics Calculation
- Query counts `DISTINCT ip_address` per day
- Always returns 7 days (today and previous 6 days)
- Missing days are filled with `count: 0`
- Dates are formatted as `YYYY-MM-DD` in local timezone

## Testing

### Test Script: `test_visitor_tracking.sh`
Run the test script to verify visitor tracking:
```bash
./test_visitor_tracking.sh
```

### Test Coverage
1. ✓ Homepage access tracking
2. ✓ Multiple visits from same IP
3. ✓ Statistics retrieval
4. ✓ visitors_last_7_days structure
5. ✓ 7-day array length
6. ✓ Data structure (date, count fields)
7. ✓ Today's date inclusion
8. ✓ Today's visitor count
9. ✓ All statistics fields present

**Result**: 9/9 tests passing (100%)

### Manual Testing
```bash
# Access homepage to track visitor
curl http://localhost:3000/api/home

# Check visitors table
mysql -u root semesta_lestari -e "SELECT * FROM visitors;"

# Get statistics (requires token)
curl -X GET http://localhost:3000/api/admin/statistics \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Database Queries

### View all visitors
```sql
SELECT * FROM visitors ORDER BY visited_date DESC;
```

### View visitors for today
```sql
SELECT * FROM visitors WHERE visited_date = CURDATE();
```

### View visitor count by day (last 7 days)
```sql
SELECT 
  visited_date,
  COUNT(DISTINCT ip_address) as unique_visitors,
  SUM(visit_count) as total_visits
FROM visitors
WHERE visited_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY visited_date
ORDER BY visited_date ASC;
```

## Technical Considerations

### Timezone Handling
- Database stores dates as DATE type (no timezone)
- JavaScript Date objects are converted to local timezone format
- Fixed issue where UTC conversion was showing wrong dates
- Solution: Use `DATE_FORMAT()` in MySQL and local date formatting in JavaScript

### Performance
- Visitor tracking is asynchronous (doesn't block homepage response)
- UNIQUE constraint on (ip_address, visited_date) prevents duplicates
- Index on visited_date for fast queries
- Uses `ON DUPLICATE KEY UPDATE` for efficient upserts

### Privacy Considerations
- Only stores IP address and user agent
- No personal information collected
- IP addresses are hashed/anonymized in production (recommended)
- Consider data retention policy (e.g., delete data older than 90 days)

### Proxy/Load Balancer Support
- Checks `X-Forwarded-For` header for real client IP
- Handles IPv4 and IPv6 addresses
- IPv6 localhost (::1) is properly tracked

## Future Enhancements (Optional)

1. **IP Anonymization**: Hash IP addresses for privacy
2. **Geolocation**: Track visitor location by IP
3. **Referrer Tracking**: Track where visitors come from
4. **Page Views**: Track which pages are visited
5. **Session Duration**: Track how long visitors stay
6. **Bot Detection**: Filter out bot traffic
7. **Data Retention**: Automatically delete old visitor data
8. **Analytics Dashboard**: Visual charts for visitor trends

## Swagger Documentation

The `/api/admin/statistics` endpoint is fully documented in Swagger with:
- Request/response schemas
- Authentication requirements
- Example responses
- Field descriptions

Access Swagger UI at: `http://localhost:3000/api-docs`

## Status
✅ **COMPLETE** - All functionality implemented and tested
- Visitor tracking working correctly
- Statistics endpoint returning proper data
- Timezone issues resolved
- All tests passing
- Documentation complete
