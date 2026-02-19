# Image Upload System - Complete Implementation

## Overview
Comprehensive image upload, management, and deletion system for all entities in the Semesta Lestari API. Images are stored locally in organized directories and served as static files.

## Features
- ✅ Multipart form data upload
- ✅ Single and multiple file uploads
- ✅ Organized storage by entity type
- ✅ Automatic file naming with timestamps
- ✅ File type validation (JPEG, PNG, GIF, WebP)
- ✅ File size limit (5MB per file)
- ✅ Image deletion with cleanup
- ✅ Static file serving
- ✅ Full authentication required
- ✅ Swagger documentation

## Supported Entity Types
Images can be uploaded for the following entities:
- `articles` - Article images
- `awards` - Award images
- `gallery` - Gallery photos
- `merchandise` - Product images
- `programs` - Program images
- `partners` - Partner logos
- `leadership` - Leadership member photos
- `history` - Historical event images
- `pages` - Page hero images
- `hero` - Hero section images
- `donation` - Donation CTA images
- `closing` - Closing CTA images

## Directory Structure
```
uploads/
├── articles/
├── awards/
├── gallery/
├── merchandise/
├── programs/
├── partners/
├── leadership/
├── history/
├── pages/
├── hero/
├── donation/
└── closing/
```

## API Endpoints

### 1. Upload Single Image
```
POST /api/admin/upload/{entity}
```

**Authentication**: Required (Bearer token)

**Parameters**:
- `entity` (path): Entity type (articles, awards, gallery, etc.)

**Request Body** (multipart/form-data):
- `image` (file): Image file (JPEG, PNG, GIF, WebP, max 5MB)

**Example using cURL**:
```bash
curl -X POST http://localhost:3000/api/admin/upload/articles \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "image=@/path/to/image.jpg"
```

**Response**:
```json
{
  "success": true,
  "message": "Image uploaded successfully",
  "data": {
    "url": "/uploads/articles/image-1234567890.jpg",
    "fullUrl": "http://localhost:3000/uploads/articles/image-1234567890.jpg",
    "filename": "image-1234567890.jpg",
    "path": "uploads/articles/image-1234567890.jpg",
    "size": 45678,
    "mimetype": "image/jpeg"
  }
}
```

### 2. Upload Multiple Images
```
POST /api/admin/upload/multiple/{entity}
```

**Authentication**: Required (Bearer token)

**Parameters**:
- `entity` (path): Entity type

**Request Body** (multipart/form-data):
- `images` (files): Multiple image files (max 10 files, each max 5MB)

**Example using cURL**:
```bash
curl -X POST http://localhost:3000/api/admin/upload/multiple/gallery \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "images=@/path/to/image1.jpg" \
  -F "images=@/path/to/image2.jpg"
```

**Response**:
```json
{
  "success": true,
  "message": "2 image(s) uploaded successfully",
  "data": {
    "files": [
      {
        "url": "/uploads/gallery/image1-1234567890.jpg",
        "fullUrl": "http://localhost:3000/uploads/gallery/image1-1234567890.jpg",
        "filename": "image1-1234567890.jpg",
        "path": "uploads/gallery/image1-1234567890.jpg",
        "size": 45678,
        "mimetype": "image/jpeg"
      },
      {
        "url": "/uploads/gallery/image2-1234567891.jpg",
        "fullUrl": "http://localhost:3000/uploads/gallery/image2-1234567891.jpg",
        "filename": "image2-1234567891.jpg",
        "path": "uploads/gallery/image2-1234567891.jpg",
        "size": 56789,
        "mimetype": "image/jpeg"
      }
    ],
    "count": 2
  }
}
```

### 3. Delete Image
```
DELETE /api/admin/upload
```

**Authentication**: Required (Bearer token)

**Request Body** (JSON):
```json
{
  "url": "/uploads/articles/image-1234567890.jpg"
}
```

**Example using cURL**:
```bash
curl -X DELETE http://localhost:3000/api/admin/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"url":"/uploads/articles/image-1234567890.jpg"}'
```

**Response**:
```json
{
  "success": true,
  "message": "Image deleted successfully",
  "data": null
}
```

### 4. Access Uploaded Images
```
GET /uploads/{entity}/{filename}
```

**Authentication**: Not required (public access)

**Example**:
```
http://localhost:3000/uploads/articles/image-1234567890.jpg
```

## File Naming Convention
Uploaded files are automatically renamed using the following pattern:
```
{sanitized-original-name}-{timestamp}-{random-number}.{extension}
```

**Example**:
- Original: `My Photo 2024.jpg`
- Renamed: `my-photo-2024-1771492149452-6901261.jpg`

## File Validation

### Allowed File Types
- JPEG (`.jpg`, `.jpeg`)
- PNG (`.png`)
- GIF (`.gif`)
- WebP (`.webp`)

### File Size Limit
- Maximum: 5MB per file
- Multiple uploads: 5MB per file, max 10 files

### Validation Errors
```json
{
  "success": false,
  "message": "Invalid file type. Only JPEG, PNG, GIF, and WebP images are allowed.",
  "data": null
}
```

## Integration with Entities

### Example: Creating Article with Image

**Step 1: Upload Image**
```bash
curl -X POST http://localhost:3000/api/admin/upload/articles \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "image=@article-cover.jpg"
```

**Response**:
```json
{
  "data": {
    "url": "/uploads/articles/article-cover-1234567890.jpg"
  }
}
```

**Step 2: Create Article with Image URL**
```bash
curl -X POST http://localhost:3000/api/admin/articles \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "New Article",
    "content": "Article content...",
    "image_url": "/uploads/articles/article-cover-1234567890.jpg",
    "category_id": 1
  }'
```

### Example: Updating Entity Image

**Step 1: Upload New Image**
```bash
curl -X POST http://localhost:3000/api/admin/upload/programs \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "image=@new-program-image.jpg"
```

**Step 2: Update Program with New Image**
```bash
curl -X PUT http://localhost:3000/api/admin/programs/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "image_url": "/uploads/programs/new-program-image-1234567890.jpg"
  }'
```

**Step 3: Delete Old Image (Optional)**
```bash
curl -X DELETE http://localhost:3000/api/admin/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"url": "/uploads/programs/old-image.jpg"}'
```

## Files Created/Modified

### New Files
1. **`src/middleware/upload.js`**
   - Multer configuration
   - Storage setup with organized directories
   - File validation (type, size)
   - Helper functions for file operations

2. **`src/controllers/uploadController.js`**
   - Upload single image handler
   - Upload multiple images handler
   - Delete image handler
   - Helper function for updating entity images

3. **`test_image_upload.sh`**
   - Comprehensive test script
   - 9 test cases covering all scenarios
   - All tests passing (100%)

### Modified Files
1. **`src/routes/admin.js`**
   - Added upload routes
   - Imported upload middleware and controller

2. **`src/app.js`**
   - Added static file serving for `/uploads` directory
   - Updated helmet configuration for CORS

3. **`package.json`**
   - Added `multer` dependency

## Testing

### Run Test Script
```bash
./test_image_upload.sh
```

### Test Coverage
1. ✓ Upload image to articles entity
2. ✓ Verify uploaded image is accessible
3. ✓ Upload image to gallery entity
4. ✓ Upload without authentication (should fail)
5. ✓ Upload without file (should fail)
6. ✓ Upload multiple images
7. ✓ Delete uploaded image
8. ✓ Deleted image is no longer accessible
9. ✓ Test uploads to different entity types

**Result**: 9/9 tests passing (100%)

### Manual Testing

**Upload Image**:
```bash
# Create test image
echo "Test" > test.txt
convert -size 100x100 xc:blue test.jpg  # Or use any image

# Upload
curl -X POST http://localhost:3000/api/admin/upload/articles \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "image=@test.jpg"
```

**Access Image**:
```bash
curl http://localhost:3000/uploads/articles/test-1234567890.jpg
```

**Delete Image**:
```bash
curl -X DELETE http://localhost:3000/api/admin/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"url":"/uploads/articles/test-1234567890.jpg"}'
```

## Security Considerations

### Authentication
- All upload and delete operations require authentication
- Bearer token must be valid
- Only admin users can upload/delete images

### File Validation
- Only image files allowed (JPEG, PNG, GIF, WebP)
- File size limited to 5MB
- MIME type validation
- File extension validation

### File Storage
- Files stored outside web root (in `uploads/` directory)
- Organized by entity type
- Unique filenames prevent collisions
- No executable files allowed

### CORS
- Configured to allow cross-origin image access
- Helmet configured with `crossOriginResourcePolicy: "cross-origin"`

## Error Handling

### Common Errors

**1. No file uploaded**
```json
{
  "success": false,
  "message": "No file uploaded",
  "data": null
}
```

**2. Invalid file type**
```json
{
  "success": false,
  "message": "Invalid file type. Only JPEG, PNG, GIF, and WebP images are allowed.",
  "data": null
}
```

**3. File too large**
```json
{
  "success": false,
  "message": "File too large. Maximum size is 5MB.",
  "data": null
}
```

**4. Unauthorized**
```json
{
  "success": false,
  "message": "Unauthorized",
  "data": null
}
```

**5. File not found (delete)**
```json
{
  "success": false,
  "message": "File not found or already deleted",
  "data": null
}
```

## Swagger Documentation

All upload endpoints are fully documented in Swagger UI:
- Request/response schemas
- Authentication requirements
- File upload examples
- Error responses

Access Swagger at: `http://localhost:3000/api-docs`

## Usage Examples

### Frontend Integration (JavaScript)

**Upload Image**:
```javascript
async function uploadImage(file, entity) {
  const formData = new FormData();
  formData.append('image', file);

  const response = await fetch(`http://localhost:3000/api/admin/upload/${entity}`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`
    },
    body: formData
  });

  const data = await response.json();
  return data.data.url; // Returns: /uploads/articles/image-123.jpg
}
```

**Upload Multiple Images**:
```javascript
async function uploadMultipleImages(files, entity) {
  const formData = new FormData();
  files.forEach(file => {
    formData.append('images', file);
  });

  const response = await fetch(`http://localhost:3000/api/admin/upload/multiple/${entity}`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`
    },
    body: formData
  });

  const data = await response.json();
  return data.data.files; // Returns array of uploaded files
}
```

**Delete Image**:
```javascript
async function deleteImage(url) {
  const response = await fetch('http://localhost:3000/api/admin/upload', {
    method: 'DELETE',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ url })
  });

  return await response.json();
}
```

### React Example

```jsx
import React, { useState } from 'react';

function ImageUploader({ entity, onUpload }) {
  const [uploading, setUploading] = useState(false);

  const handleFileChange = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    setUploading(true);
    try {
      const formData = new FormData();
      formData.append('image', file);

      const response = await fetch(`/api/admin/upload/${entity}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: formData
      });

      const data = await response.json();
      if (data.success) {
        onUpload(data.data.url);
      }
    } catch (error) {
      console.error('Upload failed:', error);
    } finally {
      setUploading(false);
    }
  };

  return (
    <div>
      <input 
        type="file" 
        accept="image/*" 
        onChange={handleFileChange}
        disabled={uploading}
      />
      {uploading && <p>Uploading...</p>}
    </div>
  );
}
```

## Best Practices

### 1. Always Upload Before Creating/Updating Entity
```bash
# Good: Upload first, then create
1. POST /api/admin/upload/articles (get URL)
2. POST /api/admin/articles (use URL)

# Bad: Create with external URL
POST /api/admin/articles (with external URL)
```

### 2. Delete Old Images When Updating
```bash
# When updating entity image:
1. Upload new image
2. Update entity with new URL
3. Delete old image
```

### 3. Use Appropriate Entity Type
```bash
# Good: Organized by entity
/uploads/articles/article-image.jpg
/uploads/gallery/photo.jpg

# Bad: Everything in one folder
/uploads/general/everything.jpg
```

### 4. Handle Upload Errors
```javascript
try {
  const url = await uploadImage(file, 'articles');
  // Use URL
} catch (error) {
  // Show error to user
  alert('Upload failed: ' + error.message);
}
```

## Maintenance

### Cleanup Old Images
```bash
# Find images not referenced in database
# (Manual script - run periodically)

# Example: Find orphaned article images
mysql -u root semesta_lestari -e "
  SELECT CONCAT('uploads', SUBSTRING_INDEX(image_url, 'uploads', -1)) as path
  FROM articles 
  WHERE image_url IS NOT NULL
" > used_images.txt

# Compare with actual files and delete orphans
```

### Backup Images
```bash
# Backup uploads directory
tar -czf uploads-backup-$(date +%Y%m%d).tar.gz uploads/
```

### Monitor Disk Usage
```bash
# Check uploads directory size
du -sh uploads/

# Check by entity
du -sh uploads/*/
```

## Status
✅ **COMPLETE** - All functionality implemented and tested
- Single image upload working
- Multiple image upload working
- Image deletion working
- Static file serving working
- All tests passing (100%)
- Documentation complete
- Swagger documentation complete
