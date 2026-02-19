# Vision, Donation CTA, and Impact Section Images Implementation

## Overview
Added `image_url` field support to Vision, Donation CTA, and Impact sections in the home page API.

## Changes Made

### 1. Database Schema Updates

#### Migration Script
Created `src/scripts/addImageUrlColumns.js` to add `image_url` columns to existing databases:
- Added `image_url VARCHAR(500)` to `visions` table
- Added `image_url VARCHAR(500)` to `impact_sections` table
- `donation_ctas` table already had `image_url` field

#### Updated initDatabase.js
Modified table creation scripts to include `image_url` field:

```sql
-- Visions table
CREATE TABLE IF NOT EXISTS visions (
  ...
  icon_url VARCHAR(500),
  image_url VARCHAR(500),  -- NEW
  ...
)

-- Impact sections table
CREATE TABLE IF NOT EXISTS impact_sections (
  ...
  icon_url VARCHAR(500),
  image_url VARCHAR(500),  -- NEW
  ...
)

-- Donation CTAs table (already had image_url)
CREATE TABLE IF NOT EXISTS donation_ctas (
  ...
  image_url VARCHAR(500),
  ...
)
```

### 2. API Documentation Updates

#### Admin Endpoints (src/controllers/adminHomeController.js)
Updated Swagger documentation for:

- `PUT /api/admin/homepage/vision` - Added `image_url` field
- `POST /api/admin/homepage/impact` - Added `image_url` field
- `PUT /api/admin/homepage/impact/:id` - Added `image_url` field
- `PUT /api/admin/homepage/donation-cta/:id` - Added `image_url` field

#### Public Endpoints (src/controllers/homeController.js)
Updated Swagger documentation for `/api/home` response to include `image_url` in:
- `vision` object
- `donationCta` object
- `impact` array items

### 3. Models
No changes needed - models use BaseModel which automatically handles all fields.

### 4. Test Script
Created `test_home_images.sh` with comprehensive tests:
- Upload images for vision, donation CTA, and impact sections
- Update sections with image URLs
- Verify images appear in `/api/home` response
- Test image replacement functionality
- Verify admin GET endpoints return image URLs

## API Usage

### Upload Images

```bash
# Upload vision image
POST /api/admin/upload/vision
Content-Type: multipart/form-data
Authorization: Bearer {token}

image: <file>

# Upload donation CTA image
POST /api/admin/upload/donation_cta
Content-Type: multipart/form-data
Authorization: Bearer {token}

image: <file>

# Upload impact section image
POST /api/admin/upload/impact_section
Content-Type: multipart/form-data
Authorization: Bearer {token}

image: <file>
```

### Update Sections with Images

```bash
# Update vision
PUT /api/admin/homepage/vision
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Our Vision",
  "description": "Vision description",
  "icon_url": "/uploads/vision/icon.png",
  "image_url": "/uploads/vision/image.png",
  "is_active": true
}

# Update donation CTA
PUT /api/admin/homepage/donation-cta/1
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Support Our Cause",
  "description": "Your donation helps",
  "button_text": "Donate Now",
  "button_url": "/donate",
  "image_url": "/uploads/donation_cta/image.png",
  "is_active": true
}

# Create impact section
POST /api/admin/homepage/impact
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Trees Planted",
  "description": "We planted thousands of trees",
  "stats_number": "10,000+",
  "icon_url": "/uploads/impact_section/icon.png",
  "image_url": "/uploads/impact_section/image.png",
  "order_position": 1,
  "is_active": true
}
```

### Public API Response

```bash
GET /api/home
```

Response includes:
```json
{
  "success": true,
  "data": {
    "vision": {
      "id": 1,
      "title": "Our Vision",
      "description": "...",
      "icon_url": "/uploads/vision/icon.png",
      "image_url": "/uploads/vision/image.png"
    },
    "donationCta": {
      "id": 1,
      "title": "Support Our Cause",
      "description": "...",
      "button_text": "Donate Now",
      "button_url": "/donate",
      "image_url": "/uploads/donation_cta/image.png"
    },
    "impact": [
      {
        "id": 1,
        "title": "Trees Planted",
        "description": "...",
        "stats_number": "10,000+",
        "icon_url": "/uploads/impact_section/icon.png",
        "image_url": "/uploads/impact_section/image.png"
      }
    ]
  }
}
```

## Running the Migration

For existing databases, run the migration script:

```bash
node src/scripts/addImageUrlColumns.js
```

This will add the `image_url` columns to `visions` and `impact_sections` tables if they don't already exist.

## Testing

Run the comprehensive test script:

```bash
chmod +x test_home_images.sh
./test_home_images.sh
```

Note: The test script may hit rate limits if run multiple times quickly. Wait 15 minutes between runs if you encounter "Too many login attempts" errors.

## Files Modified

1. `src/scripts/initDatabase.js` - Added `image_url` columns to table schemas
2. `src/scripts/addImageUrlColumns.js` - NEW migration script
3. `src/controllers/adminHomeController.js` - Updated Swagger docs
4. `src/controllers/homeController.js` - Updated Swagger docs
5. `test_home_images.sh` - NEW comprehensive test script

## Summary

All three sections (Vision, Donation CTA, and Impact) now support images:
- ✅ Database schema updated with `image_url` fields
- ✅ Migration script created for existing databases
- ✅ API documentation updated
- ✅ Image upload endpoints work with all three entity types
- ✅ Public `/api/home` endpoint returns images
- ✅ Admin endpoints support CRUD operations with images
- ✅ Test script created for verification

The implementation is complete and ready for use!
