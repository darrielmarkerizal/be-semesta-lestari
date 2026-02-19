# Contact Data Synchronization Update

## Summary
Synchronized contact information between `/api/home` and `/api/contact` to use the same data source (Settings table). Removed duplicate `home_contact_section` table usage.

## Date
February 19, 2026

---

## Changes Made

### 1. Unified Data Source

**Before:**
- `/api/contact/info` → Used `settings` table
- `/api/home` (contact section) → Used `home_contact_section` table
- Two separate data sources causing inconsistency

**After:**
- `/api/contact/info` → Uses `settings` table
- `/api/home` (contact section) → Uses `settings` table
- `/api/admin/homepage/contact-section` → Uses `settings` table
- Single source of truth for contact information

---

## Updated Endpoints

### Public Endpoints

#### 1. GET /api/contact/info
**Data Source:** Settings table  
**Response:**
```json
{
  "email": "info@semestalestari.org",
  "phones": ["(+62) 21-1234-5678", "(+62) 812-3456-7890"],
  "address": "Jl. Lingkungan Hijau No. 123, Jakarta Selatan, DKI Jakarta 12345, Indonesia",
  "work_hours": "Monday - Friday: 09:00 AM - 05:00 PM\nSaturday: 09:00 AM - 01:00 PM\nSunday: Closed"
}
```

#### 2. GET /api/home
**Contact Section Data Source:** Settings table  
**Contact Section Response:**
```json
{
  "contact": {
    "email": "info@semestalestari.org",
    "phones": ["(+62) 21-1234-5678", "(+62) 812-3456-7890"],
    "address": "Jl. Lingkungan Hijau No. 123, Jakarta Selatan, DKI Jakarta 12345, Indonesia",
    "work_hours": "Monday - Friday: 09:00 AM - 05:00 PM\nSaturday: 09:00 AM - 01:00 PM\nSunday: Closed"
  }
}
```

### Admin Endpoints

#### 3. GET /api/admin/contact/info
**Data Source:** Settings table  
**Same response as public endpoint**

#### 4. PUT /api/admin/contact/info
**Updates:** Settings table  
**Effect:** Updates contact info for both `/api/contact/info` AND `/api/home`

#### 5. GET /api/admin/homepage/contact-section
**Data Source:** Settings table (redirects to contact controller)  
**Same response as `/api/admin/contact/info`**

#### 6. PUT /api/admin/homepage/contact-section
**Updates:** Settings table (redirects to contact controller)  
**Same functionality as `/api/admin/contact/info`**

---

## Data Structure Changes

### Contact Section in /api/home

**Before:**
```json
{
  "contact": {
    "id": 1,
    "title": "Get in Touch",
    "description": "Contact us description",
    "email": "info@example.com",
    "phone": "+62 123 456 789",
    "address": "Address",
    "work_hours": "Hours"
  }
}
```

**After:**
```json
{
  "contact": {
    "email": "info@semestalestari.org",
    "phones": ["(+62) 21-1234-5678", "(+62) 812-3456-7890"],
    "address": "Jl. Lingkungan Hijau No. 123, Jakarta Selatan, DKI Jakarta 12345, Indonesia",
    "work_hours": "Monday - Friday: 09:00 AM - 05:00 PM\nSaturday: 09:00 AM - 01:00 PM\nSunday: Closed"
  }
}
```

**Changes:**
- Removed: `id`, `title`, `description`
- Changed: `phone` (string) → `phones` (array)
- Kept: `email`, `address`, `work_hours`

---

## Benefits

### 1. Single Source of Truth
- Contact information stored in one place (Settings table)
- No data duplication
- Consistent data across all endpoints

### 2. Simplified Management
- Update contact info once, reflects everywhere
- Admin updates via `/api/admin/contact/info` affect both:
  - `/api/contact/info`
  - `/api/home` (contact section)
  - `/api/admin/homepage/contact-section`

### 3. Data Consistency
- No risk of outdated information
- All endpoints always return the same data
- Automatic synchronization

### 4. Reduced Maintenance
- One table to manage instead of two
- Simpler database schema
- Less code duplication

---

## Files Modified

### Controllers

1. **src/controllers/homeController.js**
   - Removed `HomeContactSection` import
   - Added `Settings` import
   - Updated `getHomePage()` to fetch contact data from Settings table
   - Parse phones array from JSON
   - Updated Swagger documentation

2. **src/controllers/adminHomeController.js**
   - Removed `HomeContactSection` import
   - Added `contactController` import
   - Updated `contactSectionController` to redirect to contact controller methods
   - `get` → `contactController.getContactInfoAdmin`
   - `update` → `contactController.updateContactInfo`

### Swagger Documentation
- Updated `/api/home` response schema
- Changed contact section from old structure to new structure
- Updated `phone` to `phones` array

---

## Database Tables

### Settings Table (Used)
```sql
-- Contact information stored as key-value pairs
contact_email        VARCHAR(255)
contact_phones       TEXT (JSON array)
contact_address      TEXT
contact_work_hours   TEXT
```

### home_contact_section Table (Deprecated)
```sql
-- This table is no longer used
-- Can be dropped in future migration
CREATE TABLE home_contact_section (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  address TEXT,
  email VARCHAR(255),
  phone VARCHAR(50),
  work_hours VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

**Note:** The `home_contact_section` table is no longer used but kept for backward compatibility. It can be safely dropped in a future migration.

---

## Testing

### Test 1: Verify Data Consistency
```bash
# Get contact info from /api/contact/info
curl http://localhost:3000/api/contact/info

# Get contact info from /api/home
curl http://localhost:3000/api/home | jq '.data.contact'

# Both should return identical data
```

**Result:** ✅ Both endpoints return identical contact data

### Test 2: Update Contact Info
```bash
# Login as admin
TOKEN=$(curl -s -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' \
  | jq -r '.data.accessToken')

# Update contact info
curl -X PUT http://localhost:3000/api/admin/contact/info \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email":"newemail@example.com"}'

# Verify update in both endpoints
curl http://localhost:3000/api/contact/info
curl http://localhost:3000/api/home | jq '.data.contact'
```

**Result:** ✅ Update reflects in both endpoints immediately

### Test 3: Admin Homepage Contact Section
```bash
# Get via homepage admin endpoint
curl http://localhost:3000/api/admin/homepage/contact-section \
  -H "Authorization: Bearer $TOKEN"

# Should return same data as /api/admin/contact/info
```

**Result:** ✅ Returns identical data

---

## Migration Guide for Frontend

### Breaking Changes

#### 1. Contact Section Structure in /api/home

**Old Code:**
```javascript
const contact = homeData.contact;
console.log(contact.title);        // "Get in Touch"
console.log(contact.description);  // "Contact us..."
console.log(contact.phone);        // "+62 123 456 789" (string)
```

**New Code:**
```javascript
const contact = homeData.contact;
// title and description no longer exist
console.log(contact.phones);       // ["(+62) 21-1234-5678", ...] (array)
console.log(contact.phones[0]);    // Get first phone
```

#### 2. Phone Field Changed to Array

**Old:**
```javascript
<a href={`tel:${contact.phone}`}>{contact.phone}</a>
```

**New:**
```javascript
<a href={`tel:${contact.phones[0]}`}>{contact.phones[0]}</a>

// Or display all phones
{contact.phones.map(phone => (
  <a key={phone} href={`tel:${phone}`}>{phone}</a>
))}
```

---

## API Consistency Verification

All three endpoints now return the same contact data:

```bash
# Endpoint 1: Public contact info
GET /api/contact/info

# Endpoint 2: Home page contact section
GET /api/home → data.contact

# Endpoint 3: Admin homepage contact section
GET /api/admin/homepage/contact-section
```

**All return:**
```json
{
  "email": "info@semestalestari.org",
  "phones": ["(+62) 21-1234-5678", "(+62) 812-3456-7890"],
  "address": "Jl. Lingkungan Hijau No. 123, Jakarta Selatan, DKI Jakarta 12345, Indonesia",
  "work_hours": "Monday - Friday: 09:00 AM - 05:00 PM\nSaturday: 09:00 AM - 01:00 PM\nSunday: Closed"
}
```

---

## Update Flow

```
Admin updates contact info
         ↓
PUT /api/admin/contact/info
         ↓
Updates Settings table
         ↓
    Affects all endpoints:
    ├── GET /api/contact/info
    ├── GET /api/home (contact section)
    └── GET /api/admin/homepage/contact-section
```

---

## Conclusion

✅ Contact data successfully synchronized across all endpoints  
✅ Single source of truth established (Settings table)  
✅ Data consistency guaranteed  
✅ Simplified management and maintenance  
✅ All endpoints tested and working  
✅ Swagger documentation updated  

**Status:** Complete and Production Ready

---

## Quick Verification

```bash
# Test data consistency
curl -s http://localhost:3000/api/contact/info | jq '.data' > contact.json
curl -s http://localhost:3000/api/home | jq '.data.contact' > home_contact.json
diff contact.json home_contact.json

# Should show no differences
```

---

**Implementation Date:** February 19, 2026  
**Status:** Complete  
**Breaking Changes:** Yes (contact section structure in /api/home)  
**Migration Required:** Frontend needs to update contact section handling
