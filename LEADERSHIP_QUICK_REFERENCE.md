# Leadership Section - Quick Reference

## Overview
Leadership section with hero image, title, subtitle, and team member management.

## Public API

### Get Leadership Section
```bash
GET /api/about/leadership
```

**Response:**
```json
{
  "success": true,
  "message": "Leadership section retrieved",
  "data": {
    "section": {
      "id": 1,
      "title": "Our Leadership",
      "subtitle": "Meet the team driving environmental change",
      "image_url": "/uploads/leadership/hero.jpg",
      "is_active": true
    },
    "items": [
      {
        "id": 1,
        "name": "Dr. Budi Santoso",
        "position": "Founder & CEO",
        "bio": "Environmental scientist...",
        "image_url": "/uploads/leadership/budi.jpg",
        "email": "budi.santoso@semestalestari.com",
        "phone": "+62 812 3456 7890",
        "linkedin_link": "https://linkedin.com/in/budisantoso",
        "instagram_link": "https://instagram.com/budisantoso",
        "is_highlighted": true,
        "order_position": 1,
        "is_active": true
      }
    ]
  }
}
```

## Admin API

### Section Settings

#### Get Section Settings
```bash
GET /api/admin/about/leadership-section
Authorization: Bearer {token}
```

#### Update Section Settings
```bash
PUT /api/admin/about/leadership-section
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Our Leadership",
  "subtitle": "Meet the team driving environmental change",
  "image_url": "/uploads/leadership/hero.jpg",
  "is_active": true
}
```

### Leadership Items CRUD

#### List All Items
```bash
GET /api/admin/about/leadership
Authorization: Bearer {token}
```

#### Get Single Item
```bash
GET /api/admin/about/leadership/:id
Authorization: Bearer {token}
```

#### Create Item
```bash
POST /api/admin/about/leadership
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Dr. Budi Santoso",
  "position": "Founder & CEO",
  "bio": "Environmental scientist with 20+ years of experience",
  "image_url": "/uploads/leadership/budi.jpg",
  "email": "budi.santoso@semestalestari.com",
  "phone": "+62 812 3456 7890",
  "linkedin_link": "https://linkedin.com/in/budisantoso",
  "instagram_link": "https://instagram.com/budisantoso",
  "is_highlighted": true,
  "order_position": 1,
  "is_active": true
}
```

#### Update Item
```bash
PUT /api/admin/about/leadership/:id
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Dr. Budi Santoso",
  "position": "Founder & CEO"
}
```

#### Delete Item
```bash
DELETE /api/admin/about/leadership/:id
Authorization: Bearer {token}
```

## Database Schema

### leadership_section Table
```sql
CREATE TABLE leadership_section (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  subtitle VARCHAR(255),
  image_url VARCHAR(500),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### leadership Table
```sql
CREATE TABLE leadership (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  position VARCHAR(255) NOT NULL,
  bio TEXT,
  image_url VARCHAR(500),
  email VARCHAR(255),
  phone VARCHAR(20),
  linkedin_link VARCHAR(500),
  instagram_link VARCHAR(500),
  is_highlighted BOOLEAN DEFAULT FALSE,
  order_position INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## Testing

### Run Complete Test Suite
```bash
./test_leadership_complete.sh
```

**Expected Result:** 42/42 tests passing (100%)

## Key Features

1. **Section Header Management**
   - Title, subtitle, hero image
   - Single record per section
   - Admin-only updates

2. **Leadership Items Management**
   - Full CRUD operations
   - Team member profiles
   - Social media links
   - Highlighted members
   - Order positioning

3. **Public Access**
   - Combined section + items response
   - No authentication required
   - Only active items shown

4. **Admin Access**
   - Separate section and items management
   - Authentication required
   - Full CRUD capabilities

## Pattern Consistency

Follows the same pattern as:
- Impact Section
- Partners Section
- FAQs Section
- History Section

All sections share:
- Separate tables for settings and items
- Section + items response structure
- Admin CRUD operations
- Swagger documentation
- 100% test coverage
