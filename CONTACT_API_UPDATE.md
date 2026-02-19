# Contact API Update

## Summary
Updated the Contact API to include comprehensive contact information (email, phones, address, work_hours) and reorganized admin endpoints under `/api/admin/contact/`.

## Date
February 19, 2026

---

## Changes Made

### 1. Contact Info Endpoint Updates

#### Public Endpoint: `/api/contact/info`
**Previous Response:**
```json
{
  "email": "info@semestalestari.org",
  "phone": "+62 123 4567 890",
  "address": "Jakarta, Indonesia"
}
```

**New Response:**
```json
{
  "email": "info@semestalestari.org",
  "phones": [
    "(+62) 21-1234-5678",
    "(+62) 812-3456-7890"
  ],
  "address": "Jl. Lingkungan Hijau No. 123, Jakarta Selatan, DKI Jakarta 12345, Indonesia",
  "work_hours": "Monday - Friday: 09:00 AM - 05:00 PM\nSaturday: 09:00 AM - 01:00 PM\nSunday: Closed"
}
```

**Changes:**
- Changed `phone` (string) to `phones` (array) to support multiple phone numbers
- Added `work_hours` field for business hours information
- Enhanced `address` with full detailed address

---

### 2. Admin Endpoints Reorganization

#### Previous Structure:
```
GET    /api/admin/messages
GET    /api/admin/messages/:id
PUT    /api/admin/messages/:id/read
DELETE /api/admin/messages/:id
```

#### New Structure:
```
# Contact Messages
GET    /api/admin/contact/show-messages
GET    /api/admin/contact/show-messages/:id
PUT    /api/admin/contact/show-messages/:id/read
DELETE /api/admin/contact/show-messages/:id

# Contact Info Management
GET    /api/admin/contact/info
PUT    /api/admin/contact/info
```

**Benefits:**
- Better organization under `/api/admin/contact/` namespace
- Clear separation between messages and contact info
- More intuitive endpoint naming

---

## New Features

### Admin Contact Info Management

#### Get Contact Info (Admin)
```bash
GET /api/admin/contact/info
Authorization: Bearer YOUR_TOKEN
```

**Response:**
```json
{
  "success": true,
  "message": "Contact info retrieved",
  "data": {
    "email": "info@semestalestari.org",
    "phones": ["(+62) 21-1234-5678", "(+62) 812-3456-7890"],
    "address": "Jl. Lingkungan Hijau No. 123, Jakarta Selatan, DKI Jakarta 12345, Indonesia",
    "work_hours": "Monday - Friday: 09:00 AM - 05:00 PM\nSaturday: 09:00 AM - 01:00 PM\nSunday: Closed"
  }
}
```

#### Update Contact Info
```bash
PUT /api/admin/contact/info
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "email": "info@semestalestari.org",
  "phones": ["(+62) 21-1234-5678", "(+62) 812-3456-7890"],
  "address": "Jl. Lingkungan Hijau No. 123, Jakarta Selatan",
  "work_hours": "Monday - Friday: 09:00 AM - 05:00 PM"
}
```

**Features:**
- Partial updates supported (only send fields you want to update)
- Phones stored as JSON array in database
- All fields are optional in update request

---

## Database Changes

### Settings Table Updates

**New Settings Keys:**
- `contact_email` - Email address
- `contact_phones` - JSON array of phone numbers
- `contact_address` - Full address
- `contact_work_hours` - Business hours (supports multiline with \n)

**Example Data:**
```sql
INSERT INTO settings (`key`, value) VALUES
  ('contact_email', 'info@semestalestari.org'),
  ('contact_phones', '["(+62) 21-1234-5678", "(+62) 812-3456-7890"]'),
  ('contact_address', 'Jl. Lingkungan Hijau No. 123, Jakarta Selatan, DKI Jakarta 12345, Indonesia'),
  ('contact_work_hours', 'Monday - Friday: 09:00 AM - 05:00 PM\nSaturday: 09:00 AM - 01:00 PM\nSunday: Closed');
```

---

## API Endpoints Reference

### Public Endpoints

#### Get Contact Info
```bash
GET /api/contact/info
```
Returns email, phones array, address, and work hours.

#### Send Contact Message
```bash
POST /api/contact/send-message
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+62 812 3456 7890",
  "subject": "Inquiry",
  "message": "Your message here"
}
```

### Admin Endpoints (Require Authentication)

#### Get All Messages
```bash
GET /api/admin/contact/show-messages?page=1&limit=10
Authorization: Bearer YOUR_TOKEN
```

#### Get Single Message
```bash
GET /api/admin/contact/show-messages/:id
Authorization: Bearer YOUR_TOKEN
```

#### Mark Message as Read
```bash
PUT /api/admin/contact/show-messages/:id/read
Authorization: Bearer YOUR_TOKEN
```

#### Delete Message
```bash
DELETE /api/admin/contact/show-messages/:id
Authorization: Bearer YOUR_TOKEN
```

#### Get Contact Info (Admin)
```bash
GET /api/admin/contact/info
Authorization: Bearer YOUR_TOKEN
```

#### Update Contact Info
```bash
PUT /api/admin/contact/info
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "email": "new@email.com",
  "phones": ["+62 xxx", "+62 yyy"],
  "address": "New address",
  "work_hours": "New hours"
}
```

---

## Swagger Documentation Updates

### Tags Updated
- Changed `Admin - Messages` to `Admin - Contact`
- All contact-related endpoints now grouped under "Admin - Contact" tag

### New Swagger Schemas
- Contact info response schema with phones array
- Contact info update request schema
- Detailed examples for all fields

---

## Testing Examples

### Test Public Contact Info
```bash
curl "http://localhost:3000/api/contact/info"
```

### Test Admin Get Contact Info
```bash
# Get token
TOKEN=$(curl -s -X POST "http://localhost:3000/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['accessToken'])")

# Get contact info
curl "http://localhost:3000/api/admin/contact/info" \
  -H "Authorization: Bearer $TOKEN"
```

### Test Update Contact Info
```bash
curl -X PUT "http://localhost:3000/api/admin/contact/info" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "info@semestalestari.org",
    "phones": ["(+62) 21-1234-5678", "(+62) 812-3456-7890"],
    "address": "Jl. Lingkungan Hijau No. 123, Jakarta Selatan, DKI Jakarta 12345, Indonesia",
    "work_hours": "Monday - Friday: 09:00 AM - 05:00 PM\nSaturday: 09:00 AM - 01:00 PM\nSunday: Closed"
  }'
```

### Test Send Message
```bash
curl -X POST "http://localhost:3000/api/contact/send-message" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+62 812 3456 7890",
    "subject": "Inquiry",
    "message": "I would like to know more about your programs."
  }'
```

### Test Get Messages
```bash
curl "http://localhost:3000/api/admin/contact/show-messages" \
  -H "Authorization: Bearer $TOKEN"
```

---

## Files Modified

1. **src/controllers/contactController.js**
   - Updated `getContactInfo()` to return phones array, address, and work_hours
   - Added `getContactInfoAdmin()` for admin access
   - Added `updateContactInfo()` for updating contact info
   - Updated all Swagger documentation tags to "Admin - Contact"

2. **src/routes/admin.js**
   - Changed `/api/admin/messages` to `/api/admin/contact/show-messages`
   - Added `/api/admin/contact/info` GET and PUT endpoints

3. **src/scripts/seedDatabase.js**
   - Updated contact settings with new structure
   - Changed `contact_phone` to `contact_phones` (JSON array)
   - Added `contact_work_hours` setting
   - Enhanced address with full details

4. **src/utils/swagger.js**
   - Changed tag from "Admin - Messages" to "Admin - Contact"

---

## Migration Notes

### For Frontend Developers

**Breaking Changes:**
1. Contact info response now has `phones` (array) instead of `phone` (string)
2. Admin message endpoints moved from `/api/admin/messages` to `/api/admin/contact/show-messages`

**Update Your Code:**
```javascript
// OLD
const phone = contactInfo.phone; // string

// NEW
const phones = contactInfo.phones; // array
const primaryPhone = phones[0]; // get first phone
```

### For API Consumers

**Old Endpoint:**
```
GET /api/admin/messages
```

**New Endpoint:**
```
GET /api/admin/contact/show-messages
```

Simply update your API base paths from `/messages` to `/contact/show-messages`.

---

## Benefits

1. **Better Organization:** All contact-related endpoints under `/api/admin/contact/`
2. **More Flexible:** Support for multiple phone numbers
3. **Complete Information:** Includes work hours for better user experience
4. **Consistent Structure:** Follows RESTful conventions
5. **Admin Control:** Admins can now update contact info via API

---

## Swagger Documentation

Access the updated API documentation at:
```
http://localhost:3000/api-docs
```

Look for:
- **Contact** tag - Public endpoints
- **Admin - Contact** tag - Admin endpoints

---

## Status

✅ **Complete and Tested**

All endpoints are working correctly:
- Public contact info returns new structure
- Admin can view and update contact info
- Messages endpoints working under new paths
- Swagger documentation updated
- Database seeded with new data

---

## Authentication

All admin endpoints require JWT Bearer token:

```bash
# Login
curl -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}'

# Use token
curl http://localhost:3000/api/admin/contact/info \
  -H "Authorization: Bearer YOUR_TOKEN"
```
