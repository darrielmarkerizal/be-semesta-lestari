# Swagger Documentation Update - Articles & Categories

## Summary
Updated Swagger/OpenAPI documentation for the Articles and Categories functionality, including comprehensive schemas, detailed endpoint descriptions, and category deletion protection documentation.

## Date
February 19, 2026

## Changes Made

### 1. Updated Swagger Schemas (src/utils/swagger.js)

#### Article Schema
Added complete schema with all fields including category information:
- `id`, `title`, `subtitle` (nullable)
- `slug`, `content` (markdown), `excerpt` (nullable)
- `image_url` (nullable), `author_id`
- `category_id` (nullable), `category_name` (nullable), `category_slug` (nullable)
- `published_at`, `is_active`, `view_count`
- `created_at`, `updated_at`

#### Category Schema
New schema added with complete fields:
- `id`, `name`, `slug`
- `description` (nullable), `is_active`
- `created_at`, `updated_at`

#### Tags
Added new tags:
- `Categories` - Public category endpoints
- `Admin - Categories` - Admin category management

### 2. Updated Article Controller Documentation (src/controllers/articleController.js)

#### Public Endpoints

**GET /api/articles**
- Description: Get paginated articles with optional category filtering
- Parameters:
  - `category` (query, optional): Filter by category slug
  - `page` (query, default: 1): Page number
  - `limit` (query, default: 10): Items per page
- Response: Articles with category information (category_id, category_name, category_slug)
- Uses `$ref: '#/components/schemas/Article'` for consistent schema

**GET /api/articles/{slug}**
- Description: Get single article by slug with category information
- Parameters:
  - `slug` (path, required): Article slug
- Response: Article object with category information
- Error responses: 404 for not found

**POST /api/articles/{id}/increment-views**
- Description: Increment article view count
- Parameters:
  - `id` (path, required): Article ID

#### Admin Endpoints

**GET /api/admin/articles**
- Description: Get all articles including inactive ones (admin only)
- Security: Bearer token required
- Parameters: page, limit
- Response: Paginated articles with category information

**POST /api/admin/articles**
- Description: Create new article with optional category assignment
- Security: Bearer token required
- Request body:
  - `title` (required), `subtitle` (optional)
  - `content` (required, markdown)
  - `excerpt`, `image_url` (optional)
  - `category_id` (optional, integer) - Foreign key to categories table
  - `published_at`, `is_active` (optional)
- Response: Created article with 201 status

**GET /api/admin/articles/{id}**
- Description: Get single article by ID with category information
- Security: Bearer token required
- Response: Article object

**PUT /api/admin/articles/{id}**
- Description: Update article including category assignment
- Security: Bearer token required
- Request body: All article fields optional including `category_id`
- Response: Updated article object

**DELETE /api/admin/articles/{id}**
- Description: Delete article permanently
- Security: Bearer token required
- Response: Success message

### 3. Updated Category Controller Documentation (src/controllers/categoryController.js)

#### Public Endpoints

**GET /api/categories**
- Description: Get all active categories for public use
- Response: Array of active categories

**GET /api/categories/{slug}**
- Description: Get single active category by slug
- Parameters:
  - `slug` (path, required): Category slug
- Response: Category object
- Error responses: 404 for not found

#### Admin Endpoints

**GET /api/admin/categories**
- Description: Get all categories including inactive ones
- Security: Bearer token required
- Response: Array of all categories

**POST /api/admin/categories**
- Description: Create new category
- Security: Bearer token required
- Request body:
  - `name` (required): Category name
  - `slug` (required): URL-friendly slug
  - `description` (optional): Category description
  - `is_active` (optional, default: true): Active status
- Response: Created category with 201 status

**PUT /api/admin/categories/{id}**
- Description: Update existing category
- Security: Bearer token required
- Request body: All category fields optional
- Response: Updated category object

**DELETE /api/admin/categories/{id}**
- Description: Delete category with protection
- Security: Bearer token required
- **Protection**: Cannot delete if category has related articles
- Responses:
  - 200: Category deleted successfully
  - 400: Cannot delete category with related articles (includes helpful message)
  - 404: Category not found
  - 401: Unauthorized

## Features Documented

### 1. Category Filtering
- Articles can be filtered by category using `?category=slug` query parameter
- If no category specified, returns all articles
- All articles include category information in response

### 2. Category Information in Articles
All article responses include:
- `category_id`: Integer ID of the category
- `category_name`: Human-readable category name
- `category_slug`: URL-friendly category slug

### 3. Category Deletion Protection
- Categories with related articles cannot be deleted
- Returns 400 error with clear message
- Message: "Cannot delete category with related articles. Please reassign or delete the articles first."
- Implemented via `hasRelatedArticles()` method in Category model

### 4. Markdown Content
- Article content field supports markdown
- Documented in schema with description: "Markdown content"

## Testing Results

### Verified Endpoints
✅ GET /api/categories - Returns 4 categories
✅ GET /api/articles - Returns articles with category information
✅ GET /api/articles?category=environmental-conservation - Filters correctly
✅ DELETE /api/admin/categories/{id} - Protection working (returns 400 for categories with articles)

### Swagger Documentation
✅ Article schema includes all fields with category information
✅ Category schema properly defined
✅ All endpoints have comprehensive documentation
✅ Request/response examples included
✅ Error responses documented
✅ Security requirements specified

## Access Swagger Documentation

- **Swagger UI**: http://localhost:3000/api-docs
- **Swagger JSON**: http://localhost:3000/api-docs.json

## Default Admin Credentials
- Email: admin@semestalestari.com
- Password: admin123

## Notes

1. All admin endpoints require Bearer token authentication
2. Category deletion protection is enforced at the controller level
3. Articles use LEFT JOIN with categories, so articles without categories are supported
4. All schemas use `$ref` for consistency and maintainability
5. Pagination schema is reused across endpoints
6. Error responses follow consistent format using Error schema
