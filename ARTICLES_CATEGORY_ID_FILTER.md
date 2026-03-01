# Articles Category Filter Update - ID and Slug Support

## Overview
Updated the articles endpoint to support filtering by both category ID and category slug, providing more flexibility for frontend implementations.

## Changes Made

### 1. Article Model (`src/models/Article.js`)

**Updated Method:** `findAll(page, limit, isActive, category, search)`

**Before:**
- Only supported filtering by category slug
- Parameter name: `categorySlug`

**After:**
- Supports both category ID and slug
- Parameter name: `category` (more generic)
- Automatically detects if the value is numeric (ID) or string (slug)

**Implementation:**
```javascript
// Support both category ID and slug
if (category) {
  // Check if category is a number (ID) or string (slug)
  if (!isNaN(category)) {
    conditions.push('a.category_id = ?');
    params.push(parseInt(category));
  } else {
    conditions.push('c.slug = ?');
    params.push(category);
  }
}
```

### 2. Article Controller (`src/controllers/articleController.js`)

**Updated Endpoints:**
1. `GET /api/articles` - Public articles endpoint
2. `GET /api/admin/articles` - Admin articles endpoint

**Changes:**
- Updated parameter name from `categorySlug` to `category`
- Updated Swagger documentation to reflect both ID and slug support
- Added examples for both filtering methods

**Updated Swagger Documentation:**
```yaml
- name: category
  in: query
  description: Filter by category ID or slug (optional). Accepts both numeric ID (e.g., 1) or slug (e.g., environmental-conservation).
  schema:
    type: string
    example: 1
```

## Features

### 1. Filter by Category ID
```bash
GET /api/articles?page=1&limit=9&category=1
```

**Use Case:** When you have the category ID from a database query or API response

**Example Response:**
```json
{
  "success": true,
  "message": "Articles retrieved",
  "data": [
    {
      "id": 1,
      "title": "Forest Conservation Initiative",
      "category_id": 1,
      "category_name": "Environmental Conservation",
      "category_slug": "environmental-conservation",
      ...
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 2,
    "totalItems": 15,
    "itemsPerPage": 9,
    "hasNextPage": true,
    "hasPrevPage": false
  }
}
```

### 2. Filter by Category Slug
```bash
GET /api/articles?page=1&limit=9&category=environmental-conservation
```

**Use Case:** When you have SEO-friendly URLs or category slugs

### 3. Combined with Search
```bash
GET /api/articles?page=1&limit=9&category=1&search=forest
```

**Use Case:** Search within a specific category

### 4. With Pagination
```bash
GET /api/articles?page=2&limit=9&category=1
```

**Use Case:** Load more articles from a specific category

## API Endpoints

### Public Endpoint
```
GET /api/articles
```

**Parameters:**
- `category` (optional): Category ID (numeric) or slug (string)
- `search` (optional): Search term
- `page` (optional, default: 1): Page number
- `limit` (optional, default: 10): Items per page

**Examples:**
```bash
# Filter by category ID
curl "http://localhost:3000/api/articles?category=1&page=1&limit=9"

# Filter by category slug
curl "http://localhost:3000/api/articles?category=environmental-conservation&page=1&limit=9"

# Combine with search
curl "http://localhost:3000/api/articles?category=1&search=forest&page=1&limit=9"
```

### Admin Endpoint
```
GET /api/admin/articles
Authorization: Bearer <token>
```

**Parameters:** Same as public endpoint

**Examples:**
```bash
# Filter by category ID (admin)
curl -H "Authorization: Bearer <token>" \
  "http://localhost:3000/api/admin/articles?category=1&page=1&limit=9"

# Filter by category slug (admin)
curl -H "Authorization: Bearer <token>" \
  "http://localhost:3000/api/admin/articles?category=environmental-conservation&page=1&limit=9"
```

## Response Structure

All responses include complete category information:

```json
{
  "success": true,
  "message": "Articles retrieved",
  "data": [
    {
      "id": 1,
      "title": "Article Title",
      "subtitle": "Article Subtitle",
      "slug": "article-slug",
      "content": "Article content...",
      "excerpt": "Brief excerpt...",
      "image_url": "/uploads/articles/image.jpg",
      "author_id": 1,
      "category_id": 1,
      "category_name": "Environmental Conservation",
      "category_slug": "environmental-conservation",
      "published_at": "2024-03-15T10:00:00.000Z",
      "is_active": true,
      "view_count": 150,
      "created_at": "2024-03-01T08:00:00.000Z",
      "updated_at": "2024-03-15T10:00:00.000Z"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 2,
    "totalItems": 15,
    "itemsPerPage": 9,
    "hasNextPage": true,
    "hasPrevPage": false
  }
}
```

## Testing

### Test Script
**File:** `test_articles_category_id_filter.sh`

**Run:**
```bash
./test_articles_category_id_filter.sh
```

**Tests:**
1. ✅ Get all articles (no filter)
2. ✅ Filter by category ID = 1
3. ✅ Filter by category ID = 2
4. ✅ Get categories to find slug
5. ✅ Filter by category slug
6. ✅ Combine category filter with search
7. ✅ Pagination with category filter
8. ✅ Invalid category ID (returns empty)
9. ✅ Verify category information in response

### Manual Testing

#### Test 1: Filter by Category ID
```bash
curl "http://localhost:3000/api/articles?page=1&limit=9&category=1"
```

**Expected:** Articles from category ID 1 with pagination

#### Test 2: Filter by Category Slug
```bash
curl "http://localhost:3000/api/articles?page=1&limit=9&category=environmental-conservation"
```

**Expected:** Articles from the specified category slug

#### Test 3: Combined Filter
```bash
curl "http://localhost:3000/api/articles?page=1&limit=9&category=1&search=forest"
```

**Expected:** Articles from category 1 containing "forest" in title, subtitle, content, or excerpt

## Frontend Integration

### React/Next.js Example

```javascript
// Fetch articles by category ID
const fetchArticlesByCategory = async (categoryId, page = 1, limit = 9) => {
  const params = new URLSearchParams({
    page: page.toString(),
    limit: limit.toString(),
    category: categoryId.toString()
  });
  
  const response = await fetch(`/api/articles?${params}`);
  return response.json();
};

// Usage with category ID
const articlesData = await fetchArticlesByCategory(1, 1, 9);
console.log(`Found ${articlesData.pagination.totalItems} articles`);

// Usage with category slug
const fetchArticlesBySlug = async (categorySlug, page = 1, limit = 9) => {
  const params = new URLSearchParams({
    page: page.toString(),
    limit: limit.toString(),
    category: categorySlug
  });
  
  const response = await fetch(`/api/articles?${params}`);
  return response.json();
};

const articlesData2 = await fetchArticlesBySlug('environmental-conservation', 1, 9);
```

### Vue.js Example

```javascript
export default {
  data() {
    return {
      articles: [],
      pagination: {},
      categoryId: 1,
      currentPage: 1,
      limit: 9
    }
  },
  methods: {
    async fetchArticles() {
      const params = new URLSearchParams({
        page: this.currentPage,
        limit: this.limit,
        category: this.categoryId
      });
      
      const response = await fetch(`/api/articles?${params}`);
      const data = await response.json();
      
      this.articles = data.data;
      this.pagination = data.pagination;
    }
  },
  mounted() {
    this.fetchArticles();
  }
}
```

### Angular Example

```typescript
import { HttpClient, HttpParams } from '@angular/common/http';

export class ArticlesService {
  constructor(private http: HttpClient) {}
  
  getArticlesByCategory(categoryId: number, page: number = 1, limit: number = 9) {
    const params = new HttpParams()
      .set('page', page.toString())
      .set('limit', limit.toString())
      .set('category', categoryId.toString());
    
    return this.http.get('/api/articles', { params });
  }
  
  getArticlesBySlug(categorySlug: string, page: number = 1, limit: number = 9) {
    const params = new HttpParams()
      .set('page', page.toString())
      .set('limit', limit.toString())
      .set('category', categorySlug);
    
    return this.http.get('/api/articles', { params });
  }
}
```

## Backward Compatibility

✅ **Fully backward compatible**

- Existing code using category slugs will continue to work
- New code can use category IDs for better performance
- The API automatically detects which type is being used

**Example:**
```javascript
// Old code (still works)
fetch('/api/articles?category=environmental-conservation')

// New code (also works)
fetch('/api/articles?category=1')
```

## Performance Considerations

### Category ID vs Slug

**Filter by ID (Recommended):**
```sql
WHERE a.category_id = 1
```
- ✅ Faster (direct integer comparison)
- ✅ Uses index on category_id
- ✅ No JOIN needed for filtering

**Filter by Slug:**
```sql
WHERE c.slug = 'environmental-conservation'
```
- ⚠️ Requires JOIN with categories table
- ⚠️ String comparison (slightly slower)
- ✅ SEO-friendly URLs

**Recommendation:** Use category ID when possible for better performance, especially on high-traffic pages.

## Use Cases

### 1. Category Page
```javascript
// URL: /articles/category/environmental-conservation
// Use slug for SEO-friendly URLs
const articles = await fetch('/api/articles?category=environmental-conservation&page=1&limit=9');
```

### 2. Category Dropdown/Filter
```javascript
// User selects category from dropdown (has ID)
const articles = await fetch(`/api/articles?category=${selectedCategoryId}&page=1&limit=9`);
```

### 3. Related Articles
```javascript
// Show related articles from same category
const relatedArticles = await fetch(`/api/articles?category=${article.category_id}&limit=3`);
```

### 4. Admin Panel
```javascript
// Admin filtering by category
const articles = await fetch(
  `/api/admin/articles?category=${categoryId}&page=1&limit=10`,
  { headers: { 'Authorization': `Bearer ${token}` } }
);
```

## Files Modified

1. ✅ `src/models/Article.js`
   - Updated `findAll` method to support both ID and slug
   - Changed parameter name from `categorySlug` to `category`
   - Added automatic detection logic

2. ✅ `src/controllers/articleController.js`
   - Updated `getAllArticles` function (public endpoint)
   - Updated `getAllArticlesAdmin` function (admin endpoint)
   - Updated Swagger documentation for both endpoints

## Documentation Files

1. ✅ `test_articles_category_id_filter.sh` - Test script
2. ✅ `ARTICLES_CATEGORY_ID_FILTER.md` - This documentation

## Benefits

### For Frontend Developers
- ✅ More flexibility in implementation
- ✅ Can use IDs for performance or slugs for SEO
- ✅ No breaking changes to existing code
- ✅ Simpler API (one parameter for both)

### For Performance
- ✅ Category ID filtering is faster
- ✅ Reduces database load on high-traffic pages
- ✅ Better index utilization

### For SEO
- ✅ Still supports slug-based URLs
- ✅ Clean, readable URLs possible
- ✅ No compromise on SEO

## Conclusion

The articles endpoint now supports filtering by both category ID and slug:

- ✅ Automatic detection (ID vs slug)
- ✅ Backward compatible
- ✅ Performance optimized
- ✅ SEO-friendly
- ✅ Fully tested
- ✅ Swagger documented

**Usage:**
```bash
# By ID (faster)
GET /api/articles?page=1&limit=9&category=1

# By slug (SEO-friendly)
GET /api/articles?page=1&limit=9&category=environmental-conservation
```

Both methods work seamlessly and return the same response structure with complete category information.

