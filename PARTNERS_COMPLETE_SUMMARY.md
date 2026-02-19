# Partners API - Complete Summary

## Overview
Partners data is synchronized between `/api/home` and `/api/partners`, with full CRUD operations available at `/api/admin/partners`.

## Date
February 19, 2026

---

## Synchronization Status

✅ **SYNCHRONIZED** - Both endpoints use the same `partners` table via the same `Partner` model

```
/api/partners        → Partner.findAll(true) → partners table
/api/home (partners) → Partner.findAll(true) → partners table
```

---

## CRUD Operations

✅ **CREATE** - POST `/api/admin/partners`  
✅ **READ** - GET `/api/admin/partners` (list) and `/api/admin/partners/:id` (single)  
✅ **UPDATE** - PUT `/api/admin/partners/:id`  
✅ **DELETE** - DELETE `/api/admin/partners/:id`  

**All operations tested and working!**

---

## API Endpoints

### Public Endpoints
```
GET /api/partners        - Get all active partners
GET /api/partners/:id    - Get single partner by ID
```

### Admin Endpoints (Require Authentication)
```
GET    /api/admin/partners        - Get all partners (paginated)
POST   /api/admin/partners        - Create new partner
GET    /api/admin/partners/:id    - Get single partner
PUT    /api/admin/partners/:id    - Update partner
DELETE /api/admin/partners/:id    - Delete partner
```

---

## Testing Results

**Test Script:** `test_partners_api.sh`  
**Total Tests:** 6  
**Passed:** 6  
**Failed:** 0  
**Success Rate:** 100%

### Tests Performed
1. ✅ Get all partners (public)
2. ✅ Data consistency between `/api/partners` and `/api/home`
3. ✅ Create partner (admin)
4. ✅ Get single partner (admin)
5. ✅ Update partner (admin)
6. ✅ Delete partner (admin)

---

## Partner Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | Integer | Auto | Unique identifier |
| `name` | String | Yes | Partner organization name |
| `description` | Text | No | Partner description |
| `logo_url` | String | No | URL to partner logo |
| `website` | String | No | Partner website URL |
| `order_position` | Integer | No | Display order (default: 0) |
| `is_active` | Boolean | No | Visibility status (default: true) |
| `created_at` | Timestamp | Auto | Creation timestamp |
| `updated_at` | Timestamp | Auto | Last update timestamp |

---

## Usage Examples

### Create Partner
```bash
TOKEN="your_token_here"

curl -X POST "http://localhost:3000/api/admin/partners" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Environmental Alliance",
    "description": "Leading environmental conservation organization",
    "logo_url": "https://example.com/logo.png",
    "website": "https://envalliance.org"
  }'
```

### Update Partner
```bash
curl -X PUT "http://localhost:3000/api/admin/partners/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Partner Name"
  }'
```

### Delete Partner
```bash
curl -X DELETE "http://localhost:3000/api/admin/partners/1" \
  -H "Authorization: Bearer $TOKEN"
```

---

## Data Consistency

When you create, update, or delete a partner via `/api/admin/partners`, it immediately affects:

1. **GET /api/partners** - Public partners list
2. **GET /api/partners/:id** - Single partner view
3. **GET /api/home** - Home page partners section

All endpoints use the same `partners` table, so changes are instantly synchronized.

---

## Conclusion

✅ Partners data synchronized across all endpoints  
✅ Full CRUD operations implemented  
✅ All tests passing (100% success rate)  
✅ Swagger documentation complete  
✅ Production ready  

**Status:** Complete and Operational

---

**Documentation Date:** February 19, 2026  
**API Version:** 1.0.0  
**Tests:** All Passing
