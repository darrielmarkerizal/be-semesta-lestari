# Home Page Images - Quick Reference

## Quick Start

### 1. Run Migration (for existing databases)
```bash
node src/scripts/addImageUrlColumns.js
```

### 2. Upload Images

```bash
# Login first
TOKEN=$(curl -s -X POST "http://localhost:3000/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@semestalestari.com", "password": "admin123"}' \
  | jq -r '.data.accessToken')

# Upload vision image
curl -X POST "http://localhost:3000/api/admin/upload/vision" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@my-vision-image.jpg"

# Upload donation CTA image
curl -X POST "http://localhost:3000/api/admin/upload/donation_cta" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@my-donation-image.jpg"

# Upload impact section image
curl -X POST "http://localhost:3000/api/admin/upload/impact_section" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@my-impact-image.jpg"
```

### 3. Update Sections

```bash
# Update vision with image
curl -X PUT "http://localhost:3000/api/admin/homepage/vision" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Our Vision",
    "description": "Creating a sustainable future",
    "image_url": "/uploads/vision/my-vision-image.jpg",
    "is_active": true
  }'

# Update donation CTA with image (get ID first)
DONATION_ID=$(curl -s -X GET "http://localhost:3000/api/admin/homepage/donation-cta" \
  -H "Authorization: Bearer $TOKEN" | jq -r '.data.id')

curl -X PUT "http://localhost:3000/api/admin/homepage/donation-cta/$DONATION_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Support Our Mission",
    "description": "Your donation makes a difference",
    "button_text": "Donate Now",
    "button_url": "/donate",
    "image_url": "/uploads/donation_cta/my-donation-image.jpg",
    "is_active": true
  }'

# Create impact section with image
curl -X POST "http://localhost:3000/api/admin/homepage/impact" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Trees Planted",
    "description": "Making a real impact",
    "stats_number": "10,000+",
    "image_url": "/uploads/impact_section/my-impact-image.jpg",
    "order_position": 1,
    "is_active": true
  }'
```

### 4. Verify in Public API

```bash
curl http://localhost:3000/api/home | jq '.data | {
  vision_image: .vision.image_url,
  donation_image: .donationCta.image_url,
  impact_images: [.impact[].image_url]
}'
```

## Entity Types for Upload

| Section | Entity Type | Upload Endpoint |
|---------|-------------|-----------------|
| Vision | `vision` | `/api/admin/upload/vision` |
| Donation CTA | `donation_cta` | `/api/admin/upload/donation_cta` |
| Impact Section | `impact_section` | `/api/admin/upload/impact_section` |

## Admin Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/homepage/vision` | Get vision section |
| PUT | `/api/admin/homepage/vision` | Update vision with image |
| GET | `/api/admin/homepage/donation-cta` | Get donation CTA |
| PUT | `/api/admin/homepage/donation-cta/:id` | Update donation CTA with image |
| GET | `/api/admin/homepage/impact` | Get all impact sections |
| POST | `/api/admin/homepage/impact` | Create impact section with image |
| PUT | `/api/admin/homepage/impact/:id` | Update impact section with image |
| DELETE | `/api/admin/homepage/impact/:id` | Delete impact section |

## Public Endpoint

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/home` | Get complete home page data including all images |

## Image Fields

Each section now has:
- `icon_url` - Small icon (existing field)
- `image_url` - Main image (NEW field)

Both fields are optional and can be used independently or together.

## Replace Image Feature

Use the replace endpoint to upload a new image and delete the old one in a single operation:

```bash
curl -X POST "http://localhost:3000/api/admin/upload/replace/vision" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@new-image.jpg" \
  -F "oldImageUrl=/uploads/vision/old-image.jpg"
```

## Testing

Run the comprehensive test suite:

```bash
./test_home_images.sh
```

Note: Wait 15 minutes between test runs to avoid rate limiting.

## Troubleshooting

### Migration already run?
The migration script is idempotent - it's safe to run multiple times.

### Images not showing?
1. Check file was uploaded: `ls uploads/vision/`
2. Verify URL in database: Check admin GET endpoint
3. Ensure `is_active` is true

### Rate limit error?
Wait 15 minutes before trying to login again.

## Example Response

```json
{
  "success": true,
  "data": {
    "vision": {
      "id": 1,
      "title": "Our Vision",
      "description": "Creating a sustainable future",
      "icon_url": "/uploads/vision/icon.png",
      "image_url": "/uploads/vision/main-image.jpg",
      "is_active": true
    },
    "donationCta": {
      "id": 1,
      "title": "Support Our Mission",
      "description": "Your donation makes a difference",
      "button_text": "Donate Now",
      "button_url": "/donate",
      "image_url": "/uploads/donation_cta/donation-banner.jpg",
      "is_active": true
    },
    "impact": [
      {
        "id": 1,
        "title": "Trees Planted",
        "description": "Making a real impact",
        "stats_number": "10,000+",
        "icon_url": "/uploads/impact_section/tree-icon.png",
        "image_url": "/uploads/impact_section/trees-photo.jpg",
        "order_position": 1,
        "is_active": true
      }
    ]
  }
}
```
