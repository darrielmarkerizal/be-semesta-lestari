# Swagger Documentation Update - Image Upload System

## Overview
Complete Swagger documentation has been added for the image upload, management, and deletion system. All endpoints are fully documented with request/response schemas, authentication requirements, and examples.

## New Swagger Tags

### Admin - Upload
New tag added for all image upload operations:
- Upload single image
- Upload multiple images
- Delete image

## Documented Endpoints

### 1. Upload Single Image
```
POST /api/admin/upload/{entity}
```

**Swagger Documentation Includes**:
- Summary and description
- Security requirements (Bearer token)
- Path parameters (entity type with enum)
- Request body schema (multipart/form-data)
- Response schemas (success and error cases)
- HTTP status codes (200, 400, 401)

**Entity Types Documented**:
- articles
- awards
- gallery
- merchandise
- programs
- partners
- leadership
- history
- pages
- hero
- donation
- closing

**Request Body**:
```yaml
multipart/form-data:
  schema:
    type: object
    required:
      - image
    properties:
      image:
        type: string
        format: binary
        description: Image file (JPEG, PNG, GIF, WebP, max 5MB)
```

**Response Schema**:
```yaml
200:
  description: Image uploaded successfully
  content:
    application/json:
      schema:
        type: object
        properties:
          success:
            type: boolean
            example: true
          message:
            type: string
            example: Image uploaded successfully
          data:
            type: object
            properties:
              url:
                type: string
                example: /uploads/articles/image-1234567890.jpg
              fullUrl:
                type: string
                example: http://localhost:3000/uploads/articles/image-1234567890.jpg
              filename:
                type: string
                example: image-1234567890.jpg
              path:
                type: string
                example: uploads/articles/image-1234567890.jpg
              size:
                type: integer
                example: 45678
              mimetype:
                type: string
                example: image/jpeg
```

### 2. Upload Multiple Images
```
POST /api/admin/upload/multiple/{entity}
```

**Swagger Documentation Includes**:
- Summary and description
- Security requirements
- Path parameters
- Request body for multiple files
- Response with array of uploaded files
- File count in response

**Request Body**:
```yaml
multipart/form-data:
  schema:
    type: object
    required:
      - images
    properties:
      images:
        type: array
        items:
          type: string
          format: binary
        description: Image files (max 10 files, each max 5MB)
```

**Response Schema**:
```yaml
200:
  description: Images uploaded successfully
  content:
    application/json:
      schema:
        type: object
        properties:
          success:
            type: boolean
          message:
            type: string
            example: 2 image(s) uploaded successfully
          data:
            type: object
            properties:
              files:
                type: array
                items:
                  type: object
                  properties:
                    url:
                      type: string
                    fullUrl:
                      type: string
                    filename:
                      type: string
                    size:
                      type: integer
                    mimetype:
                      type: string
              count:
                type: integer
                example: 2
```

### 3. Delete Image
```
DELETE /api/admin/upload
```

**Swagger Documentation Includes**:
- Summary and description
- Security requirements
- Request body with URL
- Success and error responses
- HTTP status codes (200, 400, 404, 401)

**Request Body**:
```yaml
application/json:
  schema:
    type: object
    required:
      - url
    properties:
      url:
        type: string
        example: /uploads/articles/image-1234567890.jpg
        description: URL or path of the image to delete
```

**Response Schemas**:
```yaml
200:
  description: Image deleted successfully
  content:
    application/json:
      schema:
        type: object
        properties:
          success:
            type: boolean
            example: true
          message:
            type: string
            example: Image deleted successfully
          data:
            type: null

400:
  description: URL is required
  
404:
  description: File not found

401:
  description: Unauthorized
```

### 4. Access Uploaded Images (Public)
```
GET /uploads/{entity}/{filename}
```

**Note**: This endpoint serves static files and doesn't have explicit Swagger documentation, but it's documented in the system documentation.

**Access Pattern**:
- No authentication required
- Direct HTTP GET request
- Returns image file with appropriate Content-Type header

**Example**:
```
GET http://localhost:3000/uploads/articles/image-1234567890.jpg
```

## Security Schemas

### Bearer Authentication
All upload and delete endpoints require Bearer token authentication:

```yaml
securitySchemes:
  BearerAuth:
    type: http
    scheme: bearer
    bearerFormat: JWT
```

**Usage in Swagger UI**:
1. Click "Authorize" button
2. Enter: `Bearer YOUR_ACCESS_TOKEN`
3. Click "Authorize"
4. All protected endpoints will include the token

## Swagger UI Features

### Try It Out
All endpoints support "Try it out" functionality in Swagger UI:

1. **Upload Single Image**:
   - Select entity type from dropdown
   - Click "Choose File" to select image
   - Click "Execute"
   - View response with uploaded image URL

2. **Upload Multiple Images**:
   - Select entity type
   - Click "Choose Files" (can select multiple)
   - Click "Execute"
   - View array of uploaded files

3. **Delete Image**:
   - Enter image URL in request body
   - Click "Execute"
   - Verify deletion success

### Response Examples
Swagger UI shows example responses for:
- Successful uploads
- Validation errors
- Authentication errors
- File not found errors

## Updated Entity Schemas

All entity schemas that include image fields now reference the upload system:

### Articles
```yaml
image_url:
  type: string
  format: uri
  description: Image URL (upload via /api/admin/upload/articles)
  example: http://localhost:3000/uploads/articles/image-123.jpg
```

### Awards
```yaml
image_url:
  type: string
  description: Award image URL (upload via /api/admin/upload/awards)
```

### Gallery
```yaml
image_url:
  type: string
  description: Gallery image URL (upload via /api/admin/upload/gallery)
  required: true
```

### Merchandise
```yaml
image_url:
  type: string
  description: Product image URL (upload via /api/admin/upload/merchandise)
```

### Programs
```yaml
image_url:
  type: string
  description: Program image URL (upload via /api/admin/upload/programs)
```

### Partners
```yaml
logo_url:
  type: string
  description: Partner logo URL (upload via /api/admin/upload/partners)
```

### Leadership
```yaml
image_url:
  type: string
  description: Member photo URL (upload via /api/admin/upload/leadership)
```

### History
```yaml
image_url:
  type: string
  description: Historical image URL (upload via /api/admin/upload/history)
```

### Page Settings
```yaml
image_url:
  type: string
  description: Page hero image URL (upload via /api/admin/upload/pages)
```

### Hero Section
```yaml
image_url:
  type: string
  description: Hero image URL (upload via /api/admin/upload/hero)
```

### Donation CTA
```yaml
image_url:
  type: string
  description: CTA image URL (upload via /api/admin/upload/donation)
```

### Closing CTA
```yaml
image_url:
  type: string
  description: CTA image URL (upload via /api/admin/upload/closing)
```

## Workflow Documentation in Swagger

### Complete Upload Workflow
Documented in endpoint descriptions:

1. **Upload Image**:
   ```
   POST /api/admin/upload/{entity}
   → Returns: { url, fullUrl, filename }
   ```

2. **Create/Update Entity**:
   ```
   POST /api/admin/{entity}
   Body: { ..., image_url: fullUrl }
   ```

3. **Delete Old Image** (optional):
   ```
   DELETE /api/admin/upload
   Body: { url: oldImageUrl }
   ```

### Example Workflow in Swagger
```yaml
# Step 1: Upload
POST /api/admin/upload/articles
Files: image.jpg
Response: { "data": { "fullUrl": "http://..." } }

# Step 2: Create Article
POST /api/admin/articles
Body: {
  "title": "My Article",
  "content": "...",
  "image_url": "http://localhost:3000/uploads/articles/image-123.jpg"
}

# Step 3: Update Image (later)
POST /api/admin/upload/articles
Files: new-image.jpg
Response: { "data": { "fullUrl": "http://...new..." } }

PUT /api/admin/articles/1
Body: { "image_url": "http://...new..." }

# Step 4: Delete Old Image
DELETE /api/admin/upload
Body: { "url": "/uploads/articles/image-123.jpg" }
```

## Error Response Documentation

All endpoints document standard error responses:

### 400 Bad Request
```json
{
  "success": false,
  "message": "No file uploaded",
  "data": null,
  "error": null
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Unauthorized",
  "data": null,
  "error": null
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "File not found or already deleted",
  "data": null,
  "error": null
}
```

## File Validation Documentation

Documented in endpoint descriptions:

### Allowed File Types
- JPEG (`.jpg`, `.jpeg`)
- PNG (`.png`)
- GIF (`.gif`)
- WebP (`.webp`)

### File Size Limits
- Maximum: 5MB per file
- Multiple upload: 5MB per file, max 10 files

### Validation Errors
```json
{
  "success": false,
  "message": "Invalid file type. Only JPEG, PNG, GIF, and WebP images are allowed.",
  "data": null
}
```

## Accessing Swagger Documentation

### Local Development
```
http://localhost:3000/api-docs
```

### Swagger JSON
```
http://localhost:3000/api-docs.json
```

## Swagger UI Navigation

### Finding Upload Endpoints
1. Open Swagger UI
2. Look for "Admin - Upload" tag
3. Expand to see all upload operations
4. Click on endpoint to see details

### Testing Upload
1. Click "Try it out" on upload endpoint
2. Select entity type from dropdown
3. Click "Choose File" button
4. Select image file
5. Click "Execute"
6. View response with image URL
7. Copy URL for use in entity creation

### Testing Delete
1. First upload an image (get URL)
2. Go to delete endpoint
3. Click "Try it out"
4. Paste image URL in request body
5. Click "Execute"
6. Verify deletion success

## Integration Examples in Swagger

### Article with Image
```yaml
POST /api/admin/articles
requestBody:
  content:
    application/json:
      schema:
        type: object
        properties:
          title:
            type: string
            example: My Article
          content:
            type: string
            example: Article content...
          image_url:
            type: string
            format: uri
            example: http://localhost:3000/uploads/articles/image-123.jpg
            description: Upload image first via /api/admin/upload/articles
```

## Additional Documentation

### File Naming Convention
Documented in upload endpoint description:
- Pattern: `{sanitized-name}-{timestamp}-{random}.{ext}`
- Example: `my-photo-2024-1771492149452-6901261.jpg`

### Directory Organization
Documented in entity parameter description:
- Each entity type has its own directory
- Files organized as: `/uploads/{entity}/{filename}`

### Static File Access
Documented in system overview:
- Uploaded images are publicly accessible
- No authentication required for GET requests
- Direct URL access: `http://localhost:3000/uploads/{entity}/{filename}`

## Swagger Configuration

### Tags
```javascript
tags: [
  {
    name: 'Admin - Upload',
    description: 'Image upload, management, and deletion operations'
  }
]
```

### Security
```javascript
components: {
  securitySchemes: {
    BearerAuth: {
      type: 'http',
      scheme: 'bearer',
      bearerFormat: 'JWT'
    }
  }
}
```

## Testing in Swagger UI

### Complete Test Flow
1. **Authenticate**:
   - Click "Authorize"
   - Enter Bearer token
   - Click "Authorize"

2. **Upload Image**:
   - Go to `POST /api/admin/upload/articles`
   - Click "Try it out"
   - Select image file
   - Click "Execute"
   - Copy `fullUrl` from response

3. **Create Entity**:
   - Go to `POST /api/admin/articles`
   - Click "Try it out"
   - Fill in required fields
   - Paste `fullUrl` in `image_url` field
   - Click "Execute"

4. **Verify Image**:
   - Copy image URL
   - Open in new browser tab
   - Verify image displays

5. **Delete Image**:
   - Go to `DELETE /api/admin/upload`
   - Click "Try it out"
   - Enter image URL
   - Click "Execute"
   - Verify success response

## Status

✅ **COMPLETE** - All image upload endpoints fully documented in Swagger
- Upload single image: Documented
- Upload multiple images: Documented
- Delete image: Documented
- All entity integrations: Referenced
- Security requirements: Documented
- Error responses: Documented
- Examples: Provided
- Try it out: Functional

## Access Swagger Documentation

Visit: `http://localhost:3000/api-docs`

Look for the "Admin - Upload" section to see all image upload operations.
