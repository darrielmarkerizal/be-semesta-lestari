# Image Upload - Quick Reference

## Quick Start

### 1. Upload Image
```bash
curl -X POST http://localhost:3000/api/admin/upload/{entity} \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "image=@/path/to/image.jpg"
```

### 2. Use Image URL
```json
{
  "image_url": "/uploads/articles/image-1234567890.jpg"
}
```

### 3. Replace Image
```bash
curl -X POST http://localhost:3000/api/admin/upload/replace/{entity} \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "image=@/path/to/new-image.jpg" \
  -F "oldImageUrl=/uploads/articles/old-image.jpg"
```

### 4. Delete Image
```bash
curl -X DELETE http://localhost:3000/api/admin/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"url":"/uploads/articles/image-1234567890.jpg"}'
```

## Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/admin/upload/{entity}` | Upload single image |
| POST | `/api/admin/upload/multiple/{entity}` | Upload multiple images |
| POST | `/api/admin/upload/replace/{entity}` | Replace image (upload new + delete old) |
| DELETE | `/api/admin/upload` | Delete image |
| GET | `/uploads/{entity}/{filename}` | Access image (public) |

## Entity Types
- `articles` - Article images
- `awards` - Award images
- `gallery` - Gallery photos
- `merchandise` - Product images
- `programs` - Program images
- `partners` - Partner logos
- `leadership` - Leadership photos
- `history` - Historical images
- `pages` - Page hero images
- `hero` - Hero section images
- `donation` - Donation CTA images
- `closing` - Closing CTA images

## File Requirements
- **Types**: JPEG, PNG, GIF, WebP
- **Max Size**: 5MB per file
- **Max Files**: 10 (for multiple upload)

## Response Format

### Upload Success
```json
{
  "success": true,
  "message": "Image uploaded successfully",
  "data": {
    "url": "/uploads/articles/image-1234567890.jpg",
    "filename": "image-1234567890.jpg",
    "size": 45678,
    "mimetype": "image/jpeg"
  }
}
```

### Error
```json
{
  "success": false,
  "message": "No file uploaded",
  "data": null
}
```

## Common Workflows

### Create Entity with Image
```bash
# 1. Upload image
RESPONSE=$(curl -X POST http://localhost:3000/api/admin/upload/articles \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@image.jpg")

# 2. Extract URL
IMAGE_URL=$(echo $RESPONSE | jq -r '.data.url')

# 3. Create article with image
curl -X POST http://localhost:3000/api/admin/articles \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"Article\",\"content\":\"...\",\"image_url\":\"$IMAGE_URL\"}"
```

### Update Entity Image
```bash
# 1. Upload new image
# 2. Update entity with new URL
# 3. Delete old image (optional)
```

## Testing
```bash
./test_image_upload.sh
```

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

## JavaScript Example
```javascript
const formData = new FormData();
formData.append('image', file);

const response = await fetch('/api/admin/upload/articles', {
  method: 'POST',
  headers: { 'Authorization': `Bearer ${token}` },
  body: formData
});

const { data } = await response.json();
console.log(data.url); // /uploads/articles/image-123.jpg
```

## Files
- Middleware: `src/middleware/upload.js`
- Controller: `src/controllers/uploadController.js`
- Routes: `src/routes/admin.js`
- Tests: `test_image_upload.sh`
- Docs: `IMAGE_UPLOAD_SUMMARY.md`
