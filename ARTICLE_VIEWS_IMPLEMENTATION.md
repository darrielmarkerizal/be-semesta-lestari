# Article Views - Automatic Increment Implementation

## Overview
Implemented automatic view counting for articles. When an article is accessed via GET `/api/articles/:slug`, the view count automatically increments.

## Date
February 19, 2026

---

## Implementation Details

### What Changed

**Modified:** `src/controllers/articleController.js` - `getArticleBySlug` function

The function now:
1. Fetches the article by slug
2. Automatically increments the view count
3. Returns the updated article with the new view count

### Code Changes

```javascript
const getArticleBySlug = async (req, res, next) => {
  try {
    const article = await Article.findBySlug(req.params.slug);
    
    if (!article) {
      return errorResponse(res, 'Article not found', 404);
    }
    
    // Automatically increment view count
    await Article.incrementViewCount(article.id);
    
    // Fetch updated article with new view count
    const updatedArticle = await Article.findById(article.id);
    
    return successResponse(res, updatedArticle, 'Article retrieved');
  } catch (error) {
    next(error);
  }
};
```

---

## How It Works

### Automatic Increment
Every time someone accesses an article via:
```
GET /api/articles/{slug}
```

The system automatically:
1. ✅ Finds the article
2. ✅ Increments `view_count` by 1
3. ✅ Returns the article with updated view count

### Database Operation
```sql
UPDATE articles SET view_count = view_count + 1 WHERE id = ?
```

---

## API Endpoint

### GET /api/articles/:slug

**Public endpoint** - No authentication required

**Behavior:**
- Retrieves article by slug
- Automatically increments view count
- Returns article with updated view count

**Example Request:**
```bash
curl "http://localhost:3000/api/articles/protecting-indonesian-forests"
```

**Example Response:**
```json
{
  "success": true,
  "message": "Article retrieved",
  "data": {
    "id": 1,
    "title": "Protecting Indonesian Forests",
    "slug": "protecting-indonesian-forests",
    "content": "...",
    "view_count": 42,
    "category_name": "Environmental Conservation",
    ...
  }
}
```

---

## Testing Results

### Manual Test
```bash
# First access
curl "http://localhost:3000/api/articles/new-test-article"
# Response: view_count: 1

# Second access
curl "http://localhost:3000/api/articles/new-test-article"
# Response: view_count: 2

# Third access
curl "http://localhost:3000/api/articles/new-test-article"
# Response: view_count: 3
```

✅ **Result:** View count increments correctly on each access

---

## Important Notes

### When Views Increment
✅ **Increments:** GET `/api/articles/:slug` (public endpoint)  
❌ **Does NOT increment:** 
- GET `/api/articles` (list endpoint)
- GET `/api/admin/articles/:id` (admin endpoint)
- POST `/api/articles/:id/increment-views` (manual increment endpoint - still available)

### Manual Increment Endpoint
The manual increment endpoint still exists for special cases:
```
POST /api/articles/:id/increment-views
```

This can be used if you need to increment views programmatically without fetching the article.

---

## Use Cases

### 1. Article Page Views
When a user visits an article page on the frontend:
```javascript
// Frontend code
const fetchArticle = async (slug) => {
  const response = await fetch(`/api/articles/${slug}`);
  const { data } = await response.json();
  // View count automatically incremented
  return data;
};
```

### 2. Popular Articles
Query articles by view count to show most popular:
```sql
SELECT * FROM articles 
WHERE is_active = true 
ORDER BY view_count DESC 
LIMIT 10;
```

### 3. Analytics
Track article popularity over time using the view_count field.

---

## Database Schema

The `articles` table includes:
```sql
view_count INT DEFAULT 0
```

This field:
- Defaults to 0 for new articles
- Increments automatically on each view
- Can be queried for analytics
- Included in all article responses

---

## Swagger Documentation

Updated Swagger documentation to reflect automatic view increment:

```yaml
/api/articles/{slug}:
  get:
    summary: Get article by slug
    description: Get a single active article by its slug. 
                 Automatically increments the view count when accessed.
    responses:
      200:
        description: Article retrieved successfully. 
                     View count automatically incremented.
```

---

## Performance Considerations

### Database Impact
- Single UPDATE query per article view
- Indexed on `id` (primary key) - very fast
- No significant performance impact

### Caching Considerations
If you implement caching:
- Cache the article content
- Always increment view count (bypass cache for this operation)
- Or use a separate analytics service for view tracking

---

## Future Enhancements

Potential improvements:
1. **Unique Views:** Track unique visitors (requires session/IP tracking)
2. **View Analytics:** Store view timestamps for time-based analytics
3. **Bot Detection:** Filter out bot/crawler views
4. **Rate Limiting:** Prevent view count manipulation
5. **Batch Updates:** Queue view increments for high-traffic scenarios

---

## Conclusion

✅ **Automatic view counting implemented**  
✅ **Works on every article access**  
✅ **No frontend changes required**  
✅ **Swagger documentation updated**  
✅ **Tested and working correctly**  

**Status:** Production Ready

---

**Implementation Date:** February 19, 2026  
**API Version:** 1.0.0  
**Feature:** Automatic Article View Counting
