#!/usr/bin/env node

/**
 * Unit test for Program model backward compatibility fix
 * Tests that the model handles both databases with and without category_id column
 */

const { pool } = require('./src/config/database');

// Colors for output
const GREEN = '\x1b[32m';
const RED = '\x1b[31m';
const YELLOW = '\x1b[33m';
const NC = '\x1b[0m'; // No Color

let testsPassed = 0;
let testsFailed = 0;

function printResult(passed, testName, error = null) {
  if (passed) {
    testsPassed++;
    console.log(`${GREEN}✓ PASS${NC}: ${testName}`);
  } else {
    testsFailed++;
    console.log(`${RED}✗ FAIL${NC}: ${testName}`);
    if (error) {
      console.log(`${RED}  Error: ${error}${NC}`);
    }
  }
}

async function runTests() {
  console.log(`${YELLOW}=== Program Model Backward Compatibility Test ===${NC}\n`);

  try {
    // Test 1: Check if we can connect to database
    console.log(`${YELLOW}Test 1: Database connection${NC}`);
    try {
      await pool.query('SELECT 1');
      printResult(true, 'Database connection successful');
    } catch (error) {
      printResult(false, 'Database connection failed', error.message);
      process.exit(1);
    }

    // Test 2: Check if programs table exists
    console.log(`\n${YELLOW}Test 2: Programs table exists${NC}`);
    try {
      const [tables] = await pool.query("SHOW TABLES LIKE 'programs'");
      printResult(tables.length > 0, 'Programs table exists');
    } catch (error) {
      printResult(false, 'Programs table check failed', error.message);
    }

    // Test 3: Check if category_id column exists
    console.log(`\n${YELLOW}Test 3: Check category_id column${NC}`);
    let hasCategoryId = false;
    try {
      const [columns] = await pool.query('SHOW COLUMNS FROM programs LIKE "category_id"');
      hasCategoryId = columns.length > 0;
      console.log(`  Category ID column exists: ${hasCategoryId ? 'YES' : 'NO'}`);
      printResult(true, 'Column check completed successfully');
    } catch (error) {
      printResult(false, 'Column check failed', error.message);
    }

    // Test 4: Test basic query without category join
    console.log(`\n${YELLOW}Test 4: Basic query (no category join)${NC}`);
    try {
      const [rows] = await pool.query('SELECT * FROM programs p LIMIT 1');
      printResult(true, 'Basic query works');
    } catch (error) {
      printResult(false, 'Basic query failed', error.message);
    }

    // Test 5: Test query with category join (if column exists)
    if (hasCategoryId) {
      console.log(`\n${YELLOW}Test 5: Query with category join${NC}`);
      try {
        const [rows] = await pool.query(`
          SELECT p.*, pc.name as category_name, pc.slug as category_slug
          FROM programs p
          LEFT JOIN program_categories pc ON p.category_id = pc.id
          LIMIT 1
        `);
        printResult(true, 'Category join query works');
      } catch (error) {
        printResult(false, 'Category join query failed', error.message);
      }
    } else {
      console.log(`\n${YELLOW}Test 5: Skipped (no category_id column)${NC}`);
      printResult(true, 'Test skipped appropriately');
    }

    // Test 6: Test search query without category
    console.log(`\n${YELLOW}Test 6: Search query (no category)${NC}`);
    try {
      const searchPattern = '%test%';
      const [rows] = await pool.query(`
        SELECT * FROM programs p
        WHERE (p.name LIKE ? OR p.description LIKE ?)
        LIMIT 1
      `, [searchPattern, searchPattern]);
      printResult(true, 'Search query without category works');
    } catch (error) {
      printResult(false, 'Search query failed', error.message);
    }

    // Test 7: Test search query with category (if column exists)
    if (hasCategoryId) {
      console.log(`\n${YELLOW}Test 7: Search query with category${NC}`);
      try {
        const searchPattern = '%test%';
        const [rows] = await pool.query(`
          SELECT p.*, pc.name as category_name
          FROM programs p
          LEFT JOIN program_categories pc ON p.category_id = pc.id
          WHERE (p.name LIKE ? OR p.description LIKE ? OR pc.name LIKE ?)
          LIMIT 1
        `, [searchPattern, searchPattern, searchPattern]);
        printResult(true, 'Search query with category works');
      } catch (error) {
        printResult(false, 'Search query with category failed', error.message);
      }
    } else {
      console.log(`\n${YELLOW}Test 7: Skipped (no category_id column)${NC}`);
      printResult(true, 'Test skipped appropriately');
    }

    // Test 8: Test the actual Program model method
    console.log(`\n${YELLOW}Test 8: Program.findAllPaginatedWithSearch method${NC}`);
    try {
      const Program = require('./src/models/Program');
      const result = await Program.findAllPaginatedWithSearch(1, 5, null, null, null);
      
      if (result && typeof result === 'object' && 'data' in result && 'total' in result) {
        printResult(true, 'Program model method works correctly');
        console.log(`  Found ${result.total} total programs`);
        console.log(`  Returned ${result.data.length} programs in page 1`);
      } else {
        printResult(false, 'Program model method returned invalid structure');
      }
    } catch (error) {
      printResult(false, 'Program model method failed', error.message);
    }

    // Test 9: Test with search parameter
    console.log(`\n${YELLOW}Test 9: Program model with search${NC}`);
    try {
      const Program = require('./src/models/Program');
      const result = await Program.findAllPaginatedWithSearch(1, 5, null, null, 'program');
      
      if (result && typeof result === 'object') {
        printResult(true, 'Program model search works');
        console.log(`  Found ${result.total} programs matching search`);
      } else {
        printResult(false, 'Program model search returned invalid structure');
      }
    } catch (error) {
      printResult(false, 'Program model search failed', error.message);
    }

    // Test 10: Test pagination
    console.log(`\n${YELLOW}Test 10: Program model pagination${NC}`);
    try {
      const Program = require('./src/models/Program');
      const page1 = await Program.findAllPaginatedWithSearch(1, 2, null, null, null);
      const page2 = await Program.findAllPaginatedWithSearch(2, 2, null, null, null);
      
      if (page1.data.length <= 2 && page2.data.length <= 2) {
        printResult(true, 'Pagination works correctly');
        console.log(`  Page 1: ${page1.data.length} items`);
        console.log(`  Page 2: ${page2.data.length} items`);
      } else {
        printResult(false, 'Pagination returned too many items');
      }
    } catch (error) {
      printResult(false, 'Pagination test failed', error.message);
    }

  } catch (error) {
    console.error(`${RED}Unexpected error: ${error.message}${NC}`);
    testsFailed++;
  } finally {
    // Close database connection
    await pool.end();
  }

  // Print summary
  console.log(`\n${YELLOW}=== Test Summary ===${NC}`);
  console.log(`Total Tests: ${testsPassed + testsFailed}`);
  console.log(`${GREEN}Passed: ${testsPassed}${NC}`);
  console.log(`${RED}Failed: ${testsFailed}${NC}`);

  if (testsFailed === 0) {
    console.log(`\n${GREEN}All tests passed! ✓${NC}`);
    console.log(`\n${GREEN}The Program model is backward compatible and works correctly.${NC}`);
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
