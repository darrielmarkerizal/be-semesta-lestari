# Page Hero Settings - Complete Summary

## Overview
Page hero settings provide customizable hero sections for different pages with title, subtitle, and image. Full CRUD operations are available for managing these settings.

## Date
February 19, 2026

---

## What Was Implemented

### 1. Database Schema Update
Added `sub_title` field to `page_settings` table:
- `title` VARCHAR(255) - Main hero title
- `sub_title` VARCHAR(255) - Hero subtitle (NEW)
- `description` TEXT - Page description
- `image_url` VARCHAR(500) - Hero background image
- `meta_title` VARCHAR(255) - SEO meta title
- `meta_description` VARCHAR(500) - SEO meta description

### 2. Seeded Data
Created hero settings for 8 pages:
- articles
- awards
- merchandise
- gallery
- programs
- partners
- contact
- about

Each with professional titles, subtitles, and high-quality Unsplash images.

### 3. CRUD Operations
All CRUD operations already exist and working:
- **CREATE/UPDATE**: PUT `/api/admin/pages/{slug}` (upsert operation)
- **READ**: GET `/api/admin/pages/{slug}` (admin) and GET `/api/pages/{slug}/info` (public)
- **DELETE**: Not implemented (pages are permanent, only deactivate via `is_active`)

---

## API Endpoints

### Public Endpoint
```
GET /api/pages/{slug}/info
```

Returns page hero information for public display.

**Supported slugs:**
- articles
- awards
- merchandise
- gallery
- programs
- partners
- contact
- about

**Response:**
```json
{
  "success": true,
  "message": "Page info retrieved",
  "data": {
    "id": 1,
    "page_slug": "articles",
    "title": "Articles & News",
    "sub_title": "Latest Updates and Stories",
    "description": "Read our latest articles...",
    "image_url": "https://images.unsplash.com/...",
    "meta_title": "Articles & News - Semesta Lestari",
    "meta_description": "Read our latest articles...",
    "is_active": true
  }
}
```

### Admin Endpoints (Require Authentication)

#### Get Page Settings
```
GET /api/admin/pages/{slug}
```

Returns page settings for admin management.

#### Update Page Settings
```
PUT /api/admin/pages/{slug}
```

Updates page hero settings (upsert operation - creates if doesn't exist).

**Request Body:**
```json
{
  "title": "New Page Title",
  "sub_title": "New Subtitle",
  "description": "Page description",
  "image_url": "https://example.com/image.jpg",
  "meta_title": "SEO Title",
  "meta_description": "SEO Description",
  "is_active": true
}
```

All fields are optional (partial updates supported).

---

## Usage Examples

### Get Page Hero Info (Public)
```bash
curl "http://localhost:3000/api/pages/articles/info"
```

### Update Page Hero (Admin)
```bash
TOKEN="your_token_here"

curl -X PUT "http://localhost:3000/api/admin/pages/articles" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Articles Title",
    "sub_title": "Updated Subtitle",
    "image_url": "https://images.unsplash.com/photo-123456?w=1200"
  }'
```

### Get Page Settings (Admin)
```bash
curl "http://localhost:3000/api/admin/pages/articles" \
  -H "Authorization: Bearer $TOKEN"
```

---

## Page Hero Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `page_slug` | String | Yes | Unique page identifier |
| `title` | String | No | Main hero title |
| `sub_title` | String | No | Hero subtitle |
| `description` | Text | No | Page description |
| `image_url` | String | No | Hero background image URL |
| `meta_title` | String | No | SEO meta title |
| `meta_description` | String | No | SEO meta description |
| `is_active` | Boolean | No | Page visibility (default: true) |

---

## Seeded Pages

### 1. Articles
- **Title:** Articles & News
- **Subtitle:** Latest Updates and Stories
- **Image:** News/blog themed

### 2. Awards
- **Title:** Awards & Recognition
- **Subtitle:** Celebrating Our Achievements
- **Image:** Trophy/achievement themed

### 3. Merchandise
- **Title:** Eco-Friendly Merchandise
- **Subtitle:** Support Our Mission
- **Image:** Store/products themed

### 4. Gallery
- **Title:** Photo Gallery
- **Subtitle:** Our Journey in Pictures
- **Image:** Camera/photography themed

### 5. Programs
- **Title:** Our Programs
- **Subtitle:** Making a Difference Together
- **Image:** Environmental programs themed

### 6. Partners
- **Title:** Our Partners
- **Subtitle:** Collaborating for Change
- **Image:** Partnership/collaboration themed

### 7. Contact
- **Title:** Contact Us
- **Subtitle:** Get in Touch
- **Image:** Communication themed

### 8. About
- **Title:** About Us
- **Subtitle:** Our Story and Mission
- **Image:** Nature/landscape themed

---

## Integration Notes

### Frontend Usage
```javascript
// Fetch page hero for articles page
const response = await fetch('/api/pages/articles/info');
const { data } = await response.json();

// Display hero section
<Hero
  title={data.title}
  subtitle={data.sub_title}
  backgroundImage={data.image_url}
/>
```

### Admin Panel Usage
```javascript
// Update page hero
const updatePageHero = async (slug, heroData) => {
  const response = await fetch(`/api/admin/pages/${slug}`, {
    method: 'PUT',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(heroData)
  });
  return response.json();
};
```

---

## Data Synchronization

Page hero settings are **independent** from other hero sections:
- `/api/hero-section` - Home page hero (different table: `hero_sections`)
- `/api/pages/{slug}/info` - Page-specific heroes (table: `page_settings`)

Each page has its own customizable hero section stored in `page_settings` table.

---

## Conclusion

✅ Page hero settings implemented with `title`, `sub_title`, and `image_url`  
✅ Full CRUD operations available (upsert-based updates)  
✅ 8 pages seeded with professional content  
✅ Swagger documentation updated  
✅ Production ready  

**Status:** Complete and Operational

---

**Documentation Date:** February 19, 2026  
**API Version:** 1.0.0  
**Database:** page_settings table with sub_title field
