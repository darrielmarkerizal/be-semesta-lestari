# Admin Routes Update - Articles & Categories

## Summary
Updated admin routes and validation schemas to support the new article and category features including subtitle field, category_id foreign key, and comprehensive validation.

## Date
February 19, 2026

## Changes Made

### 1. Updated Validation Schemas (src/utils/validation.js)

#### Article Validation
Updated `articleSchemas` to support new fields:

**Create Schema:**
- `title` (required, string)
- `subtitle` (optional, string, max 200 chars, nullable)
- `content` (required, string, markdown)
- `excerpt` (optional, string, max 500 chars, nullable)
- `image_url` (optional, string URI, nullable)
- `category_id` (optional, positive integer, nullable) - Foreign key to categories
- `published_at` (optional, date)
- `is_active` (optional, boolean, default: true)

**Update Schema:**
- All fields optional
- Same validation rules as create schema

#### Category Validation
Added new `categorySchemas`:

**Create Schema:**
- `name` (required, string)
- `slug` (required, string)
- `description` (optional, string, max 500 chars, nullable)
- `is_active` (optional, boolean, default: true)

**Update Schema:**
- All fields optional
- Same validation rules as create schema

### 2. Updated Admin Routes (src/routes/admin.js)

#### Article Routes
All article routes now use updated validation:
- `POST /api/admin/articles` - Uses `validate(articleSchemas.create)`
- `PUT /api/admin/articles/:id` - Uses `validate(articleSchemas.update)`

#### Category Routes
Added complete CRUD with validation:
- `GET /api/admin/categories` - Get all categories
- `POST /api/admin/categories` - Create with `validate(categorySchemas.create)`
- `GET /api/admin/categories/:id` - Get single category by ID (NEW)
- `PUT /api/admin/categories/:id` - Update with `validate(categorySchemas.update)`
- `DELETE /api/admin/categories/:id` - Delete with protection

### 3. Updated Category Controller (src/controllers/categoryController.js)

#### New Method: getCategoryByIdAdmin
Added method to retrieve single category by ID for admin use.

**Endpoint:** `GET /api/admin/categories/:id`

**Swagger Documentation:**
```yaml
summary: Get category by ID (admin)
description: Retrieve a single category by ID (admin only)
security: BearerAuth required
parameters:
  - id (path, required): Category ID
responses:
  200: Category retrieved successfully
  404: Category not found
  401: Unauthorized
```

**Response Example:**
```json
{
  "success": true,
  "message": "Category retrieved",
  "data": {
    "id": 5,
    "name": "Test Category",
    "slug": "test-category",
    "description": "Test description",
    "is_active": 1,
    "created_at": "2026-02-19T06:02:47.000Z",
    "updated_at": "2026-02-19T06:02:47.000Z"
  }
}
```

## Validation Rules

### Article Validation Rules
1. **Title**: Required on create, optional on update
2. **Subtitle**: Optional, max 200 characters, can be null or empty string
3. **Content**: Required on create (markdown format)
4. **Category ID**: Must be positive integer if provided, can be null
5. **Image URL**: Must be valid URI format if provided
6. **Excerpt**: Max 500 characters

### Category Validation Rules
1. **Name**: Required on create
2. **Slug**: Required on create, must be unique
3. **Description**: Optional, max 500 characters
4. **Is Active**: Boolean, defaults to true

### Validation Error Responses
When validation fails, returns:
```json
{
  "success": false,
  "message": "Validation failed",
  "data": null,
  "error": {
    "details": ["Specific validation error messages"]
  }
}
```

## Testing Results

### ✅ Category Management
1. **Create Category** - Successfully created with validation
   - Endpoint: `POST /api/admin/categories`
   - Validation: Requires name and slug
   - Response: Returns created category with ID

2. **Get Category by ID** - Successfully retrieves single category
   - Endpoint: `GET /api/admin/categories/:id`
   - Response: Returns category object
   - Error: 404 if not found

3. **Validation** - Properly rejects invalid data
   - Missing required fields returns validation error
   - Invalid data types rejected

### ✅ Article Management with Categories
1. **Create Article with Category** - Successfully creates with category_id and subtitle
   - Endpoint: `POST /api/admin/articles`
   - Fields: title, subtitle, content, category_id
   - Response: Returns article with category information (category_id, category_name, category_slug)

2. **Update Article Category** - Successfully updates category assignment
   - Endpoint: `PUT /api/admin/articles/:id`
   - Can change category_id and subtitle
   - Response: Returns updated article with new category information

3. **Category Information** - All article responses include:
   - `category_id`: Integer ID
   - `category_name`: Category name
   - `category_slug`: URL-friendly slug

### ✅ Category Deletion Protection
- Cannot delete categories with related articles
- Returns 400 error with helpful message
- Message: "Cannot delete category with related articles. Please reassign or delete the articles first."

## API Endpoints Summary

### Category Endpoints (Admin)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/admin/categories` | ✓ | Get all categories |
| POST | `/api/admin/categories` | ✓ | Create category (validated) |
| GET | `/api/admin/categories/:id` | ✓ | Get category by ID |
| PUT | `/api/admin/categories/:id` | ✓ | Update category (validated) |
| DELETE | `/api/admin/categories/:id` | ✓ | Delete category (protected) |

### Article Endpoints (Admin)
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/admin/articles` | ✓ | Get all articles |
| POST | `/api/admin/articles` | ✓ | Create article (validated, supports category_id) |
| GET | `/api/admin/articles/:id` | ✓ | Get article by ID |
| PUT | `/api/admin/articles/:id` | ✓ | Update article (validated, supports category_id) |
| DELETE | `/api/admin/articles/:id` | ✓ | Delete article |

## Request Examples

### Create Category
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

### Create Article with Category
```bash
POST /api/admin/articles
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Protecting Indonesian Forests",
  "subtitle": "Our commitment to preserving biodiversity",
  "content": "# Introduction\n\nThis article discusses...",
  "excerpt": "A brief overview of our conservation efforts",
  "image_url": "https://example.com/images/forest.jpg",
  "category_id": 1,
  "is_active": true
}
```

### Update Article Category
```bash
PUT /api/admin/articles/7
Authorization: Bearer <token>
Content-Type: application/json

{
  "subtitle": "Updated subtitle",
  "category_id": 2
}
```

## Security Features

1. **Authentication Required**: All admin endpoints require Bearer token
2. **Input Validation**: All create/update operations validated with Joi schemas
3. **Data Integrity**: Category deletion protected when articles exist
4. **Type Safety**: Validation ensures correct data types (integers, strings, booleans)
5. **Length Limits**: Enforced on subtitle (200), description (500), excerpt (500)

## Migration Notes

### For Frontend Developers
1. **Article Forms**: Add fields for `subtitle` and `category_id` (dropdown)
2. **Category Management**: Implement full CRUD interface
3. **Validation**: Handle validation errors from API
4. **Category Selection**: Fetch categories from `/api/categories` for dropdown
5. **Deletion Protection**: Show appropriate message when category deletion fails

### For API Consumers
1. **New Fields**: `subtitle` and `category_id` now available in article endpoints
2. **Category Info**: All article responses include category details
3. **Validation**: Ensure requests match validation schemas
4. **Error Handling**: Handle 400 errors for validation and deletion protection

## Default Admin Credentials
- Email: admin@semestalestari.com
- Password: admin123

## Documentation
- Swagger UI: http://localhost:3000/api-docs
- Swagger JSON: http://localhost:3000/api-docs.json

## Notes

1. All validation uses Joi schemas for consistency
2. Category deletion protection prevents data integrity issues
3. Articles can exist without categories (category_id is nullable)
4. Subtitle field is optional for backward compatibility
5. All admin endpoints require authentication
6. Rate limiting applies to all endpoints (15-minute window for login)
