# Programs Data Synchronization Confirmation

## Summary
Programs data between `/api/home` and `/api/programs` is already synchronized and using the same database table.

## Date
February 19, 2026

---

## Current Implementation

### Data Source: SAME ✅

Both endpoints use the **same `programs` table** via the **same `Program` model**.

```
/api/programs        → Program.findAll(true) → programs table
/api/home (programs) → Program.findAll(true) → programs table
```

---

## Endpoint Comparison

### 1. GET /api/programs

**Response:**
```json
{
  "success": true,
  "message": "Program retrieved",
  "data": [
    {
      "id": 19,
      "name": "Tree Planting Initiative",
      "description": "Planting trees across communities to combat climate change",
      "image_url": null,
      "is_highlighted": 1,
      "order_position": 1,
      "is_active": 1,
      "created_at": "2026-02-19T06:52:04.000Z",
      "updated_at": "2026-02-19T06:52:04.000Z"
    }
  ]
}
```

### 2. GET /api/home (programs section)

**Response:**
```json
{
  "programs": {
    "section": {
      "id": 1,
      "title": "Our Programs",
      "subtitle": "Making a difference through various initiatives",
      "is_active": 1,
      "created_at": "2026-02-19T04:42:02.000Z",
      "updated_at": "2026-02-19T04:42:02.000Z"
    },
    "items": [
      {
        "id": 19,
        "name": "Tree Planting Initiative",
        "description": "Planting trees across communities to combat climate change",
        "image_url": null,
        "is_highlighted": 1,
        "order_position": 1,
        "is_active": 1,
        "created_at": "2026-02-19T06:52:04.000Z",
        "updated_at": "2026-02-19T06:52:04.000Z"
      }
    ],
    "highlighted": {
      "id": 19,
      "name": "Tree Planting Initiative",
      ...
    }
  }
}
```

---

## Key Differences

### /api/programs
- Returns: Array of programs directly
- Purpose: Dedicated programs endpoint
- Use case: Programs listing page

### /api/home (programs section)
- Returns: Object with `section`, `items`, and `highlighted`
- Purpose: Home page presentation
- Additional data:
  - `section`: Title and subtitle for the programs section
  - `highlighted`: The featured/highlighted program
- Use case: Home page programs showcase

---

## Database Tables

### programs Table (Shared) ✅
```sql
CREATE TABLE programs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  image_url VARCHAR(500),
  is_highlighted BOOLEAN DEFAULT FALSE,
  order_position INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**Used by:**
- `/api/programs`
- `/api/home` (programs.items)
- `/api/admin/programs`

### home_programs_section Table (Home Page Metadata)
```sql
CREATE TABLE home_programs_section (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  subtitle TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**Used by:**
- `/api/home` (programs.section) - Only for title/subtitle
- `/api/admin/homepage/programs-section` - Admin management

**Purpose:** Stores presentation metadata (title, subtitle) for the home page programs section.

---

## Data Flow

### When Admin Updates a Program

```
Admin updates program
         ↓
PUT /api/admin/programs/:id
         ↓
Updates programs table
         ↓
    Affects both endpoints:
    ├── GET /api/programs (updated program in list)
    └── GET /api/home (updated program in programs.items)
```

### When Admin Updates Section Metadata

```
Admin updates section title/subtitle
         ↓
PUT /api/admin/homepage/programs-section
         ↓
Updates home_programs_section table
         ↓
    Affects only:
    └── GET /api/home (programs.section)
```

---

## Verification Tests

### Test 1: Data Consistency
```bash
# Get programs from /api/programs
curl http://localhost:3000/api/programs | jq '.data[0]' > programs_endpoint.json

# Get programs from /api/home
curl http://localhost:3000/api/home | jq '.data.programs.items[0]' > home_programs.json

# Compare
diff programs_endpoint.json home_programs.json
```

**Result:** ✅ Identical program data

### Test 2: Update Synchronization
```bash
# Login as admin
TOKEN=$(curl -s -X POST http://localhost:3000/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' \
  | jq -r '.data.accessToken')

# Update a program
curl -X PUT http://localhost:3000/api/admin/programs/19 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated Program Name"}'

# Verify in both endpoints
curl http://localhost:3000/api/programs | jq '.data[] | select(.id==19)'
curl http://localhost:3000/api/home | jq '.data.programs.items[] | select(.id==19)'
```

**Result:** ✅ Update reflects in both endpoints

---

## Why This Design is Correct

### 1. Shared Core Data
- Program details (name, description, image, etc.) are shared
- Single source of truth for program information
- Updates automatically sync across endpoints

### 2. Presentation-Specific Metadata
- Home page needs section title/subtitle for UI
- This is presentation logic, not core data
- Separate table is appropriate for this use case

### 3. Flexibility
- `/api/programs` can be used for dedicated programs page
- `/api/home` includes additional context for home page
- Both use the same underlying program data

---

## Admin Management

### Program Data (Shared)
```
GET    /api/admin/programs           - List all programs
POST   /api/admin/programs           - Create program
GET    /api/admin/programs/:id       - Get single program
PUT    /api/admin/programs/:id       - Update program
DELETE /api/admin/programs/:id       - Delete program
```

**Affects:** Both `/api/programs` and `/api/home`

### Section Metadata (Home Page Only)
```
GET /api/admin/homepage/programs-section  - Get section metadata
PUT /api/admin/homepage/programs-section  - Update section metadata
```

**Affects:** Only `/api/home` (programs.section)

---

## Highlighted Program Feature

The `/api/home` endpoint includes a `highlighted` field that contains the featured program:

```javascript
// In homeController.js
const highlightedProgram = programs.find(p => p.is_highlighted) || null;

return {
  programs: {
    section: programsSection,
    items: programs,
    highlighted: highlightedProgram  // Featured program
  }
}
```

This is a convenience feature for the home page to easily access the featured program without filtering on the frontend.

---

## Conclusion

✅ Programs data is **already synchronized**  
✅ Both endpoints use the **same `programs` table**  
✅ Updates to programs affect **both endpoints**  
✅ Section metadata (title/subtitle) is **appropriately separated**  
✅ Design follows **best practices**  

**Status:** Already Synchronized - No Changes Needed

---

## Data Consistency Guarantee

Since both endpoints query the same `programs` table using the same `Program` model:

1. **Create:** New program appears in both endpoints immediately
2. **Update:** Changes reflect in both endpoints immediately
3. **Delete:** Removal affects both endpoints immediately
4. **Ordering:** `order_position` field controls display order in both
5. **Visibility:** `is_active` field controls visibility in both
6. **Highlighting:** `is_highlighted` field works across both

---

## Frontend Usage

### For Programs Listing Page
```javascript
// Use dedicated endpoint
const response = await fetch('/api/programs');
const programs = response.data; // Array of programs
```

### For Home Page
```javascript
// Use home endpoint
const response = await fetch('/api/home');
const { section, items, highlighted } = response.data.programs;

// Display section title
<h2>{section.title}</h2>
<p>{section.subtitle}</p>

// Display programs
{items.map(program => <ProgramCard {...program} />)}

// Display highlighted program
<FeaturedProgram {...highlighted} />
```

---

## Summary

The programs data is already properly synchronized between `/api/home` and `/api/programs`. Both endpoints:

- Use the same `programs` table
- Use the same `Program` model  
- Return identical program data
- Automatically sync when programs are updated

The only difference is that `/api/home` includes additional presentation metadata (section title/subtitle) which is appropriate for its use case.

**No changes needed - system is working as designed!** ✅

---

**Verification Date:** February 19, 2026  
**Status:** Already Synchronized  
**Action Required:** None
