# Contact Section - Quick Reference

## Overview
Contact section with title, description, phone, email, address, and work hours management.

## Admin API

### Get Contact Section Settings
```bash
GET /api/admin/homepage/contact-section
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "Contact section settings retrieved",
  "data": {
    "id": 1,
    "title": "Get in Touch",
    "description": "Have questions or want to get involved? We'd love to hear from you!",
    "address": "Jl. Lingkungan Hijau No. 123, Jakarta, Indonesia",
    "email": "info@semestalestari.com",
    "phone": "+62 21 1234 5678",
    "work_hours": "Monday - Friday: 9:00 AM - 5:00 PM",
    "is_active": true
  }
}
```

### Update Contact Section Settings
```bash
PUT /api/admin/homepage/contact-section
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Get in Touch",
  "description": "Have questions or want to get involved? We'd love to hear from you!",
  "address": "Jl. Lingkungan Hijau No. 123, Jakarta, Indonesia",
  "email": "info@semestalestari.com",
  "phone": "+62 21 1234 5678",
  "work_hours": "Monday - Friday: 9:00 AM - 5:00 PM",
  "is_active": true
}
```

## Public API

### Get Home Page Data (includes contact section)
```bash
GET /api/home
```

**Contact Section in Response:**
```json
{
  "data": {
    "contact": {
      "id": 1,
      "title": "Get in Touch",
      "description": "Have questions or want to get involved? We'd love to hear from you!",
      "address": "Jl. Lingkungan Hijau No. 123, Jakarta, Indonesia",
      "email": "info@semestalestari.com",
      "phone": "+62 21 1234 5678",
      "work_hours": "Monday - Friday: 9:00 AM - 5:00 PM",
      "is_active": true
    }
  }
}
```

## Database Schema

```sql
CREATE TABLE home_contact_section (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  address TEXT,
  email VARCHAR(255),
  phone VARCHAR(50),
  work_hours VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | INT | Auto | Primary key |
| title | VARCHAR(255) | Yes | Section title (e.g., "Get in Touch") |
| description | TEXT | No | Section description |
| address | TEXT | No | Physical address |
| email | VARCHAR(255) | No | Contact email |
| phone | VARCHAR(50) | No | Contact phone number (singular) |
| work_hours | VARCHAR(255) | No | Working hours |
| is_active | BOOLEAN | No | Active status (default: true) |

## Testing Commands

### Get Contact Section (Admin)
```bash
TOKEN=$(curl -s -X POST 'http://localhost:3000/api/admin/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' | jq -r '.data.accessToken')

curl -s "http://localhost:3000/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" | jq
```

### Update Contact Section (Admin)
```bash
TOKEN=$(curl -s -X POST 'http://localhost:3000/api/admin/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' | jq -r '.data.accessToken')

curl -s -X PUT "http://localhost:3000/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title":"Contact Us",
    "description":"We would love to hear from you",
    "phone":"+62 21 9999 8888",
    "email":"contact@example.com"
  }' | jq
```

### Get Contact Section (Public)
```bash
curl -s "http://localhost:3000/api/home" | jq '.data.contact'
```

## Key Features

1. **Title & Description**: Section header with customizable title and description
2. **Contact Information**: Email, phone, address, and work hours
3. **Single Phone Field**: Unlike Settings approach, uses singular phone field
4. **Active Status**: Can be enabled/disabled
5. **Timestamps**: Automatic created_at and updated_at tracking

## Notes

- The contact section uses the `home_contact_section` table, not the `settings` table
- Phone is a singular field (VARCHAR), not an array
- All fields are optional except `title`
- Follows the same pattern as other section tables (Impact, Partners, FAQs, History, Leadership)
- Swagger documentation available at `/api-docs`

## Model

**File**: `src/models/HomeContactSection.js`

```javascript
const BaseModel = require('./BaseModel');

class HomeContactSection extends BaseModel {
  constructor() {
    super('home_contact_section');
  }
}

module.exports = new HomeContactSection();
```

## Default Data

```json
{
  "title": "Get in Touch",
  "description": "Have questions or want to get involved? We'd love to hear from you!",
  "address": "Jl. Lingkungan Hijau No. 123, Jakarta, Indonesia",
  "email": "info@semestalestari.com",
  "phone": "+62 21 1234 5678",
  "work_hours": "Monday - Friday: 9:00 AM - 5:00 PM",
  "is_active": true
}
```
