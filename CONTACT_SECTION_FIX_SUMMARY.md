# Contact Section Fix - Summary

## Issue
The contact section was not showing or saving the `title`, `description`, and `phone` fields. The admin endpoint was using the Settings model instead of the HomeContactSection model.

## Root Cause
The `contactSectionController` in `src/controllers/adminHomeController.js` was redirecting to `contactController` methods which used the Settings table. This meant:
- Data was stored in the `settings` table instead of `home_contact_section` table
- Fields like `title`, `description`, and `phone` (singular) were not accessible
- The `home_contact_section` table structure was not being utilized

## Solution

### 1. Updated Admin Controller
**File**: `src/controllers/adminHomeController.js`

Changed the `contactSectionController` to use the `HomeContactSection` model directly:

```javascript
const contactSectionController = {
  get: async (req, res, next) => {
    try {
      const section = await require('../models/HomeContactSection').getFirst();
      return require("../utils/response").successResponse(
        res,
        section,
        "Contact section settings retrieved",
      );
    } catch (error) {
      next(error);
    }
  },
  update: async (req, res, next) => {
    try {
      const section = await require('../models/HomeContactSection').getFirst();
      const updated = await require('../models/HomeContactSection').update(
        section?.id || 1,
        req.body,
      );
      return require("../utils/response").successResponse(
        res,
        updated,
        "Contact section settings updated",
      );
    } catch (error) {
      next(error);
    }
  },
};
```

### 2. Updated Public Endpoint
**File**: `src/controllers/homeController.js`

Updated the `/api/home` endpoint to use `HomeContactSection` model instead of Settings:

**Before:**
```javascript
Settings.findByKey('contact_email'),
Settings.findByKey('contact_phones'),
Settings.findByKey('contact_address'),
Settings.findByKey('contact_work_hours'),
```

**After:**
```javascript
require('../models/HomeContactSection').getFirst(),
```

**Response structure changed from:**
```json
{
  "contact": {
    "email": "...",
    "phones": ["...", "..."],
    "address": "...",
    "work_hours": "..."
  }
}
```

**To:**
```json
{
  "contact": {
    "id": 1,
    "title": "Get in Touch",
    "description": "Have questions or want to get involved? We'd love to hear from you!",
    "address": "Jl. Lingkungan Hijau No. 123, Jakarta, Indonesia",
    "email": "info@semestalestari.com",
    "phone": "+62 21 1234 5678",
    "work_hours": "Monday - Friday: 9:00 AM - 5:00 PM",
    "is_active": 1,
    "created_at": "...",
    "updated_at": "..."
  }
}
```

## Database Schema

### home_contact_section Table
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

## API Endpoints

### Admin Endpoint
```
GET /api/admin/homepage/contact-section
PUT /api/admin/homepage/contact-section
```

**Request Body (PUT):**
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

**Response:**
```json
{
  "success": true,
  "message": "Contact section settings updated",
  "data": {
    "id": 1,
    "title": "Get in Touch",
    "description": "Have questions or want to get involved? We'd love to hear from you!",
    "address": "Jl. Lingkungan Hijau No. 123, Jakarta, Indonesia",
    "email": "info@semestalestari.com",
    "phone": "+62 21 1234 5678",
    "work_hours": "Monday - Friday: 9:00 AM - 5:00 PM",
    "is_active": 1,
    "created_at": "2026-02-19T04:42:02.000Z",
    "updated_at": "2026-02-27T11:51:48.000Z"
  }
}
```

### Public Endpoint
```
GET /api/home
```

The contact section is now included in the home page data with all fields visible.

## Testing

### Test Admin GET
```bash
TOKEN=$(curl -s -X POST 'http://localhost:3000/api/admin/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' | jq -r '.data.accessToken')

curl -s "http://localhost:3000/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" | jq
```

### Test Admin PUT
```bash
TOKEN=$(curl -s -X POST 'http://localhost:3000/api/admin/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' | jq -r '.data.accessToken')

curl -s -X PUT "http://localhost:3000/api/admin/homepage/contact-section" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title":"Contact Us",
    "description":"Get in touch with us",
    "phone":"+62 21 9999 8888"
  }' | jq
```

### Test Public Endpoint
```bash
curl -s "http://localhost:3000/api/home" | jq '.data.contact'
```

## Files Modified

1. `src/controllers/adminHomeController.js` - Updated contactSectionController
2. `src/controllers/homeController.js` - Updated getHomePage() to use HomeContactSection

## Key Changes

1. ✅ `title` field now visible and editable
2. ✅ `description` field now visible and editable
3. ✅ `phone` field (singular) now visible and editable
4. ✅ All fields properly saved to `home_contact_section` table
5. ✅ Public endpoint returns complete contact section data
6. ✅ Admin endpoint allows full CRUD operations on contact section

## Notes

- The `phone` field in `home_contact_section` is singular (VARCHAR), not an array like in the Settings approach
- The `home_contact_section` table follows the same pattern as other section tables (Impact, Partners, FAQs, History, Leadership)
- Swagger documentation was already correct and didn't need updates
- The Settings table still exists and can be used for other global settings, but contact section now uses its dedicated table

## Conclusion

The contact section now properly uses the `home_contact_section` table and all fields (title, description, phone, email, address, work_hours) are visible and editable through both admin and public endpoints.
