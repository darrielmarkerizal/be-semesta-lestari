# Complete Articles & Categories Update

## Overview
Comprehensive update to the Semesta Lestari API adding full category management system with article categorization, including database schema changes, API endpoints, validation, Swagger documentation, and deletion protection.

## Date
February 19, 2026

---

## 1. Database Changes

### New Table: Categories
```sql
CREATE TABLE categories (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Updated Table: Articles
Added new columns:
- `subtitle VARCHAR(200)` - Optional subtitle for articles
- `category_id INT` - Foreign key to categories table (nullable)

```sql
ALTER TABLE articles 
  ADD COLUMN subtitle VARCHAR(200) AFTER title,
  ADD COLUMN category_id INT,
  ADD FOREIGN KEY (category_id) REFERENCES categories(id);
```

### Seed Data
- 4 categories created: Environmental Conservation, Community Programs, Sustainability, News & Updates
- 5 articles with full markdown content, images, subtitles, and category assignments

---

## 2. API Endpoints

### Public Endpoints

#### Categories
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/categories` | Get all active categories |
| GET | `/api/categories/{slug}` | Get category by slug |

#### Articles
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/articles` | Get articles (supports `?category=slug` filter) |
| GET | `/api/articles/{slug}` | Get article by slug |
| POST | `/api/articles/{id}/increment-views` | Increment view count |

### Admin Endpoints (Require Authentication)

#### Categories
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/categories` | Get all categories (including inactive) |
| POST | `/api/admin/categories` | Create new category |
| GET | `/api/admin/categories/{id}` | Get category by ID |
| PUT | `/api/admin/categories/{id}` | Update category |
| DELETE | `/api/admin/categories/{id}` | Delete category (protected) |

#### Articles
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/articles` | Get all articles (including inactive) |
| POST | `/api/admin/articles` | Create article with category |
| GET | `/api/admin/articles/{id}` | Get article by ID |
| PUT | `/api/admin/articles/{id}` | Update article and category |
| DELETE | `/api/admin/articles/{id}` | Delete article |

---

## 3. Features

### Category Filtering
Articles can be filtered by category using query parameter:
```
GET /api/articles?category=environmental-conservation
```
If no category specified, returns all articles.

### Category Information in Articles
All article responses include:
```json
{
  "id": 1,
  "title": "Article Title",
  "subtitle": "Article Subtitle",
  "category_id": 1,
  "category_name": "Environmental Conservation",
  "category_slug": "environmental-conservation",
  ...
}
```

### Category Deletion Protection
Categories with related articles cannot be deleted:
- Returns 400 error
- Message: "Cannot delete category with related articles. Please reassign or delete the articles first."
- Implemented via `hasRelatedArticles()` method in Category model

### Markdown Support
Article content field supports markdown formatting.

---

## 4. Validation Schemas

### Article Validation
**Create:**
- `title` (required)
- `subtitle` (optional, max 200 chars)
- `content` (required, markdown)
- `excerpt` (optional, max 500 chars)
- `image_url` (optional, URI)
- `category_id` (optional, positive integer)
- `published_at` (optional, date)
- `is_active` (optional, boolean)

**Update:**
- All fields optional
- Same validation rules

### Category Validation
**Create:**
- `name` (required)
- `slug` (required)
- `description` (optional, max 500 chars)
- `is_active` (optional, boolean)

**Update:**
- All fields optional
- Same validation rules

---

## 5. Swagger Documentation

### Schemas Added
- **Article**: Complete schema with all fields including category information
- **Category**: Complete schema with all fields

### Tags Added
- **Categories**: Public category endpoints
- **Admin - Categories**: Admin category management

### Documentation Includes
- Complete request/response examples
- Parameter descriptions
- Error responses (400, 401, 404)
- Security requirements
- Validation rules

**Access:**
- Swagger UI: http://localhost:3000/api-docs
- Swagger JSON: http://localhost:3000/api-docs.json

---

## 6. Models

### Category Model (src/models/Category.js)
Methods:
- `findAll(isActive)` - Get all categories with optional active filter
- `findById(id)` - Get category by ID
- `findBySlug(slug)` - Get category by slug
- `create(data)` - Create new category
- `update(id, data)` - Update category
- `delete(id)` - Delete category
- `hasRelatedArticles(categoryId)` - Check if category has articles

### Article Model (src/models/Article.js)
Updated methods to include category information:
- `findAll(page, limit, isActive, categorySlug)` - Supports category filtering
- `findById(id)` - Includes category info via LEFT JOIN
- `findBySlug(slug)` - Includes category info via LEFT JOIN
- `create(data, authorId)` - Supports category_id and subtitle
- `update(id, data)` - Supports category_id and subtitle updates

---

## 7. Request/Response Examples

### Create Category
**Request:**
```bash
POST /api/admin/categories
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Environmental Conservation",
  "slug": "environmental-conservation",
  "description": "Articles about environmental conservation efforts",
  "is_active": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Category created successfully",
  "data": {
    "id": 1,
    "name": "Environmental Conservation",
    "slug": "environmental-conservation",
    "description": "Articles about environmental conservation efforts",
    "is_active": 1,
    "created_at": "2026-02-19T06:02:47.000Z",
    "updated_at": "2026-02-19T06:02:47.000Z"
  }
}
```

### Create Article with Category
**Request:**
```bash
POST /api/admin/articles
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Protecting Indonesian Forests",
  "subtitle": "Our commitment to preserving biodiversity",
  "content": "# Introduction\n\nThis article discusses our forest conservation efforts...",
  "excerpt": "A brief overview of our conservation efforts",
  "image_url": "https://example.com/images/forest.jpg",
  "category_id": 1,
  "is_active": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Article created successfully",
  "data": {
    "id": 7,
    "title": "Protecting Indonesian Forests",
    "subtitle": "Our commitment to preserving biodiversity",
    "slug": "protecting-indonesian-forests",
    "content": "# Introduction\n\nThis article discusses...",
    "excerpt": "A brief overview of our conservation efforts",
    "image_url": "https://example.com/images/forest.jpg",
    "author_id": 2,
    "category_id": 1,
    "category_name": "Environmental Conservation",
    "category_slug": "environmental-conservation",
    "published_at": "2026-02-19T06:03:15.000Z",
    "is_active": 1,
    "view_count": 0,
    "created_at": "2026-02-19T06:03:15.000Z",
    "updated_at": "2026-02-19T06:03:15.000Z"
  }
}
```

### Get Articles by Category
**Request:**
```bash
GET /api/articles?category=environmental-conservation&page=1&limit=10
```

**Response:**
```json
{
  "success": true,
  "message": "Articles retrieved",
  "data": [
    {
      "id": 1,
      "title": "Protecting Indonesian Forests",
      "subtitle": "Our commitment to preserving biodiversity",
      "slug": "protecting-indonesian-forests",
      "content": "...",
      "excerpt": "...",
      "image_url": "...",
      "category_id": 1,
      "category_name": "Environmental Conservation",
      "category_slug": "environmental-conservation",
      "published_at": "2024-01-15T10:00:00.000Z",
      "view_count": 150,
      "is_active": 1
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 1,
    "totalItems": 1,
    "itemsPerPage": 10,
    "hasNextPage": false,
    "hasPrevPage": false
  }
}
```

### Delete Category with Protection
**Request:**
```bash
DELETE /api/admin/categories/1
Authorization: Bearer <token>
```

**Response (if has articles):**
```json
{
  "success": false,
  "message": "Cannot delete category with related articles. Please reassign or delete the articles first.",
  "data": null
}
```

---

## 8. Testing Results

### ✅ Verified Functionality
1. **Category CRUD**: All operations working
2. **Article Creation**: Successfully creates with category_id and subtitle
3. **Article Update**: Successfully updates category assignment
4. **Category Filtering**: Articles filter correctly by category slug
5. **Category Information**: All articles include category details
6. **Deletion Protection**: Cannot delete categories with articles
7. **Validation**: Properly rejects invalid data
8. **Swagger Documentation**: Complete and accurate

### Test Data Created
- 4 categories
- 7 articles (5 seeded + 2 test articles)
- All articles have category assignments
- Category filtering tested and working

---

## 9. Files Modified

### Database
- `src/scripts/initDatabase.js` - Added categories table, updated articles table
- `src/scripts/seedDatabase.js` - Added category and article seeds

### Models
- `src/models/Category.js` - New model
- `src/models/Article.js` - Updated to include category relationships

### Controllers
- `src/controllers/categoryController.js` - New controller with full CRUD
- `src/controllers/articleController.js` - Updated to support categories
- `src/controllers/homeController.js` - Updated to include category info
- `src/controllers/aboutController.js` - Updated if needed

### Routes
- `src/routes/public.js` - Added category routes
- `src/routes/admin.js` - Added category admin routes with validation

### Validation
- `src/utils/validation.js` - Added categorySchemas, updated articleSchemas

### Documentation
- `src/utils/swagger.js` - Added Category schema, updated Article schema
- `src/controllers/articleController.js` - Updated Swagger docs
- `src/controllers/categoryController.js` - Complete Swagger docs

### Documentation Files
- `SWAGGER_CATEGORIES_UPDATE.md` - Swagger documentation details
- `ADMIN_ROUTES_UPDATE.md` - Admin routes and validation details
- `COMPLETE_ARTICLES_CATEGORIES_UPDATE.md` - This comprehensive summary

---

## 10. Security Features

1. **Authentication**: All admin endpoints require Bearer token
2. **Input Validation**: Joi schemas validate all create/update operations
3. **Data Integrity**: Foreign key constraints and deletion protection
4. **Type Safety**: Validation ensures correct data types
5. **Length Limits**: Enforced on all text fields
6. **Rate Limiting**: Applied to all API endpoints

---

## 11. Migration Guide

### For Frontend Developers

#### Category Management UI
1. Create category list page showing all categories
2. Add category form with fields: name, slug, description, is_active
3. Implement edit/delete with protection warning
4. Show article count per category

#### Article Management UI
1. Add subtitle field to article forms
2. Add category dropdown (fetch from `/api/categories`)
3. Display category badge on article cards
4. Add category filter to article list
5. Handle validation errors appropriately

#### API Integration
```javascript
// Fetch categories for dropdown
const categories = await fetch('/api/categories').then(r => r.json());

// Create article with category
const article = await fetch('/api/admin/articles', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    title: 'Article Title',
    subtitle: 'Article Subtitle',
    content: '# Markdown content',
    category_id: 1,
    excerpt: 'Short excerpt',
    image_url: 'https://...'
  })
});

// Filter articles by category
const articles = await fetch('/api/articles?category=environmental-conservation')
  .then(r => r.json());
```

### For Backend Developers

#### Database Migration
If updating existing database:
```sql
-- Add categories table
CREATE TABLE categories (...);

-- Update articles table
ALTER TABLE articles 
  ADD COLUMN subtitle VARCHAR(200) AFTER title,
  ADD COLUMN category_id INT,
  ADD FOREIGN KEY (category_id) REFERENCES categories(id);

-- Seed categories
INSERT INTO categories (name, slug, description) VALUES (...);
```

#### Code Integration
- Import Category model where needed
- Use LEFT JOIN when querying articles to include category info
- Check `hasRelatedArticles()` before deleting categories
- Include category_id in article validation

---

## 12. Default Credentials
- Email: admin@semestalestari.com
- Password: admin123

---

## 13. API Documentation
- **Swagger UI**: http://localhost:3000/api-docs
- **Swagger JSON**: http://localhost:3000/api-docs.json
- **Health Check**: http://localhost:3000/api/health

---

## 14. Notes

1. **Backward Compatibility**: Articles without categories are supported (category_id is nullable)
2. **Subtitle Optional**: Subtitle field is optional for backward compatibility
3. **Category Filtering**: If no category specified, returns all articles
4. **Deletion Protection**: Prevents accidental data loss
5. **Markdown Content**: Full markdown support in article content
6. **SEO Friendly**: Category slugs are URL-friendly
7. **Performance**: Uses LEFT JOIN for efficient queries
8. **Validation**: Comprehensive validation on all inputs

---

## 15. Future Enhancements

Potential improvements:
1. Category hierarchy (parent/child categories)
2. Multiple categories per article (many-to-many)
3. Category images/icons
4. Category-specific templates
5. Category analytics (article count, view count)
6. Bulk category assignment
7. Category import/export
8. Category ordering/sorting

---

## Summary

This update provides a complete category management system for the Semesta Lestari API with:
- Full CRUD operations for categories
- Article categorization with foreign key relationships
- Category filtering for articles
- Deletion protection for data integrity
- Comprehensive validation
- Complete Swagger documentation
- Backward compatibility

All endpoints are tested and working correctly. The system is production-ready.
