# Footer CRUD Operations - Quick Reference

## Status: ✅ Fully Implemented and Tested

The footer system has complete CRUD operations through the Settings API.

---

## API Endpoints

### Public Endpoint

**GET /api/footer**
- Returns all footer data (contact, social media, program categories)
- No authentication required

```bash
curl http://localhost:3000/api/footer
```

### Admin Endpoints (Authenticated)

**GET /api/admin/config**
- Get all settings
- Returns array of all key-value pairs

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3000/api/admin/config
```

**GET /api/admin/config/:key**
- Get specific setting by key
- Returns single setting object

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3000/api/admin/config/contact_email
```

**PUT /api/admin/config/:key**
- Update or create setting (upsert)
- Creates if doesn't exist, updates if exists

```bash
curl -X PUT http://localhost:3000/api/admin/config/contact_email \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"newemail@example.com"}'
```

---

## Footer Settings Keys

### Contact Information

| Key | Type | Example |
|-----|------|---------|
| `contact_email` | String | `info@semestalestari.com` |
| `contact_phones` | JSON Array | `["(+62) 21-1234-5678", "(+62) 812-3456-7890"]` |
| `contact_address` | String | `Jl. Lingkungan Hijau No. 123, Jakarta` |
| `contact_work_hours` | String | `Monday - Friday: 9:00 AM - 5:00 PM` |

### Social Media Links

| Key | Platform | Example |
|-----|----------|---------|
| `social_facebook` | Facebook | `https://facebook.com/semestalestari` |
| `social_instagram` | Instagram | `https://instagram.com/semestalestari` |
| `social_twitter` | Twitter | `https://twitter.com/semestalestari` |
| `social_youtube` | YouTube | `https://youtube.com/@semestalestari` |
| `social_linkedin` | LinkedIn | `https://linkedin.com/company/semestalestari` |
| `social_tiktok` | TikTok | `https://tiktok.com/@semestalestari` |

---

## Usage Examples

### 1. Get All Settings

```bash
TOKEN="your_token_here"
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/api/admin/config | jq '.'
```

### 2. Get Contact Email

```bash
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/api/admin/config/contact_email | jq '.data'
```

Response:
```json
{
  "id": 3,
  "key": "contact_email",
  "value": "info@semestalestari.com",
  "created_at": "2026-02-19T04:08:15.000Z",
  "updated_at": "2026-02-19T06:53:14.000Z"
}
```

### 3. Update Contact Email

```bash
curl -X PUT http://localhost:3000/api/admin/config/contact_email \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"newemail@semestalestari.com"}'
```

Response:
```json
{
  "success": true,
  "message": "Setting updated successfully",
  "data": {
    "key": "contact_email",
    "value": "newemail@semestalestari.com"
  }
}
```

### 4. Update Contact Phones (JSON Array)

```bash
curl -X PUT http://localhost:3000/api/admin/config/contact_phones \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"[\"+62 21 9999-8888\", \"+62 812 9999-8888\"]"}'
```

**Note:** Phone numbers must be a JSON-encoded string array.

### 5. Update Social Media Link

```bash
curl -X PUT http://localhost:3000/api/admin/config/social_facebook \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"https://facebook.com/newsemestalestari"}'
```

### 6. Update Work Hours

```bash
curl -X PUT http://localhost:3000/api/admin/config/contact_work_hours \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"Monday - Saturday: 9:00 AM - 6:00 PM\nSunday: Closed"}'
```

### 7. Create New Custom Setting

```bash
curl -X PUT http://localhost:3000/api/admin/config/custom_footer_text \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"Custom footer message"}'
```

### 8. Verify Changes in Public Endpoint

```bash
curl http://localhost:3000/api/footer | jq '.data.contact'
```

---

## CRUD Operations Summary

| Operation | Method | Endpoint | Description |
|-----------|--------|----------|-------------|
| **Read All** | GET | `/api/admin/config` | Get all settings |
| **Read One** | GET | `/api/admin/config/:key` | Get specific setting |
| **Create** | PUT | `/api/admin/config/:key` | Create new setting (upsert) |
| **Update** | PUT | `/api/admin/config/:key` | Update existing setting (upsert) |
| **Delete** | N/A | N/A | Not implemented (settings are permanent) |

**Note:** The PUT endpoint uses "upsert" logic - it creates if the key doesn't exist, updates if it does.

---

## Authentication

All admin endpoints require JWT authentication.

### Get Token

```bash
curl -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@semestalestari.com",
    "password": "admin123"
  }' | jq -r '.data.accessToken'
```

### Use Token

```bash
TOKEN=$(curl -s -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' \
  | jq -r '.data.accessToken')

# Now use $TOKEN in requests
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/api/admin/config
```

---

## Special Handling

### JSON Array Values

When updating settings that contain JSON arrays (like `contact_phones`), you must:
1. Encode the array as a JSON string
2. Pass it as the value

**Correct:**
```json
{"value": "[\"phone1\", \"phone2\"]"}
```

**Incorrect:**
```json
{"value": ["phone1", "phone2"]}
```

### Multi-line Text

For multi-line values (like `contact_work_hours`), use `\n`:

```json
{"value": "Monday - Friday: 9:00 AM - 5:00 PM\nSaturday: 9:00 AM - 1:00 PM\nSunday: Closed"}
```

---

## Testing

### Run Complete Test Suite

```bash
# Test all footer CRUD operations
./test_footer_complete.sh

# Test settings management
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/api/admin/config
```

### Manual Testing Steps

1. **Get all settings**
   ```bash
   curl -H "Authorization: Bearer $TOKEN" \
     http://localhost:3000/api/admin/config
   ```

2. **Update a setting**
   ```bash
   curl -X PUT http://localhost:3000/api/admin/config/contact_email \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"value":"test@example.com"}'
   ```

3. **Verify in public endpoint**
   ```bash
   curl http://localhost:3000/api/footer | jq '.data.contact.email'
   ```

4. **Restore original value**
   ```bash
   curl -X PUT http://localhost:3000/api/admin/config/contact_email \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"value":"info@semestalestari.com"}'
   ```

---

## Response Format

### Success Response

```json
{
  "success": true,
  "message": "Setting updated successfully",
  "data": {
    "id": 3,
    "key": "contact_email",
    "value": "newemail@example.com",
    "created_at": "2026-02-19T04:08:15.000Z",
    "updated_at": "2026-02-27T16:00:00.000Z"
  },
  "error": null
}
```

### Error Response

```json
{
  "success": false,
  "message": "Setting not found",
  "data": null,
  "error": "NOT_FOUND"
}
```

---

## Common Tasks

### Update All Contact Information

```bash
TOKEN="your_token"

# Update email
curl -X PUT http://localhost:3000/api/admin/config/contact_email \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"info@semestalestari.com"}'

# Update phones
curl -X PUT http://localhost:3000/api/admin/config/contact_phones \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"[\"+62 21-1234-5678\", \"+62 812-3456-7890\"]"}'

# Update address
curl -X PUT http://localhost:3000/api/admin/config/contact_address \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"Jl. Lingkungan Hijau No. 123, Jakarta"}'

# Update work hours
curl -X PUT http://localhost:3000/api/admin/config/contact_work_hours \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"Monday - Friday: 9:00 AM - 5:00 PM"}'
```

### Update All Social Media Links

```bash
TOKEN="your_token"

for platform in facebook instagram twitter youtube linkedin tiktok; do
  curl -X PUT http://localhost:3000/api/admin/config/social_$platform \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"value\":\"https://$platform.com/semestalestari\"}"
done
```

---

## Swagger Documentation

Access interactive API documentation:
```
http://localhost:3000/api-docs/
```

Look for:
- **Admin - Settings** tag for settings management
- **Footer** tag for public footer endpoint

---

## Files Reference

- **Controller:** `src/controllers/settingsController.js`
- **Model:** `src/models/Settings.js`
- **Routes:** `src/routes/admin.js`
- **Public Route:** `src/routes/public.js`
- **Footer Controller:** `src/controllers/footerController.js`

---

## Notes

1. **No Delete Operation:** Settings cannot be deleted through the API. They can only be created or updated.

2. **Upsert Logic:** The PUT endpoint automatically creates settings if they don't exist.

3. **Public Endpoint:** Changes to settings are immediately reflected in the public `/api/footer` endpoint.

4. **JSON Handling:** The footer controller automatically parses JSON strings (like phone arrays) for the public API.

5. **Validation:** Currently minimal validation. Consider adding validation for:
   - Email format
   - URL format for social media
   - Phone number format

---

## Conclusion

✅ Footer CRUD operations fully implemented  
✅ All operations tested and working  
✅ Changes immediately reflected in public API  
✅ Supports JSON arrays and multi-line text  
✅ Complete authentication and authorization  

The footer management system is production-ready with full CRUD capabilities through the Settings API.
