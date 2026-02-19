# Gallery API Quick Reference

## Public Endpoints

### Get All Gallery Items
```bash
GET /api/gallery
```
**Query Parameters:**
- `page` (optional) - Page number, default: 1
- `limit` (optional) - Items per page, default: 10
- `category` (optional) - Filter by category slug (e.g., "events")

**Example:**
```bash
curl "http://localhost:3000/api/gallery?category=events&page=1&limit=5"
```

### Get Single Gallery Item
```bash
GET /api/gallery/:id
```

**Example:**
```bash
curl "http://localhost:3000/api/gallery/1"
```

### Get All Gallery Categories
```bash
GET /api/gallery-categories
```

**Example:**
```bash
curl "http://localhost:3000/api/gallery-categories"
```

### Get Category by Slug
```bash
GET /api/gallery-categories/:slug
```

**Example:**
```bash
curl "http://localhost:3000/api/gallery-categories/events"
```

---

## Admin Endpoints (Require Authentication)

### Gallery Items

#### Get All (Admin)
```bash
GET /api/admin/gallery
Authorization: Bearer YOUR_TOKEN
```

#### Create Gallery Item
```bash
POST /api/admin/gallery
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "title": "Gallery Item Title",
  "image_url": "https://example.com/image.jpg",
  "category_id": 1,
  "gallery_date": "2024-02-19",
  "order_position": 0,
  "is_active": true
}
```

**Required Fields:** title, image_url, gallery_date

#### Update Gallery Item
```bash
PUT /api/admin/gallery/:id
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "title": "Updated Title",
  "category_id": 2
}
```

#### Delete Gallery Item
```bash
DELETE /api/admin/gallery/:id
Authorization: Bearer YOUR_TOKEN
```

### Gallery Categories

#### Get All Categories (Admin)
```bash
GET /api/admin/gallery-categories
Authorization: Bearer YOUR_TOKEN
```

#### Create Category
```bash
POST /api/admin/gallery-categories
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "name": "Category Name",
  "slug": "category-slug",
  "description": "Category description",
  "is_active": true
}
```

**Required Fields:** name, slug

#### Update Category
```bash
PUT /api/admin/gallery-categories/:id
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "name": "Updated Name",
  "description": "Updated description"
}
```

#### Delete Category
```bash
DELETE /api/admin/gallery-categories/:id
Authorization: Bearer YOUR_TOKEN
```

**Note:** Cannot delete categories with related gallery items.

---

## Response Format

### Success Response
```json
{
  "success": true,
  "message": "Gallery items retrieved",
  "data": [...],
  "pagination": {
    "currentPage": 1,
    "totalPages": 2,
    "totalItems": 8,
    "itemsPerPage": 10,
    "hasNextPage": true,
    "hasPrevPage": false
  },
  "error": null
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "data": null,
  "error": {
    "code": "ERROR_CODE",
    "details": "Error details"
  }
}
```

---

## Gallery Item Object
```json
{
  "id": 1,
  "title": "Beach Cleanup Event 2024",
  "image_url": "https://images.unsplash.com/photo-...",
  "category_id": 1,
  "category_name": "Events",
  "category_slug": "events",
  "gallery_date": "2024-01-15",
  "order_position": 0,
  "is_active": true,
  "created_at": "2024-02-19T...",
  "updated_at": "2024-02-19T..."
}
```

## Gallery Category Object
```json
{
  "id": 1,
  "name": "Events",
  "slug": "events",
  "description": "Community events and gatherings",
  "is_active": true,
  "created_at": "2024-02-19T...",
  "updated_at": "2024-02-19T..."
}
```

---

## Available Categories

1. **Events** (slug: `events`) - Community events and gatherings
2. **Projects** (slug: `projects`) - Environmental conservation projects
3. **Community** (slug: `community`) - Community engagement activities
4. **Nature** (slug: `nature`) - Natural beauty and wildlife

---

## Authentication

Get access token:
```bash
curl -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@semestalestari.com",
    "password": "admin123"
  }'
```

Use token in requests:
```bash
curl http://localhost:3000/api/admin/gallery \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## Testing

Run unit tests:
```bash
chmod +x test_gallery_api.sh
./test_gallery_api.sh
```

**Test Coverage:** 20 tests covering all CRUD operations, authentication, pagination, filtering, and deletion protection.

---

## Swagger Documentation

Access interactive API documentation:
```
http://localhost:3000/api-docs
```

Look for these tags:
- **Gallery** - Public gallery endpoints
- **Gallery Categories** - Public category endpoints
- **Admin - Gallery** - Admin gallery management
- **Admin - Gallery Categories** - Admin category management
