# Swagger Documentation - Search & Pagination Update

## Overview
Complete Swagger documentation update for all search and pagination features implemented across the API.

## Updated Endpoints

### 1. Articles
#### Public Endpoint: `/api/articles`
- ✅ Search parameter: title, subtitle, content, excerpt
- ✅ Category filter by slug
- ✅ Pagination (page, limit)
- ✅ Returns articles with category information

#### Admin Endpoint: `/api/admin/articles`
- ✅ Search parameter: title, subtitle, content, excerpt
- ✅ Category filter by slug
- ✅ Pagination (page, limit)
- ✅ Includes inactive articles

### 2. Awards
#### Admin Endpoint: `/api/admin/awards`
- ✅ Search parameter: title, short_description, issuer, year
- ✅ Pagination (page, limit)
- ✅ Includes inactive awards

**Parameters:**
```yaml
- name: search
  in: query
  description: Search in title, short_description, issuer, and year
  schema:
    type: string
    example: environmental award
- name: page
  in: query
  description: Page number for pagination
  schema:
    type: integer
    default: 1
- name: limit
  in: query
  description: Number of items per page
  schema:
    type: integer
    default: 10
```

### 3. Gallery
#### Public Endpoint: `/api/gallery`
- ✅ Search parameter: title, category_name
- ✅ Category filter by ID or slug
- ✅ Pagination (page, limit)
- ✅ Returns section information and items with category details

**Parameters:**
```yaml
- name: category
  in: query
  description: Filter by category ID or slug (optional)
  schema:
    type: string
    example: events
- name: search
  in: query
  description: Search in title and category name (optional)
  schema:
    type: string
    example: tree planting
- name: page
  in: query
  description: Page number for pagination
  schema:
    type: integer
    default: 1
    example: 1
- name: limit
  in: query
  description: Number of items per page
  schema:
    type: integer
    default: 10
    example: 12
```

**Response Structure:**
```json
{
  "success": true,
  "message": "Gallery retrieved",
  "data": {
    "section": {
      "id": 1,
      "title": "Our Gallery",
      "subtitle": "Explore our environmental initiatives",
      "image_url": "/uploads/gallery/hero.jpg",
      "is_active": true
    },
    "items": [
      {
        "id": 1,
        "title": "Community Tree Planting Event 2024",
        "image_url": "https://images.unsplash.com/...",
        "category_id": 1,
        "category_name": "Events",
        "category_slug": "events",
        "gallery_date": "2024-03-15",
        "order_position": 1,
        "is_active": true
      }
    ]
  },
  "pagination": {
    "currentPage": 1,
    "totalPages": 3,
    "totalItems": 26,
    "itemsPerPage": 12,
    "hasNextPage": true,
    "hasPrevPage": false
  }
}
```

#### Admin Endpoint: `/api/admin/gallery`
- ✅ Search parameter: title, category_name
- ✅ Category filter by slug
- ✅ Pagination (page, limit)
- ✅ Includes inactive items

### 4. History
#### Admin Endpoint: `/api/admin/about/history`
- ✅ Search parameter: title, content, year
- ✅ Pagination (page, limit)
- ✅ Includes inactive records

**Parameters:**
```yaml
- name: search
  in: query
  description: Search in title, content, and year (optional)
  schema:
    type: string
    example: foundation
- name: page
  in: query
  description: Page number for pagination
  schema:
    type: integer
    default: 1
- name: limit
  in: query
  description: Number of items per page
  schema:
    type: integer
    default: 10
```

### 5. Leadership
#### Admin Endpoint: `/api/admin/about/leadership`
- ✅ Search parameter: name, position, bio, email
- ✅ Pagination (page, limit)
- ✅ Includes inactive members

**Parameters:**
```yaml
- name: search
  in: query
  description: Search in name, position, bio, and email (optional)
  schema:
    type: string
    example: director
- name: page
  in: query
  description: Page number for pagination
  schema:
    type: integer
    default: 1
- name: limit
  in: query
  description: Number of items per page
  schema:
    type: integer
    default: 10
```

### 6. Programs
#### Admin Endpoint: `/api/admin/programs`
- ✅ Search parameter: name, description, category_name
- ✅ Category filter by ID
- ✅ Pagination (page, limit)
- ✅ Backward compatible (works with/without category_id column)

**Parameters:**
```yaml
- name: search
  in: query
  description: Search in name, description, and category name (optional)
  schema:
    type: string
    example: education
- name: category_id
  in: query
  description: Filter by category ID (optional, only works if category_id column exists)
  schema:
    type: integer
    example: 1
- name: page
  in: query
  description: Page number for pagination
  schema:
    type: integer
    default: 1
- name: limit
  in: query
  description: Number of items per page
  schema:
    type: integer
    default: 10
```

### 7. Partners
#### Admin Endpoint: `/api/admin/partners`
- ✅ Search parameter: name, description, website
- ✅ Pagination (page, limit)
- ✅ Includes inactive partners

**Parameters:**
```yaml
- name: search
  in: query
  description: Search in name, description, and website (optional)
  schema:
    type: string
    example: foundation
- name: page
  in: query
  description: Page number for pagination
  schema:
    type: integer
    default: 1
- name: limit
  in: query
  description: Number of items per page
  schema:
    type: integer
    default: 10
```

### 8. FAQs
#### Admin Endpoint: `/api/admin/faqs`
- ✅ Search parameter: question, answer, category
- ✅ Category filter
- ✅ Pagination (page, limit)
- ✅ Special `all=true` parameter for non-paginated results
- ✅ Includes inactive FAQs

**Parameters:**
```yaml
- name: search
  in: query
  description: Search in question, answer, and category (optional)
  schema:
    type: string
    example: donation
- name: category
  in: query
  description: Filter by category (optional)
  schema:
    type: string
    example: General
- name: page
  in: query
  description: Page number for pagination
  schema:
    type: integer
    default: 1
- name: limit
  in: query
  description: Number of items per page
  schema:
    type: integer
    default: 10
- name: all
  in: query
  description: Return all items without pagination (set to "true")
  schema:
    type: string
    example: "true"
```

## Common Response Structure

All paginated endpoints return the same response structure:

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

## Pagination Schema

The `Pagination` schema is defined in `src/utils/swagger.js`:

```javascript
Pagination: {
  type: 'object',
  properties: {
    currentPage: { type: 'integer' },
    totalPages: { type: 'integer' },
    totalItems: { type: 'integer' },
    itemsPerPage: { type: 'integer' },
    hasNextPage: { type: 'boolean' },
    hasPrevPage: { type: 'boolean' }
  }
}
```

## Search Behavior

All search implementations follow these rules:

1. **Case-insensitive**: All searches are case-insensitive
2. **Partial matching**: Uses `LIKE %search%` pattern
3. **Multiple fields**: Searches across multiple relevant fields
4. **Optional**: Search parameter is always optional
5. **Combined with filters**: Can be combined with category filters and pagination

## Testing Swagger Documentation

### Access Swagger UI
```
http://localhost:3000/api-docs
```

### Test Examples

#### 1. Test Articles Search
```bash
curl "http://localhost:3000/api/articles?search=forest&page=1&limit=10"
```

#### 2. Test Gallery with Category Filter
```bash
curl "http://localhost:3000/api/gallery?category=events&page=1&limit=12"
```

#### 3. Test Admin Awards Search (requires auth)
```bash
curl -H "Authorization: Bearer <token>" \
  "http://localhost:3000/api/admin/awards?search=environmental&page=1&limit=10"
```

#### 4. Test FAQs with All Parameter
```bash
curl -H "Authorization: Bearer <token>" \
  "http://localhost:3000/api/admin/faqs?all=true"
```

## Files Modified

1. `src/controllers/galleryController.js`
   - Updated public gallery endpoint to include search parameter
   - Enhanced response to include section information
   - Updated Swagger documentation

2. `src/controllers/articleController.js`
   - Already had complete search and pagination documentation

3. `src/controllers/awardController.js`
   - Already had complete search and pagination documentation

4. `src/controllers/programController.js`
   - Already had complete search and pagination documentation
   - Includes backward compatibility notes

5. `src/controllers/partnerController.js`
   - Already had complete search and pagination documentation

6. `src/controllers/faqController.js`
   - Already had complete search and pagination documentation
   - Includes special `all` parameter

7. `src/controllers/adminHomeController.js`
   - History endpoint: Complete search and pagination documentation
   - Leadership endpoint: Complete search and pagination documentation

## Key Features Documented

### 1. Search Functionality
- ✅ All search parameters documented with examples
- ✅ Search fields clearly specified for each endpoint
- ✅ Case-insensitive partial matching explained

### 2. Pagination
- ✅ Page and limit parameters on all endpoints
- ✅ Default values specified
- ✅ Pagination response schema referenced

### 3. Filtering
- ✅ Category filters documented where applicable
- ✅ Filter by ID or slug options explained
- ✅ Combined filter and search examples provided

### 4. Response Structures
- ✅ Complete response schemas defined
- ✅ Nested objects properly documented
- ✅ Example responses provided

### 5. Authentication
- ✅ All admin endpoints marked with BearerAuth security
- ✅ 401 Unauthorized responses documented

## Backward Compatibility

### Programs Endpoint
The programs endpoint includes special backward compatibility:

```yaml
description: |
  Get paginated programs with search and category filtering. 
  Includes both active and inactive programs. 
  Backward compatible with databases that don't have category_id column.
```

This ensures the API works on both old and new database schemas.

## Frontend Integration Examples

### React/Next.js Example
```javascript
// Fetch gallery with category filter and search
const fetchGallery = async (category, search, page = 1, limit = 12) => {
  const params = new URLSearchParams({
    page: page.toString(),
    limit: limit.toString(),
  });
  
  if (category) params.append('category', category);
  if (search) params.append('search', search);
  
  const response = await fetch(`/api/gallery?${params}`);
  return response.json();
};

// Usage
const data = await fetchGallery('events', 'tree planting', 1, 12);
console.log(`Found ${data.pagination.totalItems} items`);
```

### Admin Panel Example
```javascript
// Fetch admin awards with search
const fetchAdminAwards = async (search, page = 1, limit = 10) => {
  const params = new URLSearchParams({
    page: page.toString(),
    limit: limit.toString(),
  });
  
  if (search) params.append('search', search);
  
  const response = await fetch(`/api/admin/awards?${params}`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  return response.json();
};
```

## Conclusion

All search and pagination features are now fully documented in Swagger:

- ✅ 8 endpoints with search functionality
- ✅ All pagination parameters documented
- ✅ Category filters documented
- ✅ Response structures defined
- ✅ Authentication requirements specified
- ✅ Example values provided
- ✅ Backward compatibility noted

The Swagger UI at `/api-docs` now provides complete, interactive documentation for all search and pagination features, making it easy for frontend developers to integrate with the API.

## Next Steps

1. Access Swagger UI: `http://localhost:3000/api-docs`
2. Test each endpoint using the "Try it out" feature
3. Verify all parameters work as documented
4. Share API documentation with frontend team
5. Update any API client libraries or SDKs

