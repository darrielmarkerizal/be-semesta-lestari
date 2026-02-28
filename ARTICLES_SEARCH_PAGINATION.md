# Articles Search & Pagination Implementation

## Overview
Successfully implemented search and pagination functionality for both public and admin articles endpoints.

## Features Implemented

### 1. Search Functionality
- **Search Fields**: title, subtitle, content, excerpt
- **Case Insensitive**: Searches work regardless of case
- **Partial Matching**: Supports partial word searches (e.g., "conser" matches "conservation")
- **Available on Both APIs**: Public (`/api/articles`) and Admin (`/api/admin/articles`)

### 2. Pagination
- **Configurable Page Size**: Default 10 items per page
- **Page Navigation**: Support for page numbers
- **Metadata**: Returns currentPage, totalPages, totalItems, itemsPerPage, hasNextPage, hasPrevPage

### 3. Combined Filters
- Search + Pagination
- Search + Category Filter + Pagination
- All filters work together seamlessly

## API Endpoints

### Public API: `/api/articles`
**Query Parameters:**
- `search` (optional): Search keyword
- `category` (optional): Category slug filter
- `page` (optional, default: 1): Page number
- `limit` (optional, default: 10): Items per page

**Examples:**
```bash
# Basic pagination
GET /api/articles?page=1&limit=10

# Search only
GET /api/articles?search=forest

# Search with pagination
GET /api/articles?search=conservation&page=1&limit=5

# Category filter with search and pagination
GET /api/articles?category=environmental-conservation&search=forest&page=1&limit=10
```

**Response:**
```json
{
  "success": true,
  "message": "Articles retrieved",
  "data": [...],
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalItems": 50,
    "itemsPerPage": 10,
    "hasNextPage": true,
    "hasPrevPage": false
  }
}
```

### Admin API: `/api/admin/articles`
**Query Parameters:**
- `search` (optional): Search keyword
- `category` (optional): Category slug filter
- `page` (optional, default: 1): Page number
- `limit` (optional, default: 10): Items per page

**Differences from Public API:**
- Includes inactive articles (is_active = 0)
- Requires authentication (Bearer token)

**Examples:**
```bash
# Basic pagination (includes inactive)
GET /api/admin/articles?page=1&limit=10
Authorization: Bearer <token>

# Search inactive articles
GET /api/admin/articles?search=sustainable
Authorization: Bearer <token>

# Search with pagination
GET /api/admin/articles?search=protection&page=1&limit=5
Authorization: Bearer <token>
```

## Implementation Details

### Model Changes (`src/models/Article.js`)
```javascript
static async findAll(page = 1, limit = 10, isActive = true, categorySlug = null, search = null) {
  // Added search parameter
  // Search in title, subtitle, content, and excerpt fields
  // Uses LIKE operator with % wildcards for partial matching
}
```

### Controller Changes (`src/controllers/articleController.js`)
```javascript
// Public endpoint
const getAllArticles = async (req, res, next) => {
  const search = req.query.search || null;
  // Pass search to model
};

// Admin endpoint
const getAllArticlesAdmin = async (req, res, next) => {
  const search = req.query.search || null;
  const categorySlug = req.query.category || null;
  // Pass search and category to model
};
```

## Swagger Documentation

### Updated Endpoints
1. **GET /api/articles** - Added `search` parameter
2. **GET /api/admin/articles** - Added `search` and `category` parameters

### Parameter Documentation
```yaml
- name: search
  in: query
  description: Search in title, subtitle, content, and excerpt (optional)
  schema:
    type: string
    example: forest conservation
```

## Test Results

### Test Script: `test_articles_search_pagination.sh`

**All Tests Passed ✓**

1. ✓ Public API pagination working
2. ✓ Public API search working (title, subtitle, content, excerpt)
3. ✓ Public API search with pagination working
4. ✓ Public API only shows active articles
5. ✓ Admin API pagination working
6. ✓ Admin API search working (includes inactive articles)
7. ✓ Admin API search with pagination working
8. ✓ Pagination metadata correct
9. ✓ Case insensitive search working
10. ✓ Partial word search working

### Test Coverage
- Created 4 test articles (3 active, 1 inactive)
- Tested various search keywords: "forest", "ocean", "protection", "conservation", "sustainable"
- Tested pagination with different page sizes
- Tested combined filters (search + pagination)
- Verified case insensitivity (FOREST = forest)
- Verified partial matching (conser = conservation)
- Verified admin API includes inactive articles
- Verified public API excludes inactive articles

## Usage Examples

### Frontend Integration

```javascript
// Search articles
const searchArticles = async (keyword, page = 1) => {
  const response = await fetch(
    `/api/articles?search=${encodeURIComponent(keyword)}&page=${page}&limit=10`
  );
  return response.json();
};

// Get paginated articles
const getArticles = async (page = 1, limit = 10) => {
  const response = await fetch(`/api/articles?page=${page}&limit=${limit}`);
  return response.json();
};

// Search with category filter
const searchByCategory = async (category, keyword, page = 1) => {
  const response = await fetch(
    `/api/articles?category=${category}&search=${encodeURIComponent(keyword)}&page=${page}`
  );
  return response.json();
};
```

### Admin Panel Integration

```javascript
// Admin search (includes inactive)
const adminSearchArticles = async (keyword, page = 1, token) => {
  const response = await fetch(
    `/api/admin/articles?search=${encodeURIComponent(keyword)}&page=${page}`,
    {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    }
  );
  return response.json();
};
```

## Performance Considerations

1. **Database Indexing**: Consider adding indexes on frequently searched columns:
   ```sql
   CREATE INDEX idx_articles_title ON articles(title);
   CREATE INDEX idx_articles_is_active ON articles(is_active);
   ```

2. **Search Optimization**: For large datasets, consider:
   - Full-text search (MySQL FULLTEXT index)
   - Elasticsearch integration
   - Caching frequently searched terms

3. **Pagination**: Current implementation uses OFFSET/LIMIT which is efficient for small to medium datasets

## Files Modified

1. `src/models/Article.js` - Added search parameter to findAll method
2. `src/controllers/articleController.js` - Updated getAllArticles and getAllArticlesAdmin with search support
3. `test_articles_search_pagination.sh` - Comprehensive test script

## Swagger UI

Access the updated API documentation at:
```
http://localhost:3000/api-docs/
```

Look for:
- **Articles** section for public endpoints
- **Admin - Articles** section for admin endpoints

## Quick Reference

| Endpoint | Method | Auth | Search | Pagination | Category Filter | Shows Inactive |
|----------|--------|------|--------|------------|-----------------|----------------|
| `/api/articles` | GET | No | ✓ | ✓ | ✓ | No |
| `/api/admin/articles` | GET | Yes | ✓ | ✓ | ✓ | Yes |

## Next Steps (Optional Enhancements)

1. Add sorting options (by date, views, title)
2. Add date range filtering
3. Add author filtering
4. Implement full-text search for better performance
5. Add search result highlighting
6. Add "related articles" based on search terms
7. Add search analytics/tracking

## Conclusion

Search and pagination functionality is now fully implemented and tested for both public and admin articles endpoints. The implementation is efficient, well-documented, and ready for production use.
