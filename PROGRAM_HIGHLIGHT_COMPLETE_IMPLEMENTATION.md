# Program & Leadership Highlight - Complete Implementation

## Overview
Comprehensive highlight management system ensuring only ONE item is highlighted at any time, with automatic reassignment when highlighted items are deleted.

## Features Implemented

### 1. Auto-Unhighlight on CREATE
When creating a new program/leadership with `is_highlighted: true`, all other items are automatically unhighlighted.

```javascript
async create(data) {
  if (data.is_highlighted === true || data.is_highlighted === 1) {
    await pool.query('UPDATE programs SET is_highlighted = FALSE');
  }
  return super.create(data);
}
```

### 2. Auto-Unhighlight on UPDATE
When updating a program/leadership to `is_highlighted: true`, all other items are automatically unhighlighted.

```javascript
async update(id, data) {
  if (data.is_highlighted === true || data.is_highlighted === 1) {
    await pool.query(
      'UPDATE programs SET is_highlighted = FALSE WHERE id != ?',
      [id]
    );
  }
  return super.update(id, data);
}
```

### 3. Auto-Reassign on DELETE
When deleting a highlighted program/leadership, the highlight is automatically assigned to a random active item.

```javascript
async delete(id) {
  const program = await this.findById(id);
  const wasHighlighted = program && (program.is_highlighted === 1 || program.is_highlighted === true);
  
  const deleted = await super.delete(id);
  
  if (deleted && wasHighlighted) {
    const [programs] = await pool.query(
      'SELECT id FROM programs WHERE is_active = TRUE ORDER BY RAND() LIMIT 1'
    );
    
    if (programs.length > 0) {
      await pool.query(
        'UPDATE programs SET is_highlighted = TRUE WHERE id = ?',
        [programs[0].id]
      );
    }
  }
  
  return deleted;
}
```

## Use Cases

### Scenario 1: Create with Highlight
```bash
POST /api/admin/programs
{
  "name": "New Program",
  "is_highlighted": true
}
```
Result: New program is highlighted, all others are unhighlighted.

### Scenario 2: Update to Highlight
```bash
PUT /api/admin/programs/5
{
  "is_highlighted": true
}
```
Result: Program 5 is highlighted, all others are unhighlighted.

### Scenario 3: Delete Highlighted Program
```bash
DELETE /api/admin/programs/5
```
Result: Program 5 is deleted, a random active program is automatically highlighted.

### Scenario 4: Delete Non-Highlighted Program
```bash
DELETE /api/admin/programs/3
```
Result: Program 3 is deleted, current highlight remains unchanged.

## Implementation Details

### Modified Files
1. `src/models/Program.js`
   - Added `create()` method with auto-unhighlight
   - Added `update()` method with auto-unhighlight
   - Added `delete()` method with auto-reassign

2. `src/models/Leadership.js`
   - Added `create()` method with auto-unhighlight
   - Added `update()` method with auto-unhighlight
   - Added `delete()` method with auto-reassign

### Logic Flow

#### CREATE Flow
1. Check if `is_highlighted` is true
2. If yes, unhighlight ALL programs
3. Create new program with highlight

#### UPDATE Flow
1. Check if `is_highlighted` is true
2. If yes, unhighlight all programs EXCEPT current one
3. Update current program

#### DELETE Flow
1. Check if program being deleted is highlighted
2. Delete the program
3. If it was highlighted, find a random active program
4. Assign highlight to that random program

## Testing

### Automated Test
```bash
chmod +x test_program_highlight_complete.sh
./test_program_highlight_complete.sh
```

### Manual Test

#### Test 1: Create with Highlight
```bash
# Login
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@semestalestari.com","password":"admin123"}' \
  | jq -r '.data.accessToken')

# Create program with highlight
curl -X POST http://localhost:3000/api/admin/programs \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Program",
    "is_highlighted": true,
    "is_active": true
  }'

# Check - should show only 1 highlighted
curl -X GET "http://localhost:3000/api/admin/programs?limit=100" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.data[] | select(.is_highlighted == 1)'
```

#### Test 2: Delete Highlighted Program
```bash
# Get highlighted program ID
HIGHLIGHTED_ID=$(curl -s -X GET "http://localhost:3000/api/admin/programs?limit=100" \
  -H "Authorization: Bearer $TOKEN" \
  | jq -r '.data[] | select(.is_highlighted == 1) | .id' | head -1)

# Delete it
curl -X DELETE "http://localhost:3000/api/admin/programs/$HIGHLIGHTED_ID" \
  -H "Authorization: Bearer $TOKEN"

# Check - should show a different program highlighted
curl -X GET "http://localhost:3000/api/admin/programs?limit=100" \
  -H "Authorization: Bearer $TOKEN" \
  | jq '.data[] | select(.is_highlighted == 1)'
```

## Behavior Summary

| Action | Condition | Result |
|--------|-----------|--------|
| CREATE | `is_highlighted: true` | New item highlighted, all others unhighlighted |
| CREATE | `is_highlighted: false` | No change to highlights |
| UPDATE | `is_highlighted: true` | Updated item highlighted, all others unhighlighted |
| UPDATE | `is_highlighted: false` | Item unhighlighted, no other changes |
| DELETE | Item is highlighted | Random active item gets highlighted |
| DELETE | Item not highlighted | No change to highlights |

## Database Schema
```sql
CREATE TABLE programs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  image_url VARCHAR(500),
  is_highlighted BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  order_position INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE leadership (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  position VARCHAR(255),
  bio TEXT,
  image_url VARCHAR(500),
  is_highlighted BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  order_position INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## Notes
- Only active items (`is_active = TRUE`) can receive highlight on auto-reassign
- Random selection uses MySQL's `RAND()` function
- If no active items exist after deletion, no item will be highlighted
- Each entity type (programs, leadership) maintains independent highlights
- The feature is fully backward compatible

## Cleanup Scripts
If you need to fix existing data:
```bash
node src/scripts/fixProgramHighlight.js
node src/scripts/fixLeadershipHighlight.js
```

## Status
✅ CREATE with auto-unhighlight
✅ UPDATE with auto-unhighlight
✅ DELETE with auto-reassign
✅ Random selection for reassignment
✅ Only active items eligible for highlight
✅ Independent per entity type
✅ Fully tested
✅ Production ready
