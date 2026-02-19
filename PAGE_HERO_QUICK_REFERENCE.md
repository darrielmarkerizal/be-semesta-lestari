# Page Hero Settings - Quick Reference

## Status: ✅ Complete with CRUD Operations

---

## Quick Facts

- **Hero Fields:** title, sub_title, image_url
- **CRUD Operations:** GET (public & admin), PUT (admin upsert)
- **Pages Available:** 8 (articles, awards, merchandise, gallery, programs, partners, contact, about)
- **Authentication:** Required for admin endpoints only

---

## Public Endpoint

```bash
# Get page hero info
GET /api/pages/{slug}/info

# Example
curl "http://localhost:3000/api/pages/articles/info"
```

**Response includes:**
- title
- sub_title
- description
- image_url
- meta_title
- meta_description

---

## Admin Endpoints

All require `Authorization: Bearer {token}`

```bash
# Get page settings
GET /api/admin/pages/{slug}

# Update page hero (upsert)
PUT /api/admin/pages/{slug}
{
  "title": "Page Title",
  "sub_title": "Page Subtitle",
  "image_url": "https://example.com/image.jpg"
}
```

---

## Available Page Slugs

1. `articles` - Articles & News
2. `awards` - Awards & Recognition
3. `merchandise` - Eco-Friendly Merchandise
4. `gallery` - Photo Gallery
5. `programs` - Our Programs
6. `partners` - Our Partners
7. `contact` - Contact Us
8. `about` - About Us

---

## Hero Fields

**Required for Display:**
- `title` - Main hero title
- `sub_title` - Hero subtitle
- `image_url` - Background image

**Optional:**
- `description` - Page description
- `meta_title` - SEO title
- `meta_description` - SEO description
- `is_active` - Visibility toggle

---

## Quick Update Example

```bash
# Login
TOKEN=$(curl -s -X POST "http://localhost:3000/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['accessToken'])")

# Update page hero
curl -X PUT "http://localhost:3000/api/admin/pages/articles" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "New Title",
    "sub_title": "New Subtitle",
    "image_url": "https://images.unsplash.com/photo-123?w=1200"
  }'
```

---

## Frontend Integration

```javascript
// Fetch page hero
const getPageHero = async (slug) => {
  const res = await fetch(`/api/pages/${slug}/info`);
  const { data } = await res.json();
  return data;
};

// Usage
const hero = await getPageHero('articles');
// hero.title, hero.sub_title, hero.image_url
```

---

## Notes

- **Upsert Operation:** PUT creates if doesn't exist, updates if exists
- **Partial Updates:** Only send fields you want to update
- **No Delete:** Pages are permanent, use `is_active: false` to hide
- **Independent:** Separate from home page hero (`/api/hero-section`)

---

## Files

- **Controller:** `src/controllers/pageController.js`
- **Model:** `src/models/PageSettings.js`
- **Routes:** `src/routes/public.js`, `src/routes/admin.js`
- **Summary:** `PAGE_HERO_SETTINGS_SUMMARY.md`

---

**Last Updated:** February 19, 2026
