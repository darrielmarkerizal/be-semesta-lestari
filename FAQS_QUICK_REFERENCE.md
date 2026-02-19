# FAQs API - Quick Reference

## Status: ✅ Complete & Synchronized

---

## Quick Facts

- **Synchronized:** Yes - `/api/faqs` and `/api/home` use same `faqs` table
- **CRUD Operations:** All implemented at `/api/admin/faqs`
- **Tests:** 13/13 passed (100%)
- **Authentication:** Required for admin endpoints only

---

## Public Endpoints

```bash
# Get all FAQs
GET /api/faqs

# Get single FAQ
GET /api/faqs/:id

# FAQs in home page
GET /api/home
# Returns: data.faq.items (array of FAQs)
```

---

## Admin Endpoints

All require `Authorization: Bearer {token}`

```bash
# List FAQs (paginated)
GET /api/admin/faqs?page=1&limit=10

# Get single FAQ
GET /api/admin/faqs/:id

# Create FAQ
POST /api/admin/faqs
{
  "question": "Your question here?",
  "answer": "Your detailed answer here.",
  "category": "General",
  "order_position": 0,
  "is_active": true
}

# Update FAQ
PUT /api/admin/faqs/:id
{
  "question": "Updated question?",
  "answer": "Updated answer."
}

# Delete FAQ
DELETE /api/admin/faqs/:id
```

---

## Required Fields

- ✅ `question` (string, max 500 chars)
- ✅ `answer` (text, long)

## Optional Fields

- `category` (string, max 100 chars)
- `order_position` (integer, default: 0)
- `is_active` (boolean, default: true)

---

## Test Script

```bash
# Run all tests
./test_faqs_api.sh
```

---

## Common Categories

- General
- Volunteer
- Donation
- Programs
- Environment
- Membership

---

## Data Flow

```
Admin creates/updates FAQ
        ↓
    faqs table
        ↓
    ┌───────┴───────┐
    ↓               ↓
/api/faqs      /api/home
(public)       (faq.items)
```

---

## Authentication

```bash
# Login to get token
curl -X POST "http://localhost:3000/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}'

# Use token in requests
curl -H "Authorization: Bearer {token}" \
  "http://localhost:3000/api/admin/faqs"
```

---

## Files

- **Controller:** `src/controllers/faqController.js`
- **Model:** `src/models/FAQ.js`
- **Routes:** `src/routes/public.js`, `src/routes/admin.js`
- **Tests:** `test_faqs_api.sh`
- **Summary:** `FAQS_COMPLETE_SUMMARY.md`

---

**Last Updated:** February 19, 2026
