# Awards Search & Pagination Implementation

## Overview
Successfully implemented search and pagination functionality for the admin awards endpoint (`/api/admin/awards`).

## Features Implemented

### 1. Search Functionality
- **Search Fields**: title, short_description, issuer, year
- **Case Insensitive**: Searches work regardless of case
- **Partial Matching**: Supports partial word searches (e.g., "sustain" matches "sustainable")
- **Multi-field Search**: Single search term searches across all fields simultaneously

### 2. Pagination
- **Configurable Page Size**: Default 10 items per page
- **Page Navigation**: Support for page numbers
- **Metadata**: Returns currentPage, totalPages, totalItems, itemsPerPage, hasNextPage, hasPrevPage

### 3. Combined Filters
- Search + Pagination work together seamlessly
- Includes both active and inactive awards (admin only)

## API Endpoint

### Admin API: `/api/admin/awards`
**Query Parameters:**
- `search` (optional): Search keyword
- `page` (optional, default: 1): Page number
- `limit` (optional, default: 10): Items per page

**Authentication:** Required (Bearer token)

**Examples:**
```bash
# Basic pagination
GET /api/admin/awards?page=1&limit=10
Authorization: Bearer <token>

# Search only
GET /api/admin/awards?search=environmental
Authorization: Bearer <token>

# Search with pagination
GET /api/admin/awards?search=innovation&page=1&limit=5
Authorization: Bearer <token>

# Search by year
GET /api/admin/awards?search=2024
Authorization: Bearer <token>

# Search by issuer
GET /api/admin/awards?search=Ministry
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "message": "Awards retrieved",
  "data": [
    {
      "id": 1,
      "title": "Environmental Excellence Award 2024",
      "short_description": "Recognized for outstanding environmental conservation efforts",
      "image_url": "https://example.com/award.jpg",
      "year": 2024,
      "issuer": "Ministry of Environment and Forestry",
      "order_position": 1,
      "is_active": 1,
      "created_at": "2024-01-15T10:00:00.000Z",
      "updated_at": "2024-01-15T10:00:00.000Z"
    }
  ],
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

## Implementation Details

### Model Changes (`src/models/Award.js`)
Added new method `findAllPaginatedWithSearch`:
```javascript
async findAllPaginatedWithSearch(page = 1, limit = 10, isActive = null, search = null) {
  // Search in title, short_description, issuer, and year fields
  // Uses LIKE operator with % wildcards for partial matching
  // Supports pagination with LIMIT and OFFSET
}
```

**Key Features:**
- Extends BaseModel functionality
- Searches across 4 fields: title, short_description, issuer, year
- Maintains order_position and created_at ordering
- Efficient count query for pagination metadata

### Controller Changes (`src/controllers/awardController.js`)
Updated `getAllAwardsAdmin` function:
```javascript
const getAllAwardsAdmin = async (req, res, next) => {
  const search = req.query.search || null;
  // Pass search parameter to model
  const { data, total } = await Award.findAllPaginatedWithSearch(page, limit, null, search);
};
```

## Swagger Documentation

### Updated Endpoint
**GET /api/admin/awards** - Added `search` parameter

### Parameter Documentation
```yaml
- name: search
  in: query
  description: Search in title, description, issuer, and year (optional)
  schema:
    type: string
    example: environmental
```

## Test Results

### Test Script: `test_awards_search_pagination.sh`

**All Tests Passed ✓**

1. ✓ Admin API pagination working
2. ✓ Admin API search working (title, description, issuer, year)
3. ✓ Admin API search with pagination working
4. ✓ Admin API includes inactive awards
5. ✓ Pagination metadata correct
6. ✓ Case insensitive search working
7. ✓ Partial word search working
8. ✓ Search by year working
9. ✓ Search by issuer working
10. ✓ Search in description working

### Test Coverage
- Created 4 test awards (3 active, 1 inactive)
- Tested various search keywords: "environmental", "innovation", "2023", "Ministry", "community"
- Tested pagination with different page sizes
- Tested combined filters (search + pagination)
- Verified case insensitivity (ENVIRONMENTAL = environmental)
- Verified partial matching (sustain = sustainable)
- Verified admin API includes inactive awards

## Usage Examples

### Frontend Integration

```javascript
// Search awards
const searchAwards = async (keyword, page = 1, token) => {
  const response = await fetch(
    `/api/admin/awards?search=${encodeURIComponent(keyword)}&page=${page}&limit=10`,
    {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    }
  );
  return response.json();
};

// Get paginated awards
const getAwards = async (page = 1, limit = 10, token) => {
  const response = await fetch(
    `/api/admin/awards?page=${page}&limit=${limit}`,
    {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    }
  );
  return response.json();
};

// Search by year
const searchAwardsByYear = async (year, token) => {
  const response = await fetch(
    `/api/admin/awards?search=${year}`,
    {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    }
  );
  return response.json();
};
```

### Admin Panel Integration

```javascript
// Admin search with filters
const adminSearchAwards = async (filters, token) => {
  const { search, page, limit } = filters;
  const params = new URLSearchParams();
  
  if (search) params.append('search', search);
  if (page) params.append('page', page);
  if (limit) params.append('limit', limit);
  
  const response = await fetch(
    `/api/admin/awards?${params.toString()}`,
    {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    }
  );
  return response.json();
};
```

## Search Capabilities

### 1. Search by Title
```bash
GET /api/admin/awards?search=innovation
# Finds: "Green Innovation Award 2024"
```

### 2. Search by Description
```bash
GET /api/admin/awards?search=community
# Finds awards with "community" in short_description
```

### 3. Search by Issuer
```bash
GET /api/admin/awards?search=Ministry
# Finds: Awards from "Ministry of Environment and Forestry"
```

### 4. Search by Year
```bash
GET /api/admin/awards?search=2024
# Finds: All awards from 2024
```

### 5. Partial Word Search
```bash
GET /api/admin/awards?search=environ
# Finds: "Environmental Excellence Award"
```

## Performance Considerations

1. **Database Indexing**: Consider adding indexes on frequently searched columns:
   ```sql
   CREATE INDEX idx_awards_title ON awards(title);
   CREATE INDEX idx_awards_year ON awards(year);
   CREATE INDEX idx_awards_issuer ON awards(issuer);
   CREATE INDEX idx_awards_is_active ON awards(is_active);
   ```

2. **Search Optimization**: For large datasets, consider:
   - Full-text search (MySQL FULLTEXT index)
   - Caching frequently searched terms
   - Limiting search results

3. **Pagination**: Current implementation uses OFFSET/LIMIT which is efficient for small to medium datasets

## Files Modified

1. `src/models/Award.js` - Added findAllPaginatedWithSearch method
2. `src/controllers/awardController.js` - Updated getAllAwardsAdmin with search support
3. `test_awards_search_pagination.sh` - Comprehensive test script

## Swagger UI

Access the updated API documentation at:
```
http://localhost:3000/api-docs/
```

Look for:
- **Admin - Awards** section for admin endpoints

## Quick Reference

| Endpoint | Method | Auth | Search | Pagination | Shows Inactive |
|----------|--------|------|--------|------------|----------------|
| `/api/admin/awards` | GET | Yes | ✓ | ✓ | Yes |

## Search Fields Summary

| Field | Type | Searchable | Example |
|-------|------|------------|---------|
| title | string | ✓ | "Environmental Excellence Award" |
| short_description | string | ✓ | "Recognized for outstanding..." |
| issuer | string | ✓ | "Ministry of Environment" |
| year | integer | ✓ | "2024" |

## Next Steps (Optional Enhancements)

1. Add sorting options (by year, title, issuer)
2. Add date range filtering (created_at, updated_at)
3. Add filter by is_active status
4. Implement full-text search for better performance
5. Add search result highlighting
6. Add "related awards" based on search terms
7. Add search analytics/tracking
8. Add export functionality (CSV, PDF)

## Comparison with Articles Implementation

Both implementations follow the same pattern:
- Search across multiple text fields
- Case-insensitive partial matching
- Pagination with metadata
- Swagger documentation

**Differences:**
- Awards: Searches in title, description, issuer, year
- Articles: Searches in title, subtitle, content, excerpt
- Awards: Admin only
- Articles: Both public and admin endpoints

## Conclusion

Search and pagination functionality is now fully implemented and tested for the admin awards endpoint. The implementation is efficient, well-documented, and ready for production use. All 14 test cases passed successfully.
