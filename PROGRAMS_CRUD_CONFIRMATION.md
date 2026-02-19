# Programs CRUD Operations - Confirmation & Documentation

## Summary
Full CRUD operations for `/api/admin/programs` are already implemented, tested, and working correctly.

## Date
February 19, 2026

---

## CRUD Operations Status

✅ **CREATE** - POST `/api/admin/programs`  
✅ **READ** - GET `/api/admin/programs` (list) and `/api/admin/programs/:id` (single)  
✅ **UPDATE** - PUT `/api/admin/programs/:id`  
✅ **DELETE** - DELETE `/api/admin/programs/:id`  

**All operations tested and working!**

---

## API Endpoints

### Public Endpoints

```
GET /api/programs        - Get all active programs
GET /api/programs/:id    - Get single program by ID
```

### Admin Endpoints (Require Authentication)

```
GET    /api/admin/programs        - Get all programs (paginated)
POST   /api/admin/programs        - Create new program
GET    /api/admin/programs/:id    - Get single program
PUT    /api/admin/programs/:id    - Update program
DELETE /api/admin/programs/:id    - Delete program
```

---

## Detailed Endpoint Documentation

### 1. Create Program

**Endpoint:** `POST /api/admin/programs`  
**Authentication:** Required (Bearer Token)

**Request Body:**
```json
{
  "name": "Environmental Education Program",
  "description": "Teaching communities about environmental conservation",
  "image_url": "https://images.unsplash.com/photo-example",
  "is_highlighted": false,
  "order_position": 1,
  "is_active": true
}
```

**Required Fields:** `name`  
**Optional Fields:** `description`, `image_url`, `is_highlighted`, `order_position`, `is_active`

**Response:**
```json
{
  "success": true,
  "message": "Program created successfully",
  "data": {
    "id": 22,
    "name": "Environmental Education Program",
    "description": "Teaching communities about environmental conservation",
    "image_url": "https://images.unsplash.com/photo-example",
    "is_highlighted": 0,
    "order_position": 1,
    "is_active": 1,
    "created_at": "2026-02-19T...",
    "updated_at": "2026-02-19T..."
  }
}
```

---

### 2. Read Programs

#### Get All Programs (Admin)
**Endpoint:** `GET /api/admin/programs`  
**Authentication:** Required

**Query Parameters:**
- `page` (optional) - Page number, default: 1
- `limit` (optional) - Items per page, default: 10

**Response:**
```json
{
  "success": true,
  "message": "Program retrieved",
  "data": [
    {
      "id": 19,
      "name": "Tree Planting Initiative",
      "description": "Planting trees across communities to combat climate change",
      "image_url": null,
      "is_highlighted": 1,
      "order_position": 1,
      "is_active": 1,
      "created_at": "2026-02-19T...",
      "updated_at": "2026-02-19T..."
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 3,
    "totalItems": 21,
    "itemsPerPage": 10,
    "hasNextPage": true,
    "hasPrevPage": false
  }
}
```

#### Get Single Program
**Endpoint:** `GET /api/admin/programs/:id`  
**Authentication:** Required

**Response:**
```json
{
  "success": true,
  "message": "Program retrieved",
  "data": {
    "id": 19,
    "name": "Tree Planting Initiative",
    "description": "Planting trees across communities to combat climate change",
    "image_url": null,
    "is_highlighted": 1,
    "order_position": 1,
    "is_active": 1,
    "created_at": "2026-02-19T...",
    "updated_at": "2026-02-19T..."
  }
}
```

---

### 3. Update Program

**Endpoint:** `PUT /api/admin/programs/:id`  
**Authentication:** Required

**Request Body (all fields optional):**
```json
{
  "name": "Updated Program Name",
  "description": "Updated description",
  "image_url": "https://new-image-url.com/image.jpg",
  "is_highlighted": true,
  "order_position": 2,
  "is_active": true
}
```

**Partial Updates Supported:** Only send fields you want to update

**Response:**
```json
{
  "success": true,
  "message": "Program updated successfully",
  "data": {
    "id": 19,
    "name": "Updated Program Name",
    "description": "Updated description",
    "image_url": "https://new-image-url.com/image.jpg",
    "is_highlighted": 1,
    "order_position": 2,
    "is_active": 1,
    "created_at": "2026-02-19T...",
    "updated_at": "2026-02-19T..."
  }
}
```

---

### 4. Delete Program

**Endpoint:** `DELETE /api/admin/programs/:id`  
**Authentication:** Required

**Response:**
```json
{
  "success": true,
  "message": "Program deleted successfully",
  "data": null
}
```

---

## Field Descriptions

### Program Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | Integer | Auto | Unique identifier |
| `name` | String | Yes | Program name |
| `description` | Text | No | Program description |
| `image_url` | String | No | URL to program image |
| `is_highlighted` | Boolean | No | Featured on homepage (default: false) |
| `order_position` | Integer | No | Display order (default: 0) |
| `is_active` | Boolean | No | Visibility status (default: true) |
| `created_at` | Timestamp | Auto | Creation timestamp |
| `updated_at` | Timestamp | Auto | Last update timestamp |

---

## Special Features

### 1. Highlighted Program
- Only one program should be highlighted at a time
- Highlighted program appears in `/api/home` response as `programs.highlighted`
- Use `is_highlighted: true` to feature a program on the homepage

### 2. Order Position
- Controls the display order of programs
- Lower numbers appear first
- Use for custom sorting

### 3. Active Status
- `is_active: true` - Program visible in public endpoints
- `is_active: false` - Program hidden from public, visible in admin

---

## Testing Results

### Test 1: Create Program ✅
```bash
POST /api/admin/programs
{
  "name": "Test Program",
  "description": "This is a test program",
  "is_highlighted": false
}
```
**Result:** Program created with ID 22

### Test 2: Read Program ✅
```bash
GET /api/admin/programs/22
```
**Result:** Retrieved program with correct data

### Test 3: Update Program ✅
```bash
PUT /api/admin/programs/22
{
  "name": "Updated Test Program",
  "is_highlighted": true
}
```
**Result:** Program updated successfully

### Test 4: Delete Program ✅
```bash
DELETE /api/admin/programs/22
```
**Result:** Program deleted successfully

---

## Usage Examples

### Create a New Program
```bash
TOKEN="your_token_here"

curl -X POST "http://localhost:3000/api/admin/programs" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Coastal Cleanup Initiative",
    "description": "Regular beach and coastal cleanup activities",
    "image_url": "https://images.unsplash.com/photo-1618477388954-7852f32655ec",
    "is_highlighted": false,
    "order_position": 3,
    "is_active": true
  }'
```

### Update Program
```bash
curl -X PUT "http://localhost:3000/api/admin/programs/19" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "is_highlighted": true
  }'
```

### Get All Programs (Paginated)
```bash
curl "http://localhost:3000/api/admin/programs?page=1&limit=5" \
  -H "Authorization: Bearer $TOKEN"
```

### Delete Program
```bash
curl -X DELETE "http://localhost:3000/api/admin/programs/22" \
  -H "Authorization: Bearer $TOKEN"
```

---

## Database Schema

```sql
CREATE TABLE programs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  image_url VARCHAR(500),
  is_highlighted BOOLEAN DEFAULT FALSE,
  order_position INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

---

## Impact on Other Endpoints

When you create, update, or delete a program via `/api/admin/programs`, it immediately affects:

1. **GET /api/programs** - Public programs list
2. **GET /api/programs/:id** - Single program view
3. **GET /api/home** - Home page programs section

All endpoints use the same `programs` table, so changes are instantly synchronized.

---

## Swagger Documentation

All endpoints are fully documented in Swagger/OpenAPI 3.0 format.

**Access:** `http://localhost:3000/api-docs`

**Tags:**
- **Programs** - Public program endpoints
- **Admin - Programs** - Admin program management

---

## Error Handling

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation error: name is required"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Program not found"
}
```

---

## Best Practices

### 1. Highlighted Programs
- Only set one program as highlighted at a time
- Before setting `is_highlighted: true`, consider un-highlighting others
- Highlighted program appears prominently on homepage

### 2. Order Position
- Use consistent numbering (1, 2, 3, etc.)
- Leave gaps for future insertions (10, 20, 30, etc.)
- Lower numbers appear first

### 3. Images
- Use high-quality images (recommended: 1200x800px)
- Use Unsplash or similar for placeholder images
- Ensure images are optimized for web

### 4. Descriptions
- Keep descriptions concise but informative
- Use markdown if needed (check frontend support)
- Include key benefits and impact

---

## Validation Rules

### Create Program
- `name`: Required, max 255 characters
- `description`: Optional, text field
- `image_url`: Optional, max 500 characters, should be valid URL
- `is_highlighted`: Optional, boolean
- `order_position`: Optional, integer
- `is_active`: Optional, boolean

### Update Program
- All fields optional
- Only provided fields are updated
- Validation same as create for provided fields

---

## Security

### Authentication
- All admin endpoints require JWT Bearer token
- Token obtained via `/api/admin/auth/login`
- Token must be included in Authorization header

### Authorization
- Only authenticated admin users can access
- Public endpoints don't require authentication
- Unauthorized requests return 401 error

---

## Conclusion

✅ Full CRUD operations implemented  
✅ All endpoints tested and working  
✅ Swagger documentation complete  
✅ Pagination support included  
✅ Partial updates supported  
✅ Synchronized with public endpoints  
✅ Production ready  

**Status:** Complete and Operational

---

## Quick Reference

```bash
# Login
curl -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}'

# Create
POST /api/admin/programs + Bearer Token

# Read All
GET /api/admin/programs + Bearer Token

# Read One
GET /api/admin/programs/:id + Bearer Token

# Update
PUT /api/admin/programs/:id + Bearer Token

# Delete
DELETE /api/admin/programs/:id + Bearer Token
```

---

**Documentation Date:** February 19, 2026  
**API Version:** 1.0.0  
**Status:** Fully Operational  
**Tests:** All Passing
