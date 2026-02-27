# Impact Section Update - Hero, Title & Subtitle

## Overview
Added hero image, title, and subtitle support to the impact section, allowing admins to customize the section header independently from the impact items.

## Changes Made

### 1. Database Schema

#### New Table: `home_impact_section`
```sql
CREATE TABLE home_impact_section (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  subtitle VARCHAR(255),
  image_url VARCHAR(500),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)
```

**Fields:**
- `title` - Section title (e.g., "Our Impact")
- `subtitle` - Section subtitle/description
- `image_url` - Optional hero/background image
- `is_active` - Enable/disable the section
- Timestamps for tracking

### 2. Models

**New File:** `src/models/HomeImpactSection.js`
- Extends BaseModel
- Manages impact section settings

### 3. API Endpoints

#### Public Endpoints

**GET /api/impact**
Returns impact section with header settings and items:
```json
{
  "success": true,
  "message": "Impact section retrieved",
  "data": {
    "section": {
      "id": 1,
      "title": "Our Amazing Impact",
      "subtitle": "Making a real difference in the world",
      "image_url": "/uploads/impact/hero.jpg",
      "is_active": 1
    },
    "items": [
      {
        "id": 1,
        "title": "Trees Planted",
        "description": "Trees planted across communities",
        "stats_number": "10,000+",
        "order_position": 1
      }
    ]
  }
}
```

**GET /api/home**
Impact section now includes both section settings and items:
```json
{
  "impact": {
    "section": {
      "title": "Our Amazing Impact",
      "subtitle": "Making a real difference in the world",
      "image_url": "/uploads/impact/hero.jpg"
    },
    "items": [...]
  }
}
```

#### Admin Endpoints (Require Authentication)

**GET /api/admin/homepage/impact-section**
- Get current impact section settings
- Returns: section object with title, subtitle, image_url

**PUT /api/admin/homepage/impact-section**
- Update impact section settings
- Body: `{ "title": "...", "subtitle": "...", "image_url": "..." }`
- Returns: updated section object

### 4. Controllers

**Updated:** `src/controllers/homeController.js`
- Modified `getImpact()` to include section settings
- Modified `getHomePage()` to structure impact data with section and items

**Updated:** `src/controllers/adminHomeController.js`
- Added `impactSectionController` with get/update methods
- Swagger documentation included

### 5. Routes

**Updated:** `src/routes/admin.js`
- Added `GET /api/admin/homepage/impact-section`
- Added `PUT /api/admin/homepage/impact-section`

### 6. Seed Data

**Default Values:**
- Title: "Our Impact"
- Subtitle: "See the difference we've made together"
- Image URL: null (can be set via admin)
- Active: true

## Usage Examples

### Get Impact Section (Public)
```bash
curl http://localhost:3000/api/impact
```

### Get Impact Section Settings (Admin)
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3000/api/admin/homepage/impact-section
```

### Update Impact Section Settings (Admin)
```bash
curl -X PUT http://localhost:3000/api/admin/homepage/impact-section \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Our Amazing Impact",
    "subtitle": "Making a real difference in the world",
    "image_url": "/uploads/impact/hero.jpg"
  }'
```

## Response Structure

### Before (Old Structure)
```json
{
  "data": [
    { "id": 1, "title": "Trees Planted", ... },
    { "id": 2, "title": "Communities Reached", ... }
  ]
}
```

### After (New Structure)
```json
{
  "data": {
    "section": {
      "title": "Our Impact",
      "subtitle": "See the difference we've made together",
      "image_url": null
    },
    "items": [
      { "id": 1, "title": "Trees Planted", ... },
      { "id": 2, "title": "Communities Reached", ... }
    ]
  }
}
```

## Files Modified

1. **src/scripts/initDatabase.js** - Added home_impact_section table
2. **src/scripts/seedDatabase.js** - Added seed data for impact section
3. **src/models/HomeImpactSection.js** - New model (created)
4. **src/controllers/homeController.js** - Updated getImpact and getHomePage
5. **src/controllers/adminHomeController.js** - Added impactSectionController
6. **src/routes/admin.js** - Added impact section routes

## Testing

### Test Public Endpoint
```bash
# Get impact section
curl http://localhost:3000/api/impact | jq '.data.section'

# Get home page (includes impact)
curl http://localhost:3000/api/home | jq '.data.impact'
```

### Test Admin Endpoints
```bash
# Login
TOKEN=$(curl -s -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' \
  | jq -r '.data.accessToken')

# Get settings
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/api/admin/homepage/impact-section | jq '.'

# Update settings
curl -X PUT http://localhost:3000/api/admin/homepage/impact-section \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "New Title",
    "subtitle": "New Subtitle",
    "image_url": "/uploads/impact/new-hero.jpg"
  }' | jq '.'
```

## Swagger Documentation

The new endpoints are documented in Swagger UI at `/api-docs/`:

**Tag:** Admin - Homepage

**Endpoints:**
- GET /api/admin/homepage/impact-section
- PUT /api/admin/homepage/impact-section

**Request/Response schemas included with examples**

## Migration

If you have an existing database:

1. Run database initialization:
```bash
node src/scripts/initDatabase.js
```

2. Run seed script to populate default data:
```bash
node src/scripts/seedDatabase.js
```

The new table will be created automatically, and default values will be inserted.

## Benefits

1. **Flexible Header Management** - Admins can customize section title and subtitle independently
2. **Hero Image Support** - Add background/hero images to the impact section
3. **Consistent Structure** - Matches other sections (programs, partners, FAQ)
4. **Backward Compatible** - Items structure remains unchanged
5. **Easy to Manage** - Simple GET/PUT endpoints for updates

## Notes

- The section settings are separate from impact items
- Only one section settings record exists (id: 1)
- Impact items continue to work as before with full CRUD operations
- The `image_url` field supports hero/background images for the section
- All changes are immediately reflected in public endpoints

## Summary

Successfully added hero image, title, and subtitle support to the impact section. The section now has:
- Customizable title and subtitle
- Optional hero/background image
- Admin endpoints for management
- Consistent structure with other homepage sections
- Complete Swagger documentation

**Status: COMPLETE** ✅
