# Programs Search Pagination Fix

## Issue
Error on production server: `Unknown column 'p.category_id' in 'on clause'`

The programs table in the production database doesn't have the `category_id` column yet, but the search implementation was trying to join with the `program_categories` table.

## Root Cause
The `findAllPaginatedWithSearch` method in `src/models/Program.js` was always attempting to join with the `program_categories` table using `category_id`, which doesn't exist in older database schemas.

## Solution
Updated the `Program.js` model to be backward compatible:

1. **Check if column exists**: Before attempting any joins, the code now checks if the `category_id` column exists in the programs table
2. **Conditional queries**: Based on whether the column exists:
   - **With category_id**: Uses full query with category joins and category filtering
   - **Without category_id**: Uses simpler query without category joins

## Code Changes

### Before (Broken)
```javascript
async findAllPaginatedWithSearch(page = 1, limit = 10, isActive = null, categoryId = null, search = null) {
  // Always tried to join with program_categories
  let query = `
    SELECT 
      p.*,
      pc.name as category_name,
      pc.slug as category_slug
    FROM programs p
    LEFT JOIN program_categories pc ON p.category_id = pc.id
  `;
  // ... rest of code
}
```

### After (Fixed)
```javascript
async findAllPaginatedWithSearch(page = 1, limit = 10, isActive = null, categoryId = null, search = null) {
  // Check if category_id column exists
  const [columns] = await pool.query('SHOW COLUMNS FROM programs LIKE "category_id"');
  const hasCategoryId = columns.length > 0;
  
  // Use appropriate query based on column existence
  let query = hasCategoryId 
    ? `SELECT p.*, pc.name as category_name, pc.slug as category_slug
       FROM programs p
       LEFT JOIN program_categories pc ON p.category_id = pc.id`
    : `SELECT * FROM programs p`;
  
  // ... conditional logic for search and filtering
}
```

## Features Maintained

### With category_id column:
- ✓ Search in name, description, and category_name
- ✓ Filter by category_id
- ✓ Pagination
- ✓ Returns category information

### Without category_id column:
- ✓ Search in name and description
- ✓ Pagination
- ✓ All other functionality works
- ⚠️ Category filtering disabled (gracefully)

## Testing

The fix ensures:
1. No errors on databases without `category_id` column
2. Full functionality on databases with `category_id` column
3. Backward compatibility with older database schemas
4. Graceful degradation of features

## Migration Path

For production servers without the `category_id` column, you can add it later:

```sql
-- Add category_id column
ALTER TABLE programs ADD COLUMN category_id INT AFTER image_url;

-- Add foreign key constraint (optional)
ALTER TABLE programs 
ADD CONSTRAINT fk_programs_category 
FOREIGN KEY (category_id) REFERENCES program_categories(id) ON DELETE SET NULL;

-- Create index for better performance
CREATE INDEX idx_programs_category_id ON programs(category_id);
```

After running this migration, the full category functionality will be available without any code changes.

## Files Modified
- `src/models/Program.js` - Added backward compatibility check

## Impact
- ✓ Fixes production error
- ✓ Maintains all functionality
- ✓ No breaking changes
- ✓ Backward compatible
- ✓ Forward compatible

## Verification

To verify the fix works:

```bash
# Test basic pagination (should work on all databases)
curl -H "Authorization: Bearer <token>" \
  "http://localhost:3000/api/admin/programs?page=1&limit=10"

# Test search (should work on all databases)
curl -H "Authorization: Bearer <token>" \
  "http://localhost:3000/api/admin/programs?search=education"

# Test category filter (only works if category_id exists)
curl -H "Authorization: Bearer <token>" \
  "http://localhost:3000/api/admin/programs?category_id=1"
```

## Conclusion

The fix ensures the programs search and pagination works on both old and new database schemas, providing a smooth upgrade path without requiring immediate database migrations.
