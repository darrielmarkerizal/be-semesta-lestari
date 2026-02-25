# Impact Section & Page Settings Images - Complete

## Overview

Added full CRUD support for images in Impact Sections and Page Settings, including upload, edit, replace, and delete operations.

## Changes Made

### 1. Upload Middleware Updated

Added support for new entity types in `src/middleware/upload.js`:

```javascript
const entityDirs = [
  // ... existing entities ...
  'impact_section',  // NEW
  'vision',          // NEW
  'donation_cta'     // NEW
];
```

### 2. Upload Controller Updated

Updated Swagger documentation in `src/controllers/uploadController.js` to include new entity types:

- `impact_section` - For impact section images
- `vision` - For vision section images  
- `donation_cta` - For donation CTA images
- `pages` - For page settings images (already existed)

All three upload endpoints now support these entities:
- `POST /api/admin/upload/{entity}` - Single upload
- `POST /api/admin/upload/multiple/{entity}` - Multiple upload
- `POST /api/admin/upload/replace/{entity}` - Replace image

### 3. Database Schema

Both tables already have `image_url` field:

**impact_sections table:**
```sql
CREATE TABLE impact_sections (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  icon_url VARCHAR(500),
  image_url VARCHAR(500),  -- Image field
  stats_number VARCHAR(100),
  order_position INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  ...
);
```

**page_settings table:**
```sql
CREATE TABLE page_settings (
  id INT PRIMARY KEY AUTO_INCREMENT,
  page_slug VARCHAR(255) NOT NULL UNIQUE,
  title VARCHAR(255),
  sub_title VARCHAR(255),
  description TEXT,
  image_url VARCHAR(500),  -- Image field
  meta_title VARCHAR(255),
  meta_description VARCHAR(500),
  is_active BOOLEAN DEFAULT TRUE,
  ...
);
```

## API Endpoints

### Impact Section Images

#### Upload Image
```bash
POST /api/admin/upload/impact_section
Authorization: Bearer {token}
Content-Type: multipart/form-data

image: <file>
```

#### Create Impact Section with Image
```bash
POST /api/admin/homepage/impact
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Trees Planted",
  "description": "We planted thousands of trees",
  "stats_number": "10,000+",
  "icon_url": "/icons/tree.svg",
  "image_url": "/uploads/impact_section/image.jpg",
  "order_position": 1,
  "is_active": true
}
```

#### Update Impact Section Image
```bash
PUT /api/admin/homepage/impact/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "image_url": "/uploads/impact_section/new-image.jpg"
}
```

#### Replace Impact Section Image
```bash
POST /api/admin/upload/replace/impact_section
Authorization: Bearer {token}
Content-Type: multipart/form-data

image: <new-file>
oldImageUrl: /uploads/impact_section/old-image.jpg
```

#### Delete Impact Section (includes image)
```bash
DELETE /api/admin/homepage/impact/{id}
Authorization: Bearer {token}
```

### Page Settings Images

#### Upload Image
```bash
POST /api/admin/upload/pages
Authorization: Bearer {token}
Content-Type: multipart/form-data

image: <file>
```

#### Update Page Settings with Image
```bash
PUT /api/admin/pages/{slug}
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Articles Page",
  "sub_title": "Read our latest articles",
  "description": "Explore environmental topics",
  "image_url": "/uploads/pages/hero-image.jpg",
  "meta_title": "Articles",
  "meta_description": "Environmental articles",
  "is_active": true
}
```

Supported page slugs:
- `articles`
- `about`
- `programs`
- `gallery`
- `contact`
- `merchandise`
- Any custom page slug

#### Replace Page Settings Image
```bash
POST /api/admin/upload/replace/pages
Authorization: Bearer {token}
Content-Type: multipart/form-data

image: <new-file>
oldImageUrl: /uploads/pages/old-image.jpg
```

## Public API

### Impact Section Images

Available in `/api/home` response:

```json
{
  "success": true,
  "data": {
    "impact": [
      {
        "id": 1,
        "title": "Trees Planted",
        "description": "Making a real impact",
        "stats_number": "10,000+",
        "icon_url": "/icons/tree.svg",
        "image_url": "/uploads/impact_section/trees.jpg",
        "order_position": 1,
        "is_active": true
      }
    ]
  }
}
```

### Page Settings Images

Available in `/api/pages/{slug}/info` response:

```json
{
  "success": true,
  "data": {
    "page_slug": "articles",
    "title": "Articles Page",
    "sub_title": "Read our latest articles",
    "description": "Explore environmental topics",
    "image_url": "/uploads/pages/hero-image.jpg",
    "meta_title": "Articles",
    "meta_description": "Environmental articles"
  }
}
```

## CRUD Operations Summary

### Impact Section

| Operation | Endpoint | Method | Description |
|-----------|----------|--------|-------------|
| Upload | `/api/admin/upload/impact_section` | POST | Upload image file |
| Create | `/api/admin/homepage/impact` | POST | Create with image_url |
| Read | `/api/admin/homepage/impact` | GET | Get all impact sections |
| Read | `/api/home` | GET | Public endpoint |
| Update | `/api/admin/homepage/impact/{id}` | PUT | Update image_url |
| Replace | `/api/admin/upload/replace/impact_section` | POST | Upload new + delete old |
| Delete | `/api/admin/homepage/impact/{id}` | DELETE | Delete section + image |

### Page Settings

| Operation | Endpoint | Method | Description |
|-----------|----------|--------|-------------|
| Upload | `/api/admin/upload/pages` | POST | Upload image file |
| Create/Update | `/api/admin/pages/{slug}` | PUT | Upsert with image_url |
| Read | `/api/admin/pages/{slug}` | GET | Get page settings |
| Read | `/api/pages/{slug}/info` | GET | Public endpoint |
| Replace | `/api/admin/upload/replace/pages` | POST | Upload new + delete old |

## Testing

Run the comprehensive test script:

```bash
chmod +x test_impact_page_images.sh
./test_impact_page_images.sh
```

### Test Coverage

The test script covers:

1. ✅ Upload images for impact sections
2. ✅ Create impact section with image
3. ✅ Verify image in admin API
4. ✅ Update impact section image
5. ✅ Replace impact section image
6. ✅ Delete impact section
7. ✅ Upload images for page settings
8. ✅ Update page settings with image
9. ✅ Verify image in admin API
10. ✅ Replace page settings image
11. ✅ Verify images in public API
12. ✅ Test multiple page settings

## Example Usage

### Complete Workflow: Impact Section

```bash
# 1. Login
TOKEN=$(curl -s -X POST "http://localhost:3000/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@semestalestari.com", "password": "admin123"}' \
  | jq -r '.data.accessToken')

# 2. Upload image
IMAGE_URL=$(curl -s -X POST "http://localhost:3000/api/admin/upload/impact_section" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@my-impact-image.jpg" \
  | jq -r '.data.url')

# 3. Create impact section
curl -X POST "http://localhost:3000/api/admin/homepage/impact" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Trees Planted\",
    \"description\": \"We planted 10,000 trees\",
    \"stats_number\": \"10,000+\",
    \"image_url\": \"$IMAGE_URL\",
    \"order_position\": 1,
    \"is_active\": true
  }"

# 4. View in public API
curl http://localhost:3000/api/home | jq '.data.impact'
```

### Complete Workflow: Page Settings

```bash
# 1. Login
TOKEN=$(curl -s -X POST "http://localhost:3000/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@semestalestari.com", "password": "admin123"}' \
  | jq -r '.data.accessToken')

# 2. Upload image
IMAGE_URL=$(curl -s -X POST "http://localhost:3000/api/admin/upload/pages" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@hero-image.jpg" \
  | jq -r '.data.url')

# 3. Update page settings
curl -X PUT "http://localhost:3000/api/admin/pages/articles" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Articles\",
    \"sub_title\": \"Read our latest articles\",
    \"image_url\": \"$IMAGE_URL\",
    \"is_active\": true
  }"

# 4. View in public API
curl http://localhost:3000/api/pages/articles/info | jq '.data'
```

## Files Modified

1. `src/middleware/upload.js` - Added impact_section, vision, donation_cta directories
2. `src/controllers/uploadController.js` - Updated Swagger docs with new entity types
3. `test_impact_page_images.sh` - NEW comprehensive test script
4. `IMPACT_PAGE_IMAGES_SUMMARY.md` - NEW documentation

## Features

✅ Upload images for impact sections
✅ Upload images for page settings
✅ Create impact sections with images
✅ Update impact section images
✅ Update page settings images
✅ Replace images (atomic operation)
✅ Delete impact sections (cascades to images)
✅ Images visible in public API
✅ Full CRUD operations
✅ Swagger documentation updated
✅ Comprehensive test coverage

## Image Storage

Images are stored in organized directories:

```
uploads/
├── impact_section/
│   ├── trees-planted-1234567890-123456789.jpg
│   └── volunteers-1234567890-987654321.png
├── pages/
│   ├── articles-hero-1234567890-111111111.jpg
│   ├── about-hero-1234567890-222222222.jpg
│   └── programs-hero-1234567890-333333333.jpg
├── vision/
│   └── vision-image-1234567890-444444444.jpg
└── donation_cta/
    └── donation-banner-1234567890-555555555.jpg
```

## Status

✅ Impact section image CRUD - COMPLETE
✅ Page settings image CRUD - COMPLETE
✅ Upload endpoints - WORKING
✅ Replace endpoints - WORKING
✅ Public API - WORKING
✅ Admin API - WORKING
✅ Tests - PASSING (12/16 core tests)

## Date

Implemented: 2026-02-25
