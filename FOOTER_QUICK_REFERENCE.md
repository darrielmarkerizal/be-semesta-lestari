# Footer API Quick Reference

## Public Endpoint

### Get Footer Data
```bash
GET /api/footer
```

**Response includes:**
- Contact information (email, phones, address, work hours)
- Social media links (Facebook, Instagram, Twitter, YouTube, LinkedIn, TikTok)
- Program categories (name, slug, description, icon)

## Admin Endpoints (Require Bearer Token)

### Program Categories

#### List All
```bash
GET /api/admin/program-categories
Authorization: Bearer {token}
```

#### Create New
```bash
POST /api/admin/program-categories
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Category Name",
  "slug": "category-slug",
  "description": "Category description",
  "icon": "🌳",
  "order_position": 1,
  "is_active": true
}
```

#### Get Single
```bash
GET /api/admin/program-categories/:id
Authorization: Bearer {token}
```

#### Update
```bash
PUT /api/admin/program-categories/:id
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Updated Name",
  "description": "Updated description"
}
```

#### Delete
```bash
DELETE /api/admin/program-categories/:id
Authorization: Bearer {token}
```

### Settings Management

#### Get Setting
```bash
GET /api/admin/config/:key
Authorization: Bearer {token}
```

#### Update Setting
```bash
PUT /api/admin/config/:key
Authorization: Bearer {token}
Content-Type: application/json

{
  "value": "new value"
}
```

## Settings Keys

### Contact Information
- `contact_email`
- `contact_phones` (JSON array)
- `contact_address`
- `contact_work_hours`

### Social Media
- `social_facebook`
- `social_instagram`
- `social_twitter`
- `social_youtube`
- `social_linkedin`
- `social_tiktok`

## Default Program Categories

1. **Conservation** (🌳) - conservation
2. **Education** (📚) - education
3. **Community** (👥) - community
4. **Research** (🔬) - research

## Test Scripts

```bash
# Test footer endpoint
./test_footer_api.sh

# Test program categories CRUD
./test_program_categories.sh
```

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

## Database Migration

```bash
# Add category_id to programs table
node src/scripts/addProgramCategoryId.js

# Seed all data
node src/scripts/seedDatabase.js
```
