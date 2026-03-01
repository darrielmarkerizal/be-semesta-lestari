# Swagger API Documentation - Quick Reference

## Access Swagger UI

**URL:** `http://localhost:3000/api-docs`

**Swagger JSON:** `http://localhost:3000/api-docs/swagger.json`

## Search & Pagination Endpoints

### Public Endpoints

#### 1. Articles
```
GET /api/articles?search=forest&category=environmental-conservation&page=1&limit=10
```
- Search: title, subtitle, content, excerpt
- Filter: category (slug)
- Pagination: page, limit

#### 2. Gallery
```
GET /api/gallery?search=tree&category=events&page=1&limit=12
```
- Search: title, category_name
- Filter: category (ID or slug)
- Pagination: page, limit
- Returns: section info + items with category details

### Admin Endpoints (Requires Authentication)

#### 1. Articles
```
GET /api/admin/articles?search=conservation&page=1&limit=10
Authorization: Bearer <token>
```

#### 2. Awards
```
GET /api/admin/awards?search=environmental&page=1&limit=10
Authorization: Bearer <token>
```
- Search: title, short_description, issuer, year

#### 3. Gallery
```
GET /api/admin/gallery?search=event&category=events&page=1&limit=10
Authorization: Bearer <token>
```
- Search: title, category_name
- Filter: category (slug)

#### 4. History
```
GET /api/admin/about/history?search=foundation&page=1&limit=10
Authorization: Bearer <token>
```
- Search: title, content, year

#### 5. Leadership
```
GET /api/admin/about/leadership?search=director&page=1&limit=10
Authorization: Bearer <token>
```
- Search: name, position, bio, email

#### 6. Programs
```
GET /api/admin/programs?search=education&category_id=1&page=1&limit=10
Authorization: Bearer <token>
```
- Search: name, description, category_name
- Filter: category_id
- Note: Backward compatible with databases without category_id

#### 7. Partners
```
GET /api/admin/partners?search=foundation&page=1&limit=10
Authorization: Bearer <token>
```
- Search: name, description, website

#### 8. FAQs
```
GET /api/admin/faqs?search=donation&category=General&page=1&limit=10
Authorization: Bearer <token>
```
- Search: question, answer, category
- Filter: category
- Special: `all=true` for non-paginated results

## Common Parameters

### Search
- **Type:** string
- **Optional:** yes
- **Behavior:** Case-insensitive partial matching
- **Example:** `search=forest conservation`

### Pagination
- **page:** integer, default: 1
- **limit:** integer, default: 10
- **Example:** `page=2&limit=20`

### Category Filter
- **Type:** string or integer
- **Optional:** yes
- **Accepts:** Category ID or slug
- **Example:** `category=events` or `category=1`

## Response Structure

### Standard Paginated Response
```json
{
  "success": true,
  "message": "Items retrieved",
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

### Gallery Response (with section)
```json
{
  "success": true,
  "message": "Gallery retrieved",
  "data": {
    "section": {
      "id": 1,
      "title": "Our Gallery",
      "subtitle": "...",
      "image_url": "...",
      "is_active": true
    },
    "items": [...]
  },
  "pagination": {...}
}
```

## Authentication

### Get Access Token
```bash
curl -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@semestalestari.com",
    "password": "admin123"
  }'
```

### Use Token in Requests
```bash
curl -H "Authorization: Bearer <your_token>" \
  http://localhost:3000/api/admin/awards?search=environmental
```

## Testing with Swagger UI

1. **Open Swagger UI:** Navigate to `http://localhost:3000/api-docs`

2. **Authenticate:**
   - Click "Authorize" button (top right)
   - Enter: `Bearer <your_token>`
   - Click "Authorize" then "Close"

3. **Test Endpoint:**
   - Find the endpoint you want to test
   - Click "Try it out"
   - Fill in parameters (search, page, limit, etc.)
   - Click "Execute"
   - View response below

4. **Copy cURL Command:**
   - After executing, scroll down to "Curl" section
   - Copy the command for use in terminal or scripts

## Quick Test Commands

### Test Public Gallery with Category Filter
```bash
curl "http://localhost:3000/api/gallery?category=events&page=1&limit=12"
```

### Test Public Articles with Search
```bash
curl "http://localhost:3000/api/articles?search=forest&page=1&limit=10"
```

### Test Admin Awards with Search (requires token)
```bash
TOKEN="your_token_here"
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:3000/api/admin/awards?search=environmental&page=1&limit=10"
```

### Test Admin FAQs with All Parameter
```bash
TOKEN="your_token_here"
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:3000/api/admin/faqs?all=true"
```

## Search Fields by Endpoint

| Endpoint | Search Fields |
|----------|---------------|
| Articles | title, subtitle, content, excerpt |
| Awards | title, short_description, issuer, year |
| Gallery | title, category_name |
| History | title, content, year |
| Leadership | name, position, bio, email |
| Programs | name, description, category_name |
| Partners | name, description, website |
| FAQs | question, answer, category |

## Filter Options by Endpoint

| Endpoint | Filter Type | Filter Field |
|----------|-------------|--------------|
| Articles | Category slug | `category` |
| Gallery (public) | Category ID or slug | `category` |
| Gallery (admin) | Category slug | `category` |
| Programs | Category ID | `category_id` |
| FAQs | Category name | `category` |

## Special Features

### FAQs - All Parameter
Return all FAQs without pagination:
```
GET /api/admin/faqs?all=true
```

### Programs - Backward Compatibility
Works with databases that don't have `category_id` column:
- With column: Full category support
- Without column: Basic search and pagination only

### Gallery - Section Information
Public gallery endpoint returns section settings along with items:
```json
{
  "data": {
    "section": {...},
    "items": [...]
  }
}
```

## Error Responses

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Unauthorized",
  "data": null
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Item not found",
  "data": null
}
```

### 500 Server Error
```json
{
  "success": false,
  "message": "Error message",
  "data": null,
  "error": {...}
}
```

## Frontend Integration

### React/Next.js Example
```javascript
const fetchGallery = async (category, search, page = 1) => {
  const params = new URLSearchParams({
    page: page.toString(),
    limit: '12'
  });
  
  if (category) params.append('category', category);
  if (search) params.append('search', search);
  
  const res = await fetch(`/api/gallery?${params}`);
  return res.json();
};
```

### Admin Panel Example
```javascript
const fetchAdminAwards = async (search, page = 1) => {
  const params = new URLSearchParams({
    page: page.toString(),
    limit: '10'
  });
  
  if (search) params.append('search', search);
  
  const res = await fetch(`/api/admin/awards?${params}`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  return res.json();
};
```

## Tips

1. **Use Swagger UI for Testing:** It's the easiest way to test endpoints interactively
2. **Copy cURL Commands:** Use Swagger's generated cURL commands in your scripts
3. **Check Response Schemas:** Swagger shows expected response structure
4. **Test Authentication First:** Get a valid token before testing admin endpoints
5. **Use Pagination:** Always use pagination for large datasets
6. **Combine Filters:** You can combine search with category filters
7. **Check Total Items:** Use `pagination.totalItems` to know total results

## Documentation Files

- `SWAGGER_SEARCH_PAGINATION_UPDATE.md` - Complete documentation
- `test_swagger_search_pagination.sh` - Test script
- `SWAGGER_QUICK_REFERENCE.md` - This file

## Support

For issues or questions:
1. Check Swagger UI at `/api-docs`
2. Review test scripts in project root
3. Check controller files in `src/controllers/`
4. Review model files in `src/models/`

