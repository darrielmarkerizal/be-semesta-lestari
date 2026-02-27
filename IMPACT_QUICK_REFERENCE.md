# Impact Section - Quick Reference

## Public Endpoint

### Get Impact Section
```bash
GET /api/impact
```

**Response:**
```json
{
  "data": {
    "section": {
      "title": "Our Impact",
      "subtitle": "See the difference we've made together",
      "image_url": "/uploads/impact/hero.jpg"
    },
    "items": [
      {
        "title": "Trees Planted",
        "stats_number": "10,000+",
        "description": "Trees planted across communities"
      }
    ]
  }
}
```

## Admin Endpoints (Require Bearer Token)

### Section Settings

#### Get Settings
```bash
GET /api/admin/homepage/impact-section
Authorization: Bearer {token}
```

#### Update Settings
```bash
PUT /api/admin/homepage/impact-section
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Our Amazing Impact",
  "subtitle": "Making a real difference",
  "image_url": "/uploads/impact/hero.jpg"
}
```

### Impact Items

#### List All Items
```bash
GET /api/admin/homepage/impact
Authorization: Bearer {token}
```

#### Create Item
```bash
POST /api/admin/homepage/impact
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Trees Planted",
  "description": "Trees planted across communities",
  "stats_number": "10,000+",
  "icon_url": "/uploads/icons/tree.svg",
  "image_url": "/uploads/impact_section/trees.jpg",
  "order_position": 1,
  "is_active": true
}
```

#### Update Item
```bash
PUT /api/admin/homepage/impact/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "stats_number": "15,000+",
  "description": "Updated description"
}
```

#### Delete Item
```bash
DELETE /api/admin/homepage/impact/{id}
Authorization: Bearer {token}
```

## Structure

```
Impact Section
├── Section Settings (Header)
│   ├── title
│   ├── subtitle
│   └── image_url (hero image)
│
└── Impact Items (Stats)
    ├── Item 1: Trees Planted (10,000+)
    ├── Item 2: Communities (50+)
    └── Item 3: Volunteers (500+)
```

## Fields

### Section Settings
- `title` - Section title (required)
- `subtitle` - Section subtitle (optional)
- `image_url` - Hero/background image (optional)
- `is_active` - Enable/disable section

### Impact Items
- `title` - Item title (required)
- `description` - Item description
- `stats_number` - The stat/number (e.g., "10,000+")
- `icon_url` - Small icon for the item
- `image_url` - Main image for the item
- `order_position` - Display order
- `is_active` - Enable/disable item

## Authentication

```bash
# Get token
curl -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@semestalestari.com",
    "password": "admin123"
  }'
```

## Testing

```bash
# Run test script
./test_impact_section.sh

# View Swagger docs
open http://localhost:3000/api-docs/
```

## Common Tasks

### Update Section Title
```bash
TOKEN="your_token_here"
curl -X PUT http://localhost:3000/api/admin/homepage/impact-section \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"New Title"}'
```

### Add New Stat
```bash
TOKEN="your_token_here"
curl -X POST http://localhost:3000/api/admin/homepage/impact \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Hectares Restored",
    "stats_number": "100+",
    "description": "Hectares of land restored",
    "order_position": 4
  }'
```

### Update Stat Number
```bash
TOKEN="your_token_here"
curl -X PUT http://localhost:3000/api/admin/homepage/impact/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"stats_number":"20,000+"}'
```

## Documentation

- **Implementation:** IMPACT_SECTION_UPDATE.md
- **Swagger Update:** IMPACT_SWAGGER_UPDATE.md
- **Complete Summary:** IMPACT_COMPLETE_UPDATE.md
- **This Guide:** IMPACT_QUICK_REFERENCE.md

## Swagger UI

```
http://localhost:3000/api-docs/
```

**Tags:**
- Home - Public endpoints
- Admin - Homepage - Admin endpoints
