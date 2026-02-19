# Home API Update - Complete

## ✅ All Requirements Implemented

I've successfully updated the `/api/home` endpoint with all the requested features.

### 📋 What Was Implemented

#### 1. ✅ Hero Section - 2 CTA Buttons
**Database Changes:**
- Added `button_text_2` field
- Added `button_url_2` field

**Response Structure:**
```json
{
  "hero": {
    "title": "Welcome to Semesta Lestari",
    "subtitle": "Building a Sustainable Future Together",
    "description": "Join us in our mission...",
    "button_text": "Learn More",
    "button_url": "/about",
    "button_text_2": "Get Involved",
    "button_url_2": "/contact"
  }
}
```

#### 2. ✅ Visions Section - Multiple Values
**Status:** Already supports multiple visions
- Returns array of all active visions
- Can add unlimited visions via admin API
- Ordered by `order_position`

#### 3. ✅ Our Programs Section
**New Database Table:** `home_programs_section`
**New Database Table:** `programs` (updated with `is_highlighted`)

**Response Structure:**
```json
{
  "programs": {
    "section": {
      "title": "Our Programs",
      "subtitle": "Making a difference through various initiatives"
    },
    "items": [
      {
        "id": 1,
        "name": "Tree Planting Initiative",
        "description": "Planting trees across communities...",
        "is_highlighted": true
      }
    ],
    "highlighted": {
      "id": 1,
      "name": "Tree Planting Initiative",
      "description": "...",
      "is_highlighted": true
    }
  }
}
```

#### 4. ✅ Statistics Section
**New Database Table:** `home_statistics`

**Response Structure:**
```json
{
  "statistics": {
    "title": "Our Impact in Numbers",
    "subtitle": "See the difference we've made together",
    "trees_planted": "10,000+",
    "volunteers": "500+",
    "areas_covered": "25+",
    "partners_count": "50+"
  }
}
```

#### 5. ✅ Donation Section - 2 CTA Buttons
**Database Changes:**
- Added `button_text_2` field
- Added `button_url_2` field

**Response Structure:**
```json
{
  "donationCta": {
    "title": "Support Our Mission",
    "description": "Your donation helps us...",
    "button_text": "Donate Now",
    "button_url": "/donate",
    "button_text_2": "Learn More",
    "button_url_2": "/about"
  }
}
```

#### 6. ✅ Partners Section
**New Database Table:** `home_partners_section`
**Existing Table:** `partners` (already exists)

**Response Structure:**
```json
{
  "partners": {
    "section": {
      "title": "Our Partners",
      "subtitle": "Working together for a sustainable future"
    },
    "items": [
      {
        "id": 1,
        "name": "Green Earth Foundation",
        "description": "Environmental conservation partner",
        "logo_url": "...",
        "website": "https://greenearth.org"
      }
    ]
  }
}
```

#### 7. ✅ FAQ Section
**New Database Table:** `home_faq_section`
**Existing Table:** `faqs` (already exists)

**Response Structure:**
```json
{
  "faq": {
    "section": {
      "title": "Frequently Asked Questions",
      "subtitle": "Find answers to common questions"
    },
    "items": [
      {
        "id": 1,
        "question": "How can I volunteer?",
        "answer": "You can volunteer by filling out...",
        "category": "General"
      }
    ]
  }
}
```

#### 8. ✅ Contact Section
**New Database Table:** `home_contact_section`

**Response Structure:**
```json
{
  "contact": {
    "title": "Get in Touch",
    "description": "Have questions or want to get involved?",
    "address": "Jl. Lingkungan Hijau No. 123, Jakarta, Indonesia",
    "email": "info@semestalestari.com",
    "phone": "+62 21 1234 5678",
    "work_hours": "Monday - Friday: 9:00 AM - 5:00 PM"
  }
}
```

### 🗄️ Database Changes

**New Tables Created:**
1. `home_statistics` - Statistics section data
2. `home_partners_section` - Partners section header
3. `home_programs_section` - Programs section header
4. `home_faq_section` - FAQ section header
5. `home_contact_section` - Contact section data

**Tables Modified:**
1. `hero_sections` - Added `button_text_2`, `button_url_2`
2. `donation_ctas` - Added `button_text_2`, `button_url_2`
3. `programs` - Added `is_highlighted` field

**New Models Created:**
1. `HomeStatistics.js`
2. `HomePartnersSection.js`
3. `HomeProgramsSection.js`
4. `HomeFaqSection.js`
5. `HomeContactSection.js`

### 📊 Complete Home Page Structure

The `/api/home` endpoint now returns:

```json
{
  "success": true,
  "message": "Home page data retrieved",
  "data": {
    "hero": { /* 2 CTA buttons */ },
    "visions": [ /* Multiple visions */ ],
    "missions": [ /* Multiple missions */ ],
    "impact": [ /* Impact sections */ ],
    "programs": {
      "section": { /* Section header */ },
      "items": [ /* All programs */ ],
      "highlighted": { /* Featured program */ }
    },
    "statistics": {
      "title": "...",
      "subtitle": "...",
      "trees_planted": "10,000+",
      "volunteers": "500+",
      "areas_covered": "25+",
      "partners_count": "50+"
    },
    "donationCta": { /* 2 CTA buttons */ },
    "partners": {
      "section": { /* Section header */ },
      "items": [ /* All partners */ ]
    },
    "faq": {
      "section": { /* Section header */ },
      "items": [ /* All FAQs */ ]
    },
    "contact": {
      "title": "...",
      "description": "...",
      "address": "...",
      "email": "...",
      "phone": "...",
      "work_hours": "..."
    },
    "closingCta": { /* Closing CTA */ }
  }
}
```

### 📚 Swagger Documentation Updated

The Swagger documentation for `/api/home` now includes:
- ✅ Complete response schema
- ✅ All nested objects documented
- ✅ Field types specified
- ✅ Example structure
- ✅ Detailed descriptions

**View in Swagger UI:**
```
http://localhost:3000/api-docs
```
Look for the **Home** section → `GET /api/home`

### 🧪 Test the Endpoint

```bash
# Get complete home page data
curl http://localhost:3000/api/home

# Pretty print with Python
curl -s http://localhost:3000/api/home | python3 -m json.tool
```

### 🎯 Sample Data Seeded

The database has been seeded with sample data for all sections:
- ✅ Hero with 2 buttons
- ✅ 3 Visions
- ✅ 3 Missions
- ✅ 3 Impact sections
- ✅ Programs section with 3 programs (1 highlighted)
- ✅ Statistics with all 4 metrics
- ✅ Donation CTA with 2 buttons
- ✅ Partners section with 3 partners
- ✅ FAQ section with 3 FAQs
- ✅ Contact section with all details
- ✅ Closing CTA

### 🔧 Admin Management

All sections can be managed through admin endpoints:

**Hero Section:**
- `PUT /api/admin/homepage/hero` - Update hero (including both buttons)

**Programs:**
- `GET /api/admin/programs` - Get all programs
- `POST /api/admin/programs` - Create program
- `PUT /api/admin/programs/{id}` - Update program (set `is_highlighted: true`)

**Statistics:**
- Create admin endpoints for `home_statistics` management

**Partners:**
- `GET /api/admin/partners` - Get all partners
- `POST /api/admin/partners` - Create partner

**FAQs:**
- `GET /api/admin/faqs` - Get all FAQs
- `POST /api/admin/faqs` - Create FAQ

**Contact Section:**
- Create admin endpoints for `home_contact_section` management

### ✨ Key Features

1. **Flexible Structure** - Each section has its own table for easy management
2. **Section Headers** - Separate tables for section titles/subtitles
3. **Highlighted Content** - Programs can be marked as highlighted
4. **Multiple CTAs** - Hero and donation sections support 2 buttons each
5. **Complete Contact Info** - All contact details in one place
6. **Organized Data** - Related items grouped with their section headers

### 📝 Next Steps (Optional)

To add admin management for the new sections:

1. Create controllers for:
   - `home_statistics`
   - `home_programs_section`
   - `home_partners_section`
   - `home_faq_section`
   - `home_contact_section`

2. Add routes in `/api/admin/homepage/...`

3. Add Swagger documentation for admin endpoints

### 🎉 Result

The `/api/home` endpoint now provides a complete, structured response with all 8 requested sections:

1. ✅ Hero with 2 CTAs
2. ✅ Visions (multiple)
3. ✅ Missions
4. ✅ Programs with highlighted feature
5. ✅ Statistics (trees, volunteers, areas, partners)
6. ✅ Donation with 2 CTAs
7. ✅ Partners section
8. ✅ FAQ section
9. ✅ Contact section

**Test it now:**
```
http://localhost:3000/api/home
```

All data is seeded and ready to use! 🚀
