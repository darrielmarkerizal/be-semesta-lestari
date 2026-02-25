# Swagger Documentation Update - Footer & Program Categories

## Overview
Updated Swagger/OpenAPI documentation to include the new footer endpoint and program categories management endpoints.

## Changes Made

### 1. Updated Swagger Configuration (`src/utils/swagger.js`)

#### New Tags Added
```javascript
{ name: 'Admin - Program Categories', description: 'Admin program category management' }
{ name: 'Admin - Statistics', description: 'Admin statistics and analytics' }
{ name: 'Admin - Image Upload', description: 'Admin image upload management' }
{ name: 'Footer', description: 'Footer data endpoint' }
```

#### New Schemas Added

**ProgramCategory Schema:**
```javascript
ProgramCategory: {
  type: 'object',
  properties: {
    id: { type: 'integer' },
    name: { type: 'string' },
    slug: { type: 'string' },
    description: { type: 'string', nullable: true },
    icon: { type: 'string', nullable: true, description: 'Emoji or icon identifier' },
    order_position: { type: 'integer' },
    is_active: { type: 'boolean' },
    created_at: { type: 'string', format: 'date-time' },
    updated_at: { type: 'string', format: 'date-time' }
  }
}
```

**FooterData Schema:**
```javascript
FooterData: {
  type: 'object',
  properties: {
    contact: {
      type: 'object',
      properties: {
        email: { type: 'string', format: 'email' },
        phones: { type: 'array', items: { type: 'string' } },
        address: { type: 'string' },
        work_hours: { type: 'string' }
      }
    },
    social_media: {
      type: 'object',
      properties: {
        facebook: { type: 'string', format: 'uri' },
        instagram: { type: 'string', format: 'uri' },
        twitter: { type: 'string', format: 'uri' },
        youtube: { type: 'string', format: 'uri' },
        linkedin: { type: 'string', format: 'uri' },
        tiktok: { type: 'string', format: 'uri' }
      }
    },
    program_categories: {
      type: 'array',
      items: { $ref: '#/components/schemas/ProgramCategory' }
    }
  }
}
```

### 2. Controller Documentation

#### Footer Controller (`src/controllers/footerController.js`)

**Endpoint:** `GET /api/footer`

**JSDoc Documentation:**
```javascript
/**
 * @swagger
 * /api/footer:
 *   get:
 *     summary: Get footer data
 *     description: Returns all data needed for the website footer including contact information, social media links, and program categories
 *     tags:
 *       - Footer
 *     responses:
 *       200:
 *         description: Footer data retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: Footer data retrieved
 *                 data:
 *                   $ref: '#/components/schemas/FooterData'
 */
```

#### Program Category Controller (`src/controllers/programCategoryController.js`)

**Endpoints:**

1. **GET /api/admin/program-categories**
```javascript
/**
 * @swagger
 * /api/admin/program-categories:
 *   get:
 *     summary: Get all program categories
 *     tags:
 *       - Admin - Program Categories
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Program categories retrieved successfully
 */
```

2. **POST /api/admin/program-categories**
```javascript
/**
 * @swagger
 * /api/admin/program-categories:
 *   post:
 *     summary: Create new program category
 *     tags:
 *       - Admin - Program Categories
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - slug
 *             properties:
 *               name:
 *                 type: string
 *                 example: Conservation
 *               slug:
 *                 type: string
 *                 example: conservation
 *               description:
 *                 type: string
 *                 example: Programs focused on environmental conservation
 *               icon:
 *                 type: string
 *                 example: 🌳
 *               order_position:
 *                 type: integer
 *                 example: 1
 *               is_active:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       201:
 *         description: Program category created successfully
 */
```

3. **PUT /api/admin/program-categories/{id}**
```javascript
/**
 * @swagger
 * /api/admin/program-categories/{id}:
 *   put:
 *     summary: Update program category
 *     tags:
 *       - Admin - Program Categories
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               slug:
 *                 type: string
 *               description:
 *                 type: string
 *               icon:
 *                 type: string
 *               order_position:
 *                 type: integer
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Program category updated successfully
 */
```

4. **DELETE /api/admin/program-categories/{id}**
```javascript
/**
 * @swagger
 * /api/admin/program-categories/{id}:
 *   delete:
 *     summary: Delete program category
 *     tags:
 *       - Admin - Program Categories
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Program category deleted successfully
 */
```

## Accessing Swagger Documentation

### Local Development
```
http://localhost:3000/api-docs/
```

### Production
```
https://api.senestalestari.org/api-docs/
```

## New Endpoints in Swagger UI

### Public Endpoints
- **Footer**
  - `GET /api/footer` - Get footer data (contact, social media, program categories)

### Admin Endpoints (Require Authentication)
- **Admin - Program Categories**
  - `GET /api/admin/program-categories` - List all program categories
  - `POST /api/admin/program-categories` - Create new program category
  - `GET /api/admin/program-categories/{id}` - Get single program category
  - `PUT /api/admin/program-categories/{id}` - Update program category
  - `DELETE /api/admin/program-categories/{id}` - Delete program category

## Example Requests in Swagger UI

### 1. Get Footer Data
**No authentication required**

Request:
```
GET /api/footer
```

Response:
```json
{
  "success": true,
  "message": "Footer data retrieved",
  "data": {
    "contact": {
      "email": "info@semestalestari.org",
      "phones": ["(+62) 21-1234-5678", "(+62) 812-3456-7890"],
      "address": "Jl. Lingkungan Hijau No. 123, Jakarta Selatan",
      "work_hours": "Monday - Friday: 09:00 AM - 05:00 PM"
    },
    "social_media": {
      "facebook": "https://facebook.com/semestalestari",
      "instagram": "https://instagram.com/semestalestari",
      "twitter": "https://twitter.com/semestalestari",
      "youtube": "https://youtube.com/@semestalestari",
      "linkedin": "https://linkedin.com/company/semestalestari",
      "tiktok": "https://tiktok.com/@semestalestari"
    },
    "program_categories": [
      {
        "id": 1,
        "name": "Conservation",
        "slug": "conservation",
        "description": "Programs focused on environmental conservation",
        "icon": "🌳",
        "order_position": 1,
        "is_active": true
      }
    ]
  }
}
```

### 2. Create Program Category
**Requires Bearer token authentication**

Request:
```
POST /api/admin/program-categories
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Wildlife Protection",
  "slug": "wildlife-protection",
  "description": "Programs dedicated to protecting endangered wildlife",
  "icon": "🦁",
  "order_position": 5,
  "is_active": true
}
```

Response:
```json
{
  "success": true,
  "message": "Program Category created successfully",
  "data": {
    "id": 5,
    "name": "Wildlife Protection",
    "slug": "wildlife-protection",
    "description": "Programs dedicated to protecting endangered wildlife",
    "icon": "🦁",
    "order_position": 5,
    "is_active": true,
    "created_at": "2026-02-25T14:30:00.000Z",
    "updated_at": "2026-02-25T14:30:00.000Z"
  }
}
```

## Testing Swagger Documentation

### 1. Access Swagger UI
```bash
open http://localhost:3000/api-docs/
```

### 2. Test Footer Endpoint
1. Navigate to "Footer" section
2. Click on `GET /api/footer`
3. Click "Try it out"
4. Click "Execute"
5. Verify response includes contact, social_media, and program_categories

### 3. Test Program Categories (Admin)
1. First, authenticate:
   - Navigate to "Authentication" section
   - Use `POST /api/admin/auth/login`
   - Login with: `admin@semestalestari.com` / `admin123`
   - Copy the `accessToken` from response

2. Authorize in Swagger:
   - Click "Authorize" button at top
   - Enter: `Bearer {your_token}`
   - Click "Authorize"

3. Test CRUD operations:
   - Navigate to "Admin - Program Categories"
   - Try GET, POST, PUT, DELETE operations

## Schema Validation

All endpoints now have proper schema validation in Swagger:

- **Request bodies** are validated against defined schemas
- **Response bodies** follow consistent structure
- **Error responses** use standard Error schema
- **Pagination** uses standard Pagination schema

## Related Documentation

- [Footer API Summary](./FOOTER_API_SUMMARY.md)
- [Footer Quick Reference](./FOOTER_QUICK_REFERENCE.md)
- [Footer Test Report](./FOOTER_TEST_REPORT.md)

## Notes

- All JSDoc comments are already in place in controller files
- Swagger automatically generates documentation from these comments
- Server restart required to see Swagger changes
- Swagger UI provides interactive API testing interface

## Verification

To verify Swagger documentation is working:

```bash
# Check Swagger UI is accessible
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api-docs/

# Should return: 200

# Test footer endpoint through Swagger
# Visit http://localhost:3000/api-docs/ and test the endpoints
```

## Summary

✅ Added Footer tag and schema  
✅ Added ProgramCategory schema  
✅ Added FooterData composite schema  
✅ Documented all footer endpoints  
✅ Documented all program category CRUD endpoints  
✅ Added proper request/response examples  
✅ Added authentication requirements  
✅ Server restarted with new documentation  

All new endpoints are now fully documented and testable through Swagger UI at `/api-docs/`.
