# Quick Reference - Articles & Categories API

## Public Endpoints

### Get All Categories
```bash
GET /api/categories
```

### Get Category by Slug
```bash
GET /api/categories/environmental-conservation
```

### Get All Articles (with optional category filter)
```bash
GET /api/articles
GET /api/articles?category=environmental-conservation
GET /api/articles?category=community-programs&page=1&limit=10
```

### Get Article by Slug
```bash
GET /api/articles/protecting-indonesian-forests
```

---

## Admin Endpoints (Require Bearer Token)

### Login
```bash
POST /api/admin/auth/login
Content-Type: application/json

{
  "email": "admin@semestalestari.com",
  "password": "admin123"
}
```

### Categories

#### List All Categories
```bash
GET /api/admin/categories
Authorization: Bearer <token>
```

#### Get Category by ID
```bash
GET /api/admin/categories/1
Authorization: Bearer <token>
```

#### Create Category
```bash
POST /api/admin/categories
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Environmental Conservation",
  "slug": "environmental-conservation",
  "description": "Articles about environmental conservation",
  "is_active": true
}
```

#### Update Category
```bash
PUT /api/admin/categories/1
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Updated Name",
  "description": "Updated description"
}
```

#### Delete Category
```bash
DELETE /api/admin/categories/1
Authorization: Bearer <token>
```
Note: Cannot delete if category has related articles

### Articles

#### List All Articles
```bash
GET /api/admin/articles
Authorization: Bearer <token>
```

#### Get Article by ID
```bash
GET /api/admin/articles/1
Authorization: Bearer <token>
```

#### Create Article
```bash
POST /api/admin/articles
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Article Title",
  "subtitle": "Article Subtitle",
  "content": "# Markdown Content\n\nArticle body...",
  "excerpt": "Short excerpt",
  "image_url": "https://example.com/image.jpg",
  "category_id": 1,
  "is_active": true
}
```

#### Update Article
```bash
PUT /api/admin/articles/1
Authorization: Bearer <token>
Content-Type: application/json

{
  "subtitle": "Updated Subtitle",
  "category_id": 2
}
```

#### Delete Article
```bash
DELETE /api/admin/articles/1
Authorization: Bearer <token>
```

---

## Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "data": null,
  "error": { ... }
}
```

### Paginated Response
```json
{
  "success": true,
  "message": "Items retrieved",
  "data": [ ... ],
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

---

## Article Object Structure
```json
{
  "id": 1,
  "title": "Article Title",
  "subtitle": "Article Subtitle",
  "slug": "article-title",
  "content": "Markdown content",
  "excerpt": "Short excerpt",
  "image_url": "https://...",
  "author_id": 2,
  "category_id": 1,
  "category_name": "Environmental Conservation",
  "category_slug": "environmental-conservation",
  "published_at": "2024-01-15T10:00:00.000Z",
  "is_active": 1,
  "view_count": 150,
  "created_at": "2024-01-15T09:00:00.000Z",
  "updated_at": "2024-01-15T09:00:00.000Z"
}
```

## Category Object Structure
```json
{
  "id": 1,
  "name": "Environmental Conservation",
  "slug": "environmental-conservation",
  "description": "Articles about environmental conservation",
  "is_active": 1,
  "created_at": "2024-01-15T09:00:00.000Z",
  "updated_at": "2024-01-15T09:00:00.000Z"
}
```

---

## Validation Rules

### Article
- `title`: Required (create only)
- `subtitle`: Optional, max 200 chars
- `content`: Required (create only)
- `excerpt`: Optional, max 500 chars
- `image_url`: Optional, must be valid URI
- `category_id`: Optional, must be positive integer
- `is_active`: Optional, boolean

### Category
- `name`: Required (create only)
- `slug`: Required (create only), must be unique
- `description`: Optional, max 500 chars
- `is_active`: Optional, boolean

---

## Common Errors

### 400 - Validation Failed
```json
{
  "success": false,
  "message": "Validation failed",
  "error": {
    "details": ["\"title\" is required"]
  }
}
```

### 400 - Cannot Delete Category
```json
{
  "success": false,
  "message": "Cannot delete category with related articles. Please reassign or delete the articles first."
}
```

### 401 - Unauthorized
```json
{
  "success": false,
  "message": "No token provided. Authorization header must be in format: Bearer <token>"
}
```

### 404 - Not Found
```json
{
  "success": false,
  "message": "Category not found"
}
```

---

## Default Credentials
- Email: `admin@semestalestari.com`
- Password: `admin123`

## Documentation
- Swagger UI: http://localhost:3000/api-docs
- Swagger JSON: http://localhost:3000/api-docs.json

## Server
- Base URL: http://localhost:3000
- Health Check: http://localhost:3000/api/health
