# Google Maps Link Integration - Summary

## Status: ✅ Complete

Added Google Maps link field to footer contact information with full CRUD support and Swagger documentation.

---

## What Was Added

### New Field: `contact_gmaps`

A new setting for storing Google Maps link/embed URL for the organization's location.

**Example Values:**
- Coordinates: `https://maps.google.com/?q=-6.200000,106.816666`
- Place name: `https://maps.google.com/?q=Semesta+Lestari+Jakarta`
- Embed URL: `https://www.google.com/maps/embed?pb=...`

---

## Updated Files

### 1. Database Seeder
**File:** `src/scripts/seedDatabase.js`

Added default gmaps setting:
```javascript
['contact_gmaps', 'https://maps.google.com/?q=-6.200000,106.816666']
```

### 2. Footer Controller (Public API)
**File:** `src/controllers/footerController.js`

**Updated `getFooterData()`:**
- Added `contact_gmaps` to settings fetch
- Included in response under `contact.gmaps`

**Response structure:**
```json
{
  "contact": {
    "email": "...",
    "phones": [...],
    "address": "...",
    "work_hours": "...",
    "gmaps": "https://maps.google.com/?q=-6.200000,106.816666"
  }
}
```

### 3. Admin Footer Controller
**File:** `src/controllers/footerController.js`

**Updated `getFooterAdmin()`:**
- Added `contact_gmaps` to admin response
- Returns full setting object with key and value

**Updated `updateFooterAdmin()`:**
- Added support for updating `contact.gmaps`
- Validates and saves to database

### 4. Swagger Documentation
**File:** `src/controllers/footerController.js`

Updated all Swagger annotations:

**GET /api/footer:**
```yaml
contact:
  gmaps:
    type: string
    example: https://maps.google.com/?q=-6.200000,106.816666
```

**GET /api/admin/footer:**
```yaml
contact:
  gmaps:
    type: object
    properties:
      key: contact_gmaps
      value: https://maps.google.com/?q=-6.200000,106.816666
```

**PUT /api/admin/footer:**
```yaml
contact:
  gmaps:
    type: string
    example: https://maps.google.com/?q=-6.200000,106.816666
```

---

## API Usage

### Get Footer Data (Public)

```bash
curl http://localhost:3000/api/footer
```

**Response:**
```json
{
  "success": true,
  "data": {
    "contact": {
      "email": "info@semestalestari.com",
      "phones": ["(+62) 21-1234-5678"],
      "address": "Jl. Lingkungan Hijau No. 123, Jakarta",
      "work_hours": "Monday - Friday: 9:00 AM - 5:00 PM",
      "gmaps": "https://maps.google.com/?q=-6.200000,106.816666"
    }
  }
}
```

### Get Admin Footer Settings

```bash
TOKEN="your_token"
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/api/admin/footer
```

**Response:**
```json
{
  "success": true,
  "data": {
    "contact": {
      "gmaps": {
        "id": 144,
        "key": "contact_gmaps",
        "value": "https://maps.google.com/?q=-6.200000,106.816666",
        "created_at": "2026-02-28T03:55:00.000Z",
        "updated_at": "2026-02-28T03:55:00.000Z"
      }
    }
  }
}
```

### Update Google Maps Link

**Method 1: Using Admin Footer Endpoint**
```bash
curl -X PUT http://localhost:3000/api/admin/footer \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "contact": {
      "gmaps": "https://maps.google.com/?q=Semesta+Lestari+Jakarta"
    }
  }'
```

**Method 2: Using Settings Endpoint**
```bash
curl -X PUT http://localhost:3000/api/admin/config/contact_gmaps \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value":"https://maps.google.com/?q=-6.200000,106.816666"}'
```

---

## Google Maps URL Formats

### 1. Coordinates (Recommended)
```
https://maps.google.com/?q=-6.200000,106.816666
```
- Most reliable
- Works everywhere
- Easy to generate

### 2. Place Name
```
https://maps.google.com/?q=Semesta+Lestari+Jakarta
```
- User-friendly
- May not be precise
- Good for well-known locations

### 3. Place ID
```
https://maps.google.com/?q=place_id:ChIJN1t_tDeuEmsRUsoyG83frY4
```
- Most accurate
- Requires Google Places API
- Permanent identifier

### 4. Embed URL
```
https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d...
```
- For iframe embedding
- Generated from Google Maps
- Includes zoom and view settings

---

## Frontend Integration Examples

### 1. Simple Link
```html
<a href="{{ contact.gmaps }}" target="_blank">
  View on Google Maps
</a>
```

### 2. Embedded Map
```html
<iframe 
  src="{{ contact.gmaps }}" 
  width="600" 
  height="450" 
  style="border:0;" 
  allowfullscreen="" 
  loading="lazy">
</iframe>
```

### 3. React Component
```jsx
function ContactMap({ gmapsUrl }) {
  return (
    <div className="map-container">
      <a 
        href={gmapsUrl} 
        target="_blank" 
        rel="noopener noreferrer"
        className="map-link"
      >
        <img src="/map-icon.png" alt="Location" />
        View on Google Maps
      </a>
    </div>
  );
}
```

### 4. Vue Component
```vue
<template>
  <div class="contact-map">
    <a :href="contact.gmaps" target="_blank">
      📍 View Location
    </a>
  </div>
</template>

<script>
export default {
  props: ['contact']
}
</script>
```

---

## Testing

### Test Script

```bash
#!/bin/bash

BASE_URL="http://localhost:3000/api"

# Get token
TOKEN=$(curl -s -X POST "$BASE_URL/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' \
  | jq -r '.data.accessToken')

# Get current gmaps
echo "Current gmaps:"
curl -s "$BASE_URL/footer" | jq '.data.contact.gmaps'

# Update gmaps
echo -e "\nUpdating gmaps..."
curl -s -X PUT "$BASE_URL/admin/footer" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "contact": {
      "gmaps": "https://maps.google.com/?q=New+Location"
    }
  }' | jq '.success'

# Verify update
echo -e "\nVerifying update:"
curl -s "$BASE_URL/footer" | jq '.data.contact.gmaps'
```

### Manual Testing

1. **Get current value:**
   ```bash
   curl http://localhost:3000/api/footer | jq '.data.contact.gmaps'
   ```

2. **Update via Swagger UI:**
   - Go to http://localhost:3000/api-docs/
   - Find PUT /api/admin/footer
   - Update contact.gmaps field
   - Execute

3. **Verify in public API:**
   ```bash
   curl http://localhost:3000/api/footer | jq '.data.contact'
   ```

---

## Swagger Documentation

### Access Swagger UI
```
http://localhost:3000/api-docs/
```

### Documented Endpoints

**Public:**
- GET /api/footer (includes gmaps in contact object)

**Admin:**
- GET /api/admin/footer (includes gmaps setting)
- PUT /api/admin/footer (update gmaps)
- GET /api/admin/config/contact_gmaps (get gmaps setting)
- PUT /api/admin/config/contact_gmaps (update gmaps setting)

### Swagger Features

1. **Complete Schema:** Full request/response schemas with gmaps field
2. **Examples:** Multiple examples showing gmaps usage
3. **Interactive Testing:** Try it out directly in Swagger UI
4. **Field Descriptions:** Clear descriptions of gmaps field purpose

---

## Database

### Settings Table

The gmaps link is stored in the `settings` table:

| id  | key           | value                                          |
|-----|---------------|------------------------------------------------|
| 144 | contact_gmaps | https://maps.google.com/?q=-6.200000,106.816666 |

### Query Examples

**Get gmaps:**
```sql
SELECT value FROM settings WHERE `key` = 'contact_gmaps';
```

**Update gmaps:**
```sql
UPDATE settings 
SET value = 'https://maps.google.com/?q=New+Location' 
WHERE `key` = 'contact_gmaps';
```

**Insert if not exists:**
```sql
INSERT INTO settings (`key`, value) 
VALUES ('contact_gmaps', 'https://maps.google.com/?q=-6.200000,106.816666')
ON DUPLICATE KEY UPDATE value = VALUES(value);
```

---

## Complete Contact Object

The footer now returns complete contact information:

```json
{
  "contact": {
    "email": "info@semestalestari.com",
    "phones": [
      "(+62) 21-1234-5678",
      "(+62) 812-3456-7890"
    ],
    "address": "Jl. Lingkungan Hijau No. 123, Jakarta Selatan, DKI Jakarta 12345, Indonesia",
    "work_hours": "Monday - Friday: 09:00 AM - 05:00 PM\nSaturday: 09:00 AM - 01:00 PM\nSunday: Closed",
    "gmaps": "https://maps.google.com/?q=-6.200000,106.816666"
  }
}
```

---

## Tips & Best Practices

### 1. URL Format
- Use coordinates for precision: `?q=lat,lng`
- Use place names for readability: `?q=Place+Name+City`
- Always use HTTPS

### 2. Validation
Consider adding validation:
- Check URL starts with `https://`
- Validate it's a Google Maps URL
- Test the link works before saving

### 3. Frontend Display
- Open in new tab: `target="_blank"`
- Add security: `rel="noopener noreferrer"`
- Show map icon for better UX
- Consider embedding map for better experience

### 4. Mobile Optimization
- Google Maps URLs automatically open in Google Maps app on mobile
- Test on both iOS and Android
- Consider deep links for better mobile experience

---

## Future Enhancements

1. **Validation:**
   - Validate Google Maps URL format
   - Check if coordinates are valid
   - Test link accessibility

2. **Multiple Locations:**
   - Support multiple office locations
   - Store as JSON array
   - Each location with its own gmaps link

3. **Map Customization:**
   - Store zoom level
   - Store map type (roadmap, satellite)
   - Store marker customization

4. **Analytics:**
   - Track map link clicks
   - Monitor popular locations
   - A/B test different map formats

---

## Troubleshooting

### Issue: gmaps field not showing
**Solution:** 
1. Check if setting exists: `curl http://localhost:3000/api/admin/config/contact_gmaps`
2. If not, create it: See "Update Google Maps Link" section
3. Restart server if needed

### Issue: Map not loading in iframe
**Solution:**
- Use embed URL format, not regular Google Maps URL
- Check iframe src attribute
- Verify no CORS issues

### Issue: Link opens wrong location
**Solution:**
- Use coordinates instead of place name
- Verify coordinates are correct (lat, lng order)
- Test link in browser first

---

## Summary

✅ Google Maps link field added to contact information  
✅ Full CRUD support via admin endpoints  
✅ Included in public footer API  
✅ Comprehensive Swagger documentation  
✅ Multiple URL format support  
✅ Tested and working  

The gmaps field is now fully integrated into the footer system and ready for use in frontend applications.

---

**Access Documentation:**
- Swagger UI: http://localhost:3000/api-docs/
- Look for "Admin - Footer" and "Footer" tags
- Test endpoints interactively

**Default Value:**
```
https://maps.google.com/?q=-6.200000,106.816666
```
(Jakarta, Indonesia coordinates)
