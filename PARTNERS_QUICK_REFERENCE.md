# Partners Section - Quick Reference

## Overview
Partners section with header settings (title, subtitle, image) and partner items list.

## API Endpoints

### Public Endpoints

#### GET /api/partners
Returns partners section with header and items.

**Response:**
```json
{
  "success": true,
  "message": "Partners section retrieved",
  "data": {
    "section": {
      "id": 1,
      "title": "Our Partners",
      "subtitle": "Working together for a sustainable future",
      "image_url": "/uploads/partners/hero.jpg",
      "is_active": true
    },
    "items": [
      {
        "id": 1,
        "name": "Green Earth Foundation",
        "description": "Environmental conservation partner",
        "logo_url": "/uploads/partners/logo.png",
        "website": "https://greenearth.org",
        "order_position": 1,
        "is_active": true
      }
    ]
  }
}
```

### Admin Endpoints

#### GET /api/admin/homepage/partners-section
Get partners section settings.

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "Our Partners",
    "subtitle": "Working together for a sustainable future",
    "image_url": "/uploads/partners/hero.jpg",
    "is_active": true
  }
}
```

#### PUT /api/admin/homepage/partners-section
Update partners section settings.

**Headers:** `Authorization: Bearer {token}`

**Body:**
```json
{
  "title": "Our Amazing Partners",
  "subtitle": "Building a sustainable future together",
  "image_url": "/uploads/partners/new-hero.jpg"
}
```

#### GET /api/admin/partners
List all partner items (paginated).

**Headers:** `Authorization: Bearer {token}`

**Query Params:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)

#### GET /api/admin/partners/:id
Get single partner item.

**Headers:** `Authorization: Bearer {token}`

#### POST /api/admin/partners
Create new partner item.

**Headers:** `Authorization: Bearer {token}`

**Body:**
```json
{
  "name": "New Partner",
  "description": "Partner description",
  "logo_url": "/uploads/partners/logo.png",
  "website": "https://partner.com",
  "order_position": 1,
  "is_active": true
}
```

#### PUT /api/admin/partners/:id
Update partner item.

**Headers:** `Authorization: Bearer {token}`

**Body:**
```json
{
  "name": "Updated Partner Name",
  "description": "Updated description",
  "website": "https://newwebsite.com"
}
```

#### DELETE /api/admin/partners/:id
Delete partner item.

**Headers:** `Authorization: Bearer {token}`

## Database Tables

### home_partners_section
Section header settings.

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| title | VARCHAR(255) | Section title |
| subtitle | VARCHAR(255) | Section subtitle |
| image_url | VARCHAR(500) | Hero image URL |
| is_active | BOOLEAN | Active status |
| created_at | TIMESTAMP | Creation time |
| updated_at | TIMESTAMP | Last update time |

### partners
Partner items.

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| name | VARCHAR(255) | Partner name |
| description | TEXT | Partner description |
| logo_url | VARCHAR(500) | Partner logo URL |
| website | VARCHAR(500) | Partner website |
| order_position | INT | Display order |
| is_active | BOOLEAN | Active status |
| created_at | TIMESTAMP | Creation time |
| updated_at | TIMESTAMP | Last update time |

## Testing

Run complete test suite:
```bash
./test_partners_complete.sh
```

**Test Coverage:**
- 68 total tests
- 100% success rate
- Public endpoints (12 tests)
- Admin section settings (10 tests)
- Admin partner items CRUD (14 tests)
- Data structure validation (18 tests)
- Authorization (6 tests)
- Edge cases (8 tests)

## Common Tasks

### Update Section Header
```bash
curl -X PUT http://localhost:3000/api/admin/homepage/partners-section \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Our Partners",
    "subtitle": "Working together",
    "image_url": "/uploads/partners/hero.jpg"
  }'
```

### Add New Partner
```bash
curl -X POST http://localhost:3000/api/admin/partners \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Partner Name",
    "description": "Partner description",
    "logo_url": "/uploads/partners/logo.png",
    "website": "https://partner.com",
    "order_position": 1,
    "is_active": true
  }'
```

### Get Partners (Public)
```bash
curl http://localhost:3000/api/partners
```

## Files

- `src/models/Partner.js` - Partner items model
- `src/models/HomePartnersSection.js` - Section settings model
- `src/controllers/partnerController.js` - Partner controllers
- `src/controllers/adminHomeController.js` - Admin section controller
- `src/scripts/addPartnersImageUrl.js` - Migration script
- `src/scripts/cleanupPartnersSectionDuplicates.js` - Cleanup script
- `test_partners_complete.sh` - Test script
- `PARTNERS_TEST_REPORT.md` - Detailed test report

## Notes

- Section and items are separate tables (no foreign key relationship)
- Public endpoint returns both section and items in one call
- Admin endpoints manage section and items separately
- Pattern matches impact section implementation
- All tests passing at 100%
