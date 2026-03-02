# Highlight Feature - Complete Quick Reference

## What It Does
- ✅ Only ONE item can be highlighted at a time
- ✅ Creating with highlight → auto-unhighlights others
- ✅ Updating to highlight → auto-unhighlights others
- ✅ Deleting highlighted item → assigns to random active item

## Entities
- Programs (`/api/admin/programs`)
- Leadership (`/api/admin/leadership`)

## API Examples

### Create with Highlight
```bash
POST /api/admin/programs
Authorization: Bearer {token}

{
  "name": "New Program",
  "description": "Description",
  "is_highlighted": true,
  "is_active": true
}
```
→ New program highlighted, all others unhighlighted

### Update to Highlight
```bash
PUT /api/admin/programs/5
Authorization: Bearer {token}

{
  "is_highlighted": true
}
```
→ Program 5 highlighted, all others unhighlighted

### Delete Highlighted
```bash
DELETE /api/admin/programs/5
Authorization: Bearer {token}
```
→ Program 5 deleted, random active program highlighted

### Delete Non-Highlighted
```bash
DELETE /api/admin/programs/3
Authorization: Bearer {token}
```
→ Program 3 deleted, highlight unchanged

## Behavior Matrix

| Action | Input | Result |
|--------|-------|--------|
| POST | `is_highlighted: true` | New item ✅, Others ❌ |
| POST | `is_highlighted: false` | No change |
| PUT | `is_highlighted: true` | Target ✅, Others ❌ |
| PUT | `is_highlighted: false` | Target ❌, Others unchanged |
| DELETE | Highlighted item | Random item ✅ |
| DELETE | Non-highlighted | No change |

## Testing
```bash
# Complete test
./test_program_highlight_complete.sh

# Cleanup if needed
node src/scripts/fixProgramHighlight.js
node src/scripts/fixLeadershipHighlight.js
```

## Key Points
- Only 1 item highlighted per entity type
- Auto-reassign uses random active item
- If no active items, none highlighted
- Programs and Leadership independent
- Fully automatic, no manual management needed
