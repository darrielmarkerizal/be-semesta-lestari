# Program Auto-Unhighlight Feature

## Overview
Implemented automatic unhighlighting for programs. When one program is highlighted, all other programs are automatically unhighlighted, ensuring only one program can be highlighted at a time.

## Implementation

### Modified Files
- `src/models/Program.js` - Added custom `update()` method with auto-unhighlight logic

### How It Works
1. When updating a program with `is_highlighted: true`, the system first sets all other programs' `is_highlighted` to `false`
2. Then updates the target program with the new data
3. This ensures only one program is highlighted at any given time

### Code Changes

```javascript
// src/models/Program.js
async update(id, data) {
  // If setting is_highlighted to true, first unhighlight all other programs
  if (data.is_highlighted === true || data.is_highlighted === 1) {
    await pool.query(
      'UPDATE programs SET is_highlighted = FALSE WHERE id != ?',
      [id]
    );
  }
  
  // Call parent update method
  return super.update(id, data);
}
```

## API Usage

### Highlight a Program
```bash
PUT /api/admin/programs/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "is_highlighted": true
}
```

When you highlight Program B, Program A (if previously highlighted) will automatically be unhighlighted.

### Unhighlight a Program
```bash
PUT /api/admin/programs/{id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "is_highlighted": false
}
```

## Testing

Run the test script:
```bash
./test_program_highlight.sh
```

### Test Scenarios
1. Highlight Program A → Only Program A is highlighted
2. Highlight Program B → Only Program B is highlighted (Program A auto-unhighlighted)
3. Highlight Program C → Only Program C is highlighted (Program B auto-unhighlighted)
4. Unhighlight Program C → No programs are highlighted

## Database Schema
The `programs` table has an `is_highlighted` BOOLEAN column:
```sql
is_highlighted BOOLEAN DEFAULT FALSE
```

## Behavior
- Only one program can be highlighted at a time
- Setting `is_highlighted: true` on any program automatically sets all other programs' `is_highlighted` to `false`
- Setting `is_highlighted: false` simply unhighlights that program without affecting others
- The highlighted program typically appears on the homepage or in featured sections

## Similar Features
This pattern is also implemented in:
- Leadership members (`is_highlighted` column in `leadership` table) - Same auto-unhighlight behavior
- Both models use the same pattern: when one item is highlighted, all others are automatically unhighlighted

## Notes
- The auto-unhighlight logic only triggers when explicitly setting `is_highlighted` to `true` (or `1`)
- Updating other fields (name, description, etc.) without touching `is_highlighted` won't trigger the auto-unhighlight
- The feature works for both admin create and update operations
