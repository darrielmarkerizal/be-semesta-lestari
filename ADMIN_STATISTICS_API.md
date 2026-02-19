# Admin Statistics API - Documentation

## Overview
Comprehensive statistics endpoint for admin dashboard providing key metrics including article views, content counts, top articles, and visitor analytics.

## Date
February 19, 2026

---

## Endpoint

### GET /api/admin/statistics

**Authentication:** Required (Bearer Token)  
**Method:** GET  
**Access:** Admin only

---

## Response Data

### Statistics Object

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
    "visitors_last_7_days": 342
  }
}
```

---

## Data Fields

### 1. total_article_views
- **Type:** Integer
- **Description:** Sum of all view counts from active articles
- **Query:** `SUM(view_count) FROM articles WHERE is_active = true`
- **Use Case:** Overall content engagement metric

### 2. total_programs
- **Type:** Integer
- **Description:** Total count of active programs
- **Query:** `COUNT(*) FROM programs WHERE is_active = true`
- **Use Case:** Content inventory tracking

### 3. total_gallery
- **Type:** Integer
- **Description:** Total count of active gallery items
- **Query:** `COUNT(*) FROM gallery_items WHERE is_active = true`
- **Use Case:** Media library size

### 4. total_partners
- **Type:** Integer
- **Description:** Total count of active partners
- **Query:** `COUNT(*) FROM partners WHERE is_active = true`
- **Use Case:** Partnership network size

### 5. top_articles
- **Type:** Array of Objects
- **Description:** Top 5 articles ranked by view count
- **Fields:**
  - `id` (integer) - Article ID
  - `title` (string) - Article title
  - `slug` (string) - Article slug
  - `view_count` (integer) - Number of views
  - `published_at` (datetime) - Publication date
  - `category_name` (string) - Category name
- **Query:** Ordered by `view_count DESC`, limited to 5
- **Use Case:** Popular content identification

### 6. visitors_last_7_days
- **Type:** Integer
- **Description:** Count of articles that have been viewed in the last 7 days
- **Query:** Articles with `updated_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)` and `view_count > 0`
- **Use Case:** Recent activity tracking
- **Note:** Approximation based on article updates (not unique visitors)

---

## Usage Examples

### cURL Request
```bash
# Get authentication token
TOKEN=$(curl -s -X POST "http://localhost:3000/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' \
  | jq -r '.data.accessToken')

# Get statistics
curl -X GET "http://localhost:3000/api/admin/statistics" \
  -H "Authorization: Bearer $TOKEN"
```

### JavaScript/Fetch
```javascript
const getStatistics = async () => {
  const response = await fetch('/api/admin/statistics', {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  const { data } = await response.json();
  return data;
};

// Usage
const stats = await getStatistics();
console.log(`Total Views: ${stats.total_article_views}`);
console.log(`Top Article: ${stats.top_articles[0].title}`);
```

### React Component Example
```jsx
import { useEffect, useState } from 'react';

function AdminDashboard() {
  const [stats, setStats] = useState(null);

  useEffect(() => {
    fetch('/api/admin/statistics', {
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      }
    })
      .then(res => res.json())
      .then(data => setStats(data.data));
  }, []);

  if (!stats) return <div>Loading...</div>;

  return (
    <div className="dashboard">
      <div className="stat-card">
        <h3>Total Article Views</h3>
        <p>{stats.total_article_views.toLocaleString()}</p>
      </div>
      
      <div className="stat-card">
        <h3>Active Programs</h3>
        <p>{stats.total_programs}</p>
      </div>
      
      <div className="stat-card">
        <h3>Gallery Items</h3>
        <p>{stats.total_gallery}</p>
      </div>
      
      <div className="stat-card">
        <h3>Partners</h3>
        <p>{stats.total_partners}</p>
      </div>
      
      <div className="top-articles">
        <h3>Top Articles</h3>
        <ul>
          {stats.top_articles.map(article => (
            <li key={article.id}>
              {article.title} - {article.view_count} views
            </li>
          ))}
        </ul>
      </div>
      
      <div className="stat-card">
        <h3>Active Last 7 Days</h3>
        <p>{stats.visitors_last_7_days} articles</p>
      </div>
    </div>
  );
}
```

---

## Dashboard Metrics

### Key Performance Indicators (KPIs)

1. **Content Engagement**
   - Total Article Views
   - Top 5 Articles by Views
   - Average views per article

2. **Content Inventory**
   - Total Programs
   - Total Gallery Items
   - Total Partners

3. **Recent Activity**
   - Visitors Last 7 Days
   - Trending content

---

## Use Cases

### 1. Admin Dashboard Overview
Display key metrics on the main admin dashboard for quick insights.

### 2. Content Performance Analysis
Identify which articles are most popular to inform content strategy.

### 3. Inventory Management
Track the total number of programs, gallery items, and partners.

### 4. Activity Monitoring
Monitor recent activity to understand user engagement trends.

### 5. Reporting
Generate reports for stakeholders showing platform usage and engagement.

---

## Performance Considerations

### Query Optimization
- All queries use indexed fields (id, is_active)
- Aggregation queries (SUM, COUNT) are efficient
- Top articles query limited to 5 results
- No complex joins in count queries

### Caching Recommendations
```javascript
// Cache statistics for 5 minutes
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

let cachedStats = null;
let cacheTime = 0;

const getStatistics = async () => {
  const now = Date.now();
  if (cachedStats && (now - cacheTime) < CACHE_TTL) {
    return cachedStats;
  }
  
  const stats = await fetchStatistics();
  cachedStats = stats;
  cacheTime = now;
  return stats;
};
```

---

## Security

### Authentication Required
- Endpoint requires valid Bearer token
- Only admin users can access
- Unauthorized requests return 401

### Data Privacy
- No sensitive user data exposed
- Only aggregated statistics
- No personal information included

---

## Future Enhancements

### Potential Additions
1. **Time-based Analytics**
   - Views per day/week/month
   - Growth trends
   - Comparative analytics

2. **User Analytics**
   - Unique visitors tracking
   - Session duration
   - Bounce rate

3. **Content Analytics**
   - Most shared articles
   - Average read time
   - Engagement rate

4. **Geographic Data**
   - Visitor locations
   - Regional popularity

5. **Real-time Updates**
   - WebSocket integration
   - Live dashboard updates

---

## Error Handling

### Possible Errors

**401 Unauthorized**
```json
{
  "success": false,
  "message": "Authentication required",
  "error": "No token provided"
}
```

**500 Internal Server Error**
```json
{
  "success": false,
  "message": "Failed to retrieve statistics",
  "error": "Database error"
}
```

---

## Testing

### Manual Test
```bash
# 1. Login
TOKEN=$(curl -s -X POST "http://localhost:3000/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' \
  | jq -r '.data.accessToken')

# 2. Get statistics
curl -s "http://localhost:3000/api/admin/statistics" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.'

# 3. Verify response structure
curl -s "http://localhost:3000/api/admin/statistics" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.data | keys'
# Expected: ["total_article_views", "total_programs", "total_gallery", "total_partners", "top_articles", "visitors_last_7_days"]
```

---

## Swagger Documentation

The endpoint is fully documented in Swagger UI at `/api-docs`:

- **Tag:** Admin - Statistics
- **Security:** BearerAuth required
- **Response Schema:** Fully defined with examples

---

## Conclusion

✅ **Comprehensive statistics endpoint implemented**  
✅ **All requested metrics included**  
✅ **Optimized queries for performance**  
✅ **Fully documented with Swagger**  
✅ **Authentication secured**  
✅ **Production ready**

---

**Implementation Date:** February 19, 2026  
**API Version:** 1.0.0  
**Endpoint:** `/api/admin/statistics`  
**Status:** Operational
