# Auto-Unhighlight Feature - Quick Reference

## What It Does
Ensures only ONE item can be highlighted at a time. When you highlight item B, item A is automatically unhighlighted.

## Entities with Auto-Unhighlight
1. Programs (`/api/admin/programs/{id}`)
2. Leadership (`/api/admin/leadership/{id}`)

## Usage

### Highlight an Item
```bash
PUT /api/admin/programs/{id}
# or
PUT /api/admin/leadership/{id}

Authorization: Bearer {token}
Content-Type: application/json

{
  "is_highlighted": true
}
```

Result: The specified item becomes highlighted, all others are automatically unhighlighted.

### Unhighlight an Item
```bash
PUT /api/admin/programs/{id}
# or
PUT /api/admin/leadership/{id}

Authorization: Bearer {token}
Content-Type: application/json

{
  "is_highlighted": false
}
```

Result: The specified item is unhighlighted, no other items are affected.

## Behavior
- ✅ Only one item can be highlighted at a time per entity type
- ✅ Highlighting item B automatically unhighlights item A
- ✅ Unhighlighting an item doesn't affect others
- ✅ Works independently for each entity (1 program + 1 leadership can both be highlighted)

## Testing
```bash
# Test programs
./test_program_highlight.sh

# Test leadership (if test script exists)
./test_leadership_highlight.sh
```

## Implementation
Both models override the `update()` method:
```javascript
async update(id, data) {
  if (data.is_highlighted === true || data.is_highlighted === 1) {
    await pool.query(
      'UPDATE {table} SET is_highlighted = FALSE WHERE id != ?',
      [id]
    );
  }
  return super.update(id, data);
}
```

## Database
Both tables have:
```sql
is_highlighted BOOLEAN DEFAULT FALSE
```

## Common Use Cases
- Featured program on homepage
- Featured leadership member in about section
- Spotlight content in various sections
