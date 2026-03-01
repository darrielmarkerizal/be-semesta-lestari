#!/usr/bin/env node

/**
 * Direct Database Unit Test for Gallery Category Filter
 * Tests gallery category filtering logic without requiring running server
 */

const { pool } = require('./src/config/database');
const GalleryItem = require('./src/models/GalleryItem');

// Colors for output
const GREEN = '\x1b[32m';
const RED = '\x1b[31m';
const YELLOW = '\x1b[33m';
const BLUE = '\x1b[34m';
const NC = '\x1b[0m'; // No Color

let testsPassed = 0;
let testsFailed = 0;

function printResult(passed, testName, details = null) {
  if (passed) {
    testsPassed++;
    console.log(`${GREEN}✓ PASS${NC}: ${testName}`);
    if (details) console.log(`  ${BLUE}${details}${NC}`);
  } else {
    testsFailed++;
    console.log(`${RED}✗ FAIL${NC}: ${testName}`);
    if (details) console.log(`  ${RED}${details}${NC}`);
  }
}

async function runTests() {
  console.log(`${YELLOW}=== Gallery Category Filter Database Test ===${NC}\n`);

  try {
    // Test 1: Database connection
    console.log(`${YELLOW}Test 1: Database connection${NC}`);
    try {
      await pool.query('SELECT 1');
      printResult(true, 'Database connection successful');
    } catch (error) {
      printResult(false, 'Database connection failed', error.message);
      process.exit(1);
    }

    // Test 2: Check gallery_items table
    console.log(`\n${YELLOW}Test 2: Gallery items table${NC}`);
    const [tables] = await pool.query("SHOW TABLES LIKE 'gallery_items'");
    printResult(tables.length > 0, 'Gallery items table exists');

    // Test 3: Check gallery_categories table
    console.log(`\n${YELLOW}Test 3: Gallery categories table${NC}`);
    const [catTables] = await pool.query("SHOW TABLES LIKE 'gallery_categories'");
    printResult(catTables.length > 0, 'Gallery categories table exists');

    // Test 4: Get all categories
    console.log(`\n${YELLOW}Test 4: Retrieve all categories${NC}`);
    const [categories] = await pool.query('SELECT id, name, slug FROM gallery_categories ORDER BY id');
    if (categories.length > 0) {
      printResult(true, 'Retrieved gallery categories', `Found ${categories.length} categories`);
      categories.forEach(cat => {
        console.log(`  - ${cat.name} (id: ${cat.id}, slug: ${cat.slug})`);
      });
    } else {
      printResult(false, 'No categories found');
    }

    // Test 5: Count items per category
    console.log(`\n${YELLOW}Test 5: Count items per category${NC}`);
    const [counts] = await pool.query(`
      SELECT gc.id, gc.name, COUNT(gi.id) as item_count
      FROM gallery_categories gc
      LEFT JOIN gallery_items gi ON gc.id = gi.category_id
      GROUP BY gc.id, gc.name
      ORDER BY gc.id
    `);
    
    if (counts.length > 0) {
      printResult(true, 'Counted items per category');
      counts.forEach(cat => {
        console.log(`  - ${cat.name}: ${cat.item_count} items`);
      });
    } else {
      printResult(false, 'Failed to count items per category');
    }

    // Test 6: Test GalleryItem.findAllPaginated with category filter
    console.log(`\n${YELLOW}Test 6: GalleryItem model with category filter${NC}`);
    try {
      const result = await GalleryItem.findAllPaginated(1, 12, true, 'events', null);
      if (result && result.data && result.total !== undefined) {
        const allAreEvents = result.data.every(item => item.category_slug === 'events');
        if (allAreEvents) {
          printResult(true, 'Category filter works correctly', `Found ${result.total} items in Events category`);
        } else {
          printResult(false, 'Category filter returned wrong items');
        }
      } else {
        printResult(false, 'Invalid response structure from model');
      }
    } catch (error) {
      printResult(false, 'Model method failed', error.message);
    }

    // Test 7: Test pagination with category filter
    console.log(`\n${YELLOW}Test 7: Pagination with category filter${NC}`);
    try {
      const page1 = await GalleryItem.findAllPaginated(1, 2, true, 'events', null);
      const page2 = await GalleryItem.findAllPaginated(2, 2, true, 'events', null);
      
      if (page1.data.length <= 2 && page2.data.length <= 2) {
        const noDuplicates = !page1.data.some(i1 => page2.data.some(i2 => i1.id === i2.id));
        if (noDuplicates) {
          printResult(true, 'Pagination with category filter works', 
            `Page 1: ${page1.data.length} items, Page 2: ${page2.data.length} items`);
        } else {
          printResult(false, 'Pagination returned duplicate items');
        }
      } else {
        printResult(false, 'Pagination returned too many items');
      }
    } catch (error) {
      printResult(false, 'Pagination test failed', error.message);
    }

    // Test 8: Test each category
    console.log(`\n${YELLOW}Test 8: Test filtering for each category${NC}`);
    for (const category of categories) {
      try {
        const result = await GalleryItem.findAllPaginated(1, 12, true, category.slug, null);
        const allMatch = result.data.every(item => item.category_id === category.id);
        if (allMatch) {
          printResult(true, `${category.name} category filter works`, `${result.total} total items`);
        } else {
          printResult(false, `${category.name} category filter returned wrong items`);
        }
      } catch (error) {
        printResult(false, `Failed to filter ${category.name}`, error.message);
      }
    }

    // Test 9: Test with search and category filter combined
    console.log(`\n${YELLOW}Test 9: Combined search and category filter${NC}`);
    try {
      const result = await GalleryItem.findAllPaginated(1, 12, true, 'events', 'tree');
      const allAreEvents = result.data.every(item => item.category_slug === 'events');
      if (allAreEvents || result.data.length === 0) {
        printResult(true, 'Combined search and category filter works', 
          `Found ${result.total} items matching "tree" in Events`);
      } else {
        printResult(false, 'Combined filter returned wrong category items');
      }
    } catch (error) {
      printResult(false, 'Combined filter test failed', error.message);
    }

    // Test 10: Test category info in results
    console.log(`\n${YELLOW}Test 10: Verify category info in results${NC}`);
    try {
      const result = await GalleryItem.findAllPaginated(1, 1, true, 'events', null);
      if (result.data.length > 0) {
        const item = result.data[0];
        const hasCategoryId = 'category_id' in item;
        const hasCategoryName = 'category_name' in item;
        const hasCategorySlug = 'category_slug' in item;
        
        if (hasCategoryId && hasCategoryName && hasCategorySlug) {
          printResult(true, 'Items include complete category information', 
            `${item.category_name} (${item.category_slug})`);
        } else {
          printResult(false, 'Items missing category information');
        }
      } else {
        printResult(false, 'No items found to verify');
      }
    } catch (error) {
      printResult(false, 'Category info verification failed', error.message);
    }

    // Test 11: Test invalid category slug
    console.log(`\n${YELLOW}Test 11: Test invalid category slug${NC}`);
    try {
      const result = await GalleryItem.findAllPaginated(1, 12, true, 'nonexistent-category', null);
      if (result.data.length === 0 && result.total === 0) {
        printResult(true, 'Invalid category returns empty results', 'As expected');
      } else {
        printResult(false, 'Invalid category should return empty results');
      }
    } catch (error) {
      printResult(false, 'Invalid category test failed', error.message);
    }

    // Test 12: Test ordering with category filter
    console.log(`\n${YELLOW}Test 12: Test ordering with category filter${NC}`);
    try {
      const result = await GalleryItem.findAllPaginated(1, 10, true, 'events', null);
      if (result.data.length >= 2) {
        const firstDate = new Date(result.data[0].gallery_date);
        const secondDate = new Date(result.data[1].gallery_date);
        
        if (firstDate >= secondDate) {
          printResult(true, 'Items ordered by date DESC correctly', 
            `${result.data[0].gallery_date} >= ${result.data[1].gallery_date}`);
        } else {
          printResult(false, 'Items not ordered correctly');
        }
      } else {
        printResult(true, 'Not enough items to test ordering', 'Skipped');
      }
    } catch (error) {
      printResult(false, 'Ordering test failed', error.message);
    }

  } catch (error) {
    console.error(`${RED}Unexpected error: ${error.message}${NC}`);
    testsFailed++;
  } finally {
    await pool.end();
  }

  // Print summary
  console.log(`\n${YELLOW}=== Test Summary ===${NC}`);
  console.log(`Total Tests: ${testsPassed + testsFailed}`);
  console.log(`${GREEN}Passed: ${testsPassed}${NC}`);
  console.log(`${RED}Failed: ${testsFailed}${NC}`);

  if (testsFailed === 0) {
    console.log(`\n${GREEN}All tests passed! ✓${NC}`);
    console.log(`\n${GREEN}Gallery category filtering is working correctly!${NC}`);
    process.exit(0);
  } else {
    console.log(`\n${RED}Some tests failed. Please check the output above.${NC}`);
    process.exit(1);
  }
}

// Run tests
runTests().catch(error => {
  console.error(`${RED}Fatal error: ${error.message}${NC}`);
  process.exit(1);
});
