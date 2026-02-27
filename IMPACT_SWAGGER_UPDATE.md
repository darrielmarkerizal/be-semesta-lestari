# Impact Section - Swagger Documentation Update

## Overview
Updated Swagger documentation to reflect the new impact section structure with separate header settings and items.

## Changes Made

### 1. Public Endpoint Documentation

#### GET /api/impact

**Updated Swagger Documentation:**
```yaml
/api/impact:
  get:
    summary: Get impact section with header and items
    description: Returns impact section settings (title, subtitle, image) and all impact items
    tags:
      - Home
    responses:
      200:
        description: Impact section retrieved successfully
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
                  example: Impact section retrieved
                data:
                  type: object
                  properties:
                    section:
                      type: object
                      properties:
                        id: integer
                        title: string (e.g., "Our Impact")
                        subtitle: string (e.g., "See the difference...")
                        image_url: string (nullable)
                        is_active: boolean
                    items:
                      type: array
                      items:
                        type: object
                        properties:
                          id: integer
                          title: string (e.g., "Trees Planted")
                          description: string
                          icon_url: string (nullable)
                          image_url: string (nullable)
                          stats_number: string (e.g., "10,000+")
                          order_position: integer
                          is_active: boolean
```

**Key Changes:**
- Added detailed description explaining the endpoint returns both section and items
- Documented the nested structure with `section` and `items` properties
- Added example values for all fields
- Specified nullable fields

### 2. Admin Endpoints Documentation

#### GET /api/admin/homepage/impact

**Updated Swagger Documentation:**
```yaml
/api/admin/homepage/impact:
  get:
    summary: Get all impact items
    description: Returns all impact items (stats/achievements). Use /api/admin/homepage/impact-section for section header settings.
    tags:
      - Admin - Homepage
    security:
      - BearerAuth: []
    responses:
      200:
        description: Impact items retrieved successfully
        content:
          application/json:
            schema:
              type: object
              properties:
                success: boolean
                message: string
                data:
                  type: array
                  items:
                    type: object
                    properties:
                      id: integer
                      title: string (e.g., "Trees Planted")
                      description: string
                      icon_url: string (nullable)
                      image_url: string (nullable, "Main image for impact item")
                      stats_number: string (e.g., "10,000+")
                      order_position: integer
                      is_active: boolean
```

**Key Changes:**
- Clarified this endpoint returns impact items only
- Added note directing users to `/api/admin/homepage/impact-section` for header settings
- Changed terminology from "sections" to "items" for clarity
- Added detailed schema with examples

#### POST /api/admin/homepage/impact

**Updated Swagger Documentation:**
```yaml
post:
  summary: Create new impact item
  description: Create a new impact stat/achievement item
  requestBody:
    required: true
    content:
      application/json:
        schema:
          type: object
          required:
            - title
          properties:
            title:
              type: string
              example: Trees Planted
            description:
              type: string
              example: Trees planted across communities
            icon_url:
              type: string
              example: /uploads/icons/tree.svg
            image_url:
              type: string
              example: /uploads/impact_section/trees.jpg
              description: Main image for impact item
            stats_number:
              type: string
              example: 10,000+
            order_position:
              type: integer
              example: 1
            is_active:
              type: boolean
              example: true
```

**Key Changes:**
- Updated summary to "Create new impact item" (was "section")
- Added description clarifying this creates stat/achievement items
- Added example values for all fields
- Clarified image_url is for the item, not the section header

#### PUT /api/admin/homepage/impact/{id}

**Updated Swagger Documentation:**
```yaml
put:
  summary: Update impact item
  description: Update an existing impact stat/achievement item
  parameters:
    - name: id
      in: path
      required: true
      schema:
        type: integer
  requestBody:
    content:
      application/json:
        schema:
          type: object
          properties:
            title:
              type: string
              example: Trees Planted
            description:
              type: string
            icon_url:
              type: string
            image_url:
              type: string
              description: Main image for impact item
            stats_number:
              type: string
              example: 15,000+
            order_position:
              type: integer
            is_active:
              type: boolean
```

**Key Changes:**
- Updated summary to "Update impact item" (was "section")
- Added description for clarity
- Added example values
- Clarified image_url purpose

#### DELETE /api/admin/homepage/impact/{id}

**Updated Swagger Documentation:**
```yaml
delete:
  summary: Delete impact item
  description: Delete an impact stat/achievement item
```

**Key Changes:**
- Updated summary to "Delete impact item" (was "section")
- Added description for clarity

### 3. Impact Section Settings Endpoints

These endpoints were already documented in the previous update:

#### GET /api/admin/homepage/impact-section
- Get section header settings (title, subtitle, image_url)

#### PUT /api/admin/homepage/impact-section
- Update section header settings

## Terminology Clarification

### Before Update
- "Impact sections" - Ambiguous, could mean header or items

### After Update
- **Impact Section** - The header/container with title, subtitle, and hero image
- **Impact Items** - Individual stats/achievements (Trees Planted, Volunteers, etc.)

## API Structure Summary

```
Impact Section (Container)
├── Section Settings (/api/admin/homepage/impact-section)
│   ├── title: "Our Impact"
│   ├── subtitle: "See the difference..."
│   └── image_url: "/uploads/impact/hero.jpg"
│
└── Impact Items (/api/admin/homepage/impact)
    ├── Item 1: Trees Planted (10,000+)
    ├── Item 2: Communities Reached (50+)
    └── Item 3: Volunteers (500+)
```

## Swagger UI Access

View the updated documentation at:
```
http://localhost:3000/api-docs/
```

### Sections to Check:
1. **Home** tag - Public `/api/impact` endpoint
2. **Admin - Homepage** tag - Admin impact management endpoints

## Testing the Documentation

### 1. View in Swagger UI
```bash
open http://localhost:3000/api-docs/
```

### 2. Test Public Endpoint
Navigate to "Home" → "GET /api/impact" → Try it out → Execute

Expected response structure:
```json
{
  "data": {
    "section": { "title": "...", "subtitle": "...", "image_url": "..." },
    "items": [...]
  }
}
```

### 3. Test Admin Endpoints
1. Authenticate via "Authentication" section
2. Navigate to "Admin - Homepage"
3. Test:
   - GET /api/admin/homepage/impact (returns items array)
   - GET /api/admin/homepage/impact-section (returns section object)
   - POST /api/admin/homepage/impact (create item)
   - PUT /api/admin/homepage/impact/{id} (update item)
   - PUT /api/admin/homepage/impact-section (update section)

## Files Modified

1. **src/controllers/homeController.js**
   - Updated `/api/impact` Swagger documentation
   - Added detailed response schema
   - Added examples for all fields

2. **src/controllers/adminHomeController.js**
   - Updated `/api/admin/homepage/impact` GET documentation
   - Updated `/api/admin/homepage/impact` POST documentation
   - Updated `/api/admin/homepage/impact/{id}` PUT documentation
   - Updated `/api/admin/homepage/impact/{id}` DELETE documentation
   - Clarified terminology (items vs section)

## Benefits

1. **Clear Documentation** - Users understand the difference between section settings and items
2. **Better Examples** - All fields have example values
3. **Proper Descriptions** - Each endpoint has a clear description
4. **Consistent Terminology** - "Items" for stats, "Section" for header
5. **Easy Discovery** - Users can find the right endpoint for their needs

## Migration Notes

No code changes required - this is documentation only. The API behavior remains the same, only the Swagger documentation was updated for clarity.

## Quick Reference

### Managing Impact Section Header
```bash
# Get section settings
GET /api/admin/homepage/impact-section

# Update section settings
PUT /api/admin/homepage/impact-section
Body: { "title": "...", "subtitle": "...", "image_url": "..." }
```

### Managing Impact Items
```bash
# Get all items
GET /api/admin/homepage/impact

# Create item
POST /api/admin/homepage/impact
Body: { "title": "Trees Planted", "stats_number": "10,000+", ... }

# Update item
PUT /api/admin/homepage/impact/{id}
Body: { "stats_number": "15,000+", ... }

# Delete item
DELETE /api/admin/homepage/impact/{id}
```

### Public Access
```bash
# Get complete impact section (header + items)
GET /api/impact
```

## Summary

✅ Updated public endpoint documentation with detailed response structure  
✅ Updated admin endpoints documentation with clear terminology  
✅ Added descriptions to clarify endpoint purposes  
✅ Added example values for all fields  
✅ Clarified the difference between section settings and items  
✅ Improved discoverability in Swagger UI  

All Swagger documentation is now accurate and reflects the current API structure with separate section settings and impact items.

**Status: COMPLETE** ✅
