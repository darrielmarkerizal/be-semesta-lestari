# FAQs Section - Quick Reference

## Overview
FAQs section with header settings (title, subtitle, image) and FAQ items list.

## API Endpoints

### Public Endpoints

#### GET /api/faqs
Returns FAQs section with header and items.

**Response:**
```json
{
  "success": true,
  "message": "FAQs section retrieved",
  "data": {
    "section": {
      "id": 1,
      "title": "Frequently Asked Questions",
      "subtitle": "Find answers to common questions",
      "image_url": "/uploads/faqs/hero.jpg",
      "is_active": true
    },
    "items": [
      {
        "id": 1,
        "question": "What is your mission?",
        "answer": "Our mission is to protect the environment...",
        "category": "General",
        "order_position": 1,
        "is_active": true
      }
    ]
  }
}
```

### Admin Endpoints

#### GET /api/admin/homepage/faq-section
Get FAQ section settings.

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "success": true,
  "data": {
    "section": {
      "id": 1,
      "title": "Frequently Asked Questions",
      "subtitle": "Find answers to common questions",
      "image_url": "/uploads/faqs/hero.jpg",
      "is_active": true
    },
    "items": [...]
  }
}
```

#### PUT /api/admin/homepage/faq-section
Update FAQ section settings.

**Headers:** `Authorization: Bearer {token}`

**Body:**
```json
{
  "title": "FAQs",
  "subtitle": "Common questions answered",
  "image_url": "/uploads/faqs/new-hero.jpg"
}
```

#### GET /api/admin/faqs
List all FAQ items.

**Headers:** `Authorization: Bearer {token}`

**Query Params:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)
- `all=true` (optional): Get all items without pagination

#### GET /api/admin/faqs/:id
Get single FAQ item.

**Headers:** `Authorization: Bearer {token}`

#### POST /api/admin/faqs
Create new FAQ item.

**Headers:** `Authorization: Bearer {token}`

**Body:**
```json
{
  "question": "What is your mission?",
  "answer": "Our mission is to...",
  "category": "General",
  "order_position": 1,
  "is_active": true
}
```

#### PUT /api/admin/faqs/:id
Update FAQ item.

**Headers:** `Authorization: Bearer {token}`

**Body:**
```json
{
  "question": "Updated question?",
  "answer": "Updated answer",
  "category": "Updated Category"
}
```

#### DELETE /api/admin/faqs/:id
Delete FAQ item.

**Headers:** `Authorization: Bearer {token}`

## Database Tables

### home_faq_section
Section header settings.

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| title | VARCHAR(255) | Section title |
| subtitle | VARCHAR(255) | Section subtitle |
| image_url | VARCHAR(500) | Hero image URL |
| is_active | BOOLEAN | Active status |
| created_at | TIMESTAMP | Creation time |
| updated_at | TIMESTAMP | Last update time |

### faqs
FAQ items.

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| question | VARCHAR(500) | FAQ question |
| answer | TEXT | FAQ answer |
| category | VARCHAR(100) | FAQ category |
| order_position | INT | Display order |
| is_active | BOOLEAN | Active status |
| created_at | TIMESTAMP | Creation time |
| updated_at | TIMESTAMP | Last update time |

## Testing

Run complete test suite:
```bash
./test_faqs_complete.sh
```

**Test Coverage:**
- 67 total tests
- 100% success rate
- Public endpoints (12 tests)
- Admin section settings (10 tests)
- Admin FAQ items CRUD (14 tests)
- Data structure validation (17 tests)
- Authorization (6 tests)
- Edge cases (8 tests)

## Common Tasks

### Update Section Header
```bash
curl -X PUT http://localhost:3000/api/admin/homepage/faq-section \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "FAQs",
    "subtitle": "Common questions",
    "image_url": "/uploads/faqs/hero.jpg"
  }'
```

### Add New FAQ
```bash
curl -X POST http://localhost:3000/api/admin/faqs \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "question": "What is your mission?",
    "answer": "Our mission is...",
    "category": "General",
    "order_position": 1,
    "is_active": true
  }'
```

### Get FAQs (Public)
```bash
curl http://localhost:3000/api/faqs
```

## Files

- `src/models/FAQ.js` - FAQ items model
- `src/models/HomeFaqSection.js` - Section settings model
- `src/controllers/faqController.js` - FAQ controllers
- `src/controllers/adminHomeController.js` - Admin section controller
- `src/scripts/addFaqImageUrl.js` - Migration script
- `src/scripts/cleanupFaqSectionDuplicates.js` - Cleanup script
- `test_faqs_complete.sh` - Test script
- `FAQS_TEST_REPORT.md` - Detailed test report

## Model Synchronization

The FAQ section follows the same pattern as Impact and Partners:

### Pattern Structure
- **Section Settings Table**: `home_faq_section` (singular)
  - Stores: title, subtitle, image_url, is_active
  - Model: `HomeFaqSection`
  
- **Items Table**: `faqs` (plural)
  - Stores: question, answer, category, order_position, is_active
  - Model: `FAQ`

### Key Characteristics
- No foreign key relationship between tables
- Conceptually related but independently managed
- Public endpoint returns both in one call
- Admin endpoints manage separately
- Consistent with Impact and Partners implementation

## Notes

- Section and items are separate tables (no foreign key relationship)
- Public endpoint returns both section and items in one call
- Admin endpoints manage section and items separately
- Pattern matches impact and partners section implementation
- All tests passing at 100%
- Models synchronized across all sections (Impact, Partners, FAQs)
