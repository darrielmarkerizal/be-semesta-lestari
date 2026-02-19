# Statistics API - Visitors by Day Implementation

## Overview
Updated the `/api/admin/statistics` endpoint to return visitor count by day for the last 7 days as an array instead of a single total count.

## Date
February 19, 2026

---

## Changes Made

### Before
```json
{
  "visitors_last_7_days": 342
}
```

### After
```json
{
  "visitors_last_7_days": [
    { "date": "2026-02-13", "count": 0 },
    { "date": "2026-02-14", "count": 0 },
    { "date": "2026-02-15", "count": 5 },
    { "date": "2026-02-16", "count": 12 },
    { "date": "2026-02-17", "count": 8 },
    { "date": "2026-02-18", "count": 15 },
    { "date": "2026-02-19", "count": 23 }
  ]
}
```

---

## Implementation Details

### Database Query
```sql
SELECT 
  DATE(updated_at) as date,
  COUNT(DISTINCT id) as count
FROM articles
WHERE updated_at >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
AND view_count > 0
GROUP BY DATE(updated_at)
ORDER BY date ASC
```

### Logic
1. Query database for articles viewed in last 7 days, grouped by date
2. Create a map of dates to counts for quick lookup
3. Generate array for all 7 days (today - 6 days to today)
4. Fill in counts from database, use 0 for days with no activity

---

## Response Structure

### visitors_last_7_days Array

Each element contains:
- **date** (string): Date in YYYY-MM-DD format
- **count** (integer): Number of articles viewed on that date

**Order:** Chronological (oldest to newest)  
**Length:** Always 7 elements (one for each day)  
**Missing days:** Filled with count: 0

---

## Usage Examples

### Display as Chart
```javascript
const stats = await fetch('/api/admin/statistics', {
  headers: { 'Authorization': `Bearer ${token}` }
}).then(r => r.json());

const chartData = {
  labels: stats.data.visitors_last_7_days.map(v => v.date),
  datasets: [{
    label: 'Daily Visitors',
    data: stats.data.visitors_last_7_days.map(v => v.count)
  }]
};

// Use with Chart.js, Recharts, etc.
```

### Calculate Total
```javascript
const total = stats.data.visitors_last_7_days
  .reduce((sum, day) => sum + day.count, 0);
console.log(`Total visitors: ${total}`);
```

### Find Peak Day
```javascript
const peakDay = stats.data.visitors_last_7_days
  .reduce((max, day) => day.count > max.count ? day : max);
console.log(`Peak: ${peakDay.date} with ${peakDay.count} visitors`);
```

### React Component Example
```jsx
function VisitorsChart({ data }) {
  return (
    <div className="visitors-chart">
      <h3>Visitors Last 7 Days</h3>
      <div className="chart-bars">
        {data.visitors_last_7_days.map(day => (
          <div key={day.date} className="bar">
            <div 
              className="bar-fill" 
              style={{ height: `${day.count * 10}px` }}
            />
            <span className="bar-label">{day.date.slice(5)}</span>
            <span className="bar-count">{day.count}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
```

---

## Full Response Example

```json
{
  "success": true,
  "message": "Statistics retrieved successfully",
  "data": {
    "total_article_views": 15420,
    "total_programs": 12,
    "total_gallery": 48,
    "total_partners": 8,
    "top_articles": [
      {
        "id": 1,
        "title": "Article Title",
        "slug": "article-slug",
        "view_count": 1250,
        "published_at": "2024-01-15T10:00:00.000Z",
        "category_name": "Environmental Conservation"
      }
    ],
    "visitors_last_7_days": [
      { "date": "2026-02-13", "count": 0 },
      { "date": "2026-02-14", "count": 0 },
      { "date": "2026-02-15", "count": 5 },
      { "date": "2026-02-16", "count": 12 },
      { "date": "2026-02-17", "count": 8 },
      { "date": "2026-02-18", "count": 15 },
      { "date": "2026-02-19", "count": 23 }
    ]
  }
}
```

---

## Visualization Ideas

### 1. Line Chart
Show trend over 7 days with line graph

### 2. Bar Chart
Display daily counts as vertical bars

### 3. Area Chart
Filled area chart showing visitor volume

### 4. Sparkline
Compact inline chart for dashboard cards

### 5. Heatmap
Color-coded calendar view

---

## Notes

### Timezone Considerations
- Dates are in YYYY-MM-DD format (ISO 8601)
- Based on server's local timezone
- Database uses DATE() function for consistent day boundaries

### What Counts as a "Visitor"
- Each unique article that was viewed counts as 1
- Based on `updated_at` timestamp (updates when view_count changes)
- Not true unique visitors (would require session tracking)
- Approximation of daily activity

### Performance
- Single database query with GROUP BY
- Efficient date range filtering
- Minimal processing in application layer
- Suitable for real-time dashboard updates

---

## Future Enhancements

### Potential Improvements
1. **True Unique Visitors**
   - Track sessions or IP addresses
   - Separate analytics table
   - More accurate visitor counting

2. **Hourly Breakdown**
   - Visitors by hour for today
   - Peak hours identification

3. **Comparison**
   - Compare with previous 7 days
   - Show growth percentage

4. **Filtering**
   - By category
   - By article
   - By author

---

## Testing

### Test Current Day
```bash
# Access an article to generate activity
curl "http://localhost:3000/api/articles/some-article"

# Check statistics
TOKEN="your_token"
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:3000/api/admin/statistics" \
  | jq '.data.visitors_last_7_days'
```

### Verify 7 Days
```bash
# Should always return exactly 7 elements
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:3000/api/admin/statistics" \
  | jq '.data.visitors_last_7_days | length'
# Expected: 7
```

---

## Conclusion

✅ **Visitors now returned as array by day**  
✅ **Always 7 days of data**  
✅ **Missing days filled with 0**  
✅ **Ready for chart visualization**  
✅ **Swagger documentation updated**  

---

**Implementation Date:** February 19, 2026  
**API Version:** 1.0.0  
**Endpoint:** `/api/admin/statistics`  
**Field:** `visitors_last_7_days` (array)
