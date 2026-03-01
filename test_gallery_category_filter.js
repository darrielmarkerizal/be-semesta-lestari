#!/usr/bin/env node

/**
 * Unit test for Gallery Category Filter
 * Tests /api/gallery endpoint with category filtering and pagination
 */

const http = require('http');

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

function makeRequest(path) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: path,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(data) });
        } catch (e) {
          resolve({ status: res.statusCode, data: data });
        }
      });
    });

    req.on('error', reject);
    req.setTimeout(5000, () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });
    req.end();
  });
}

async function runTests() {
  console.log(`${YELLOW}=== Gallery Category Filter Unit Test ===${NC}\n`);

  try {
    // Test 1: Check if server is running
    console.log(`${YELLOW}Test 1: Server connectivity${NC}`);
    try {
      const response = await makeRequest('/api/gallery?page=1&limit=1');
      if (response.status === 200) {
        printResult(true, 'Server is running and responding');
      } else {
        printResult(false, 'Server returned non-200 status', `Status: ${response.status}`);
      }
    } catch (error) {
      printResult(false, 'Cannot connect to server', 'Make sure server is running on port 3000');
      console.log(`\n${RED}Please start the server with: npm start${NC}\n`);
      process.exit(1);
    }

    // Test 2: Get all gallery items (no filter)
    console.log(`\n${YELLOW}Test 2: Get all gallery items${NC}`);
    const allItems = await makeRequest('/api/gallery?page=1&limit=100');
    if (allItems.data.success && allItems.data.data.items) {
      const totalItems = allItems.data.data.items.length;
      printResult(true, 'Retrieved all gallery items', `Total: ${totalItems} items`);
    } else {
      printResult(false, 'Failed to retrieve gallery items');
    }

    // Test 3: Get gallery categories
    console.log(`\n${YELLOW}Test 3: Get gallery categories${NC}`);
    const categories = await makeRequest('/api/gallery-categories');
    let categoryList = [];
    if (categories.data.success && categories.data.data) {
      categoryList = categories.data.data;
      printResult(true, 'Retrieved gallery categories', `Found ${categoryList.length} categories`);
      categoryList.forEach(cat => {
        console.log(`  - ${cat.name} (id: ${cat.id}, slug: ${cat.slug})`);
      });
    } else {
      printResult(false, 'Failed to retrieve categories');
    }

    // Test 4: Filter by category ID (Events = 1)
    console.log(`\n${YELLOW}Test 4: Filter by category ID (Events)${NC}`);
    const eventsById = await makeRequest('/api/gallery?page=1&limit=12&category=1');
    if (eventsById.data.success && eventsById.data.data.items) {
      const items = eventsById.data.data.items;
      const allAreEvents = items.every(item => item.category_id === 1);
      if (allAreEvents && items.length > 0) {
        printResult(true, 'Category filter by ID works', `Found ${items.length} items in Events category`);
      } else if (items.length === 0) {
        printResult(false, 'No items found in Events category', 'Database may be empty');
      } else {
        printResult(false, 'Category filter returned wrong items', 'Some items are not in Events category');
      }
    } else {
      printResult(false, 'Failed to filter by category ID');
    }

    // Test 5: Filter by category slug (events)
    console.log(`\n${YELLOW}Test 5: Filter by category slug (events)${NC}`);
    const eventsBySlug = await makeRequest('/api/gallery?page=1&limit=12&category=events');
    if (eventsBySlug.data.success && eventsBySlug.data.data.items) {
      const items = eventsBySlug.data.data.items;
      const allAreEvents = items.every(item => item.category_slug === 'events');
      if (allAreEvents && items.length > 0) {
        printResult(true, 'Category filter by slug works', `Found ${items.length} items`);
      } else if (items.length === 0) {
        printResult(false, 'No items found with slug filter');
      } else {
        printResult(false, 'Category slug filter returned wrong items');
      }
    } else {
      printResult(false, 'Failed to filter by category slug');
    }

    // Test 6: Test pagination with category filter
    console.log(`\n${YELLOW}Test 6: Pagination with category filter${NC}`);
    const page1 = await makeRequest('/api/gallery?page=1&limit=2&category=1');
    const page2 = await makeRequest('/api/gallery?page=2&limit=2&category=1');
    
    if (page1.data.success && page2.data.success) {
      const items1 = page1.data.data.items;
      const items2 = page2.data.data.items;
      
      if (items1.length <= 2 && items2.length <= 2) {
        const noDuplicates = !items1.some(i1 => items2.some(i2 => i1.id === i2.id));
        if (noDuplicates) {
          printResult(true, 'Pagination with category filter works', `Page 1: ${items1.length}, Page 2: ${items2.length}`);
        } else {
          printResult(false, 'Pagination returned duplicate items');
        }
      } else {
        printResult(false, 'Pagination returned too many items per page');
      }
    } else {
      printResult(false, 'Failed to test pagination with category filter');
    }

    // Test 7: Test each category
    console.log(`\n${YELLOW}Test 7: Test filtering for each category${NC}`);
    for (const category of categoryList) {
      const response = await makeRequest(`/api/gallery?page=1&limit=12&category=${category.id}`);
      if (response.data.success && response.data.data.items) {
        const items = response.data.data.items;
        const allMatch = items.every(item => item.category_id === category.id);
        if (allMatch) {
          printResult(true, `${category.name} category filter works`, `${items.length} items`);
        } else {
          printResult(false, `${category.name} category filter returned wrong items`);
        }
      } else {
        printResult(false, `Failed to filter ${category.name} category`);
      }
    }

    // Test 8: Test invalid category
    console.log(`\n${YELLOW}Test 8: Test invalid category${NC}`);
    const invalidCat = await makeRequest('/api/gallery?page=1&limit=12&category=999');
    if (invalidCat.data.success && invalidCat.data.data.items) {
      const items = invalidCat.data.data.items;
      if (items.length === 0) {
        printResult(true, 'Invalid category returns empty results', 'As expected');
      } else {
        printResult(false, 'Invalid category should return empty results');
      }
    } else {
      printResult(false, 'Failed to handle invalid category');
    }

    // Test 9: Test response structure
    console.log(`\n${YELLOW}Test 9: Verify response structure${NC}`);
    const structureTest = await makeRequest('/api/gallery?page=1&limit=12&category=1');
    if (structureTest.data.success) {
      const hasSection = 'section' in structureTest.data.data;
      const hasItems = 'items' in structureTest.data.data;
      const hasPagination = 'pagination' in structureTest.data;
      
      if (hasSection && hasItems && hasPagination) {
        printResult(true, 'Response structure is correct', 'Has section, items, and pagination');
      } else {
        printResult(false, 'Response structure is incomplete', 
          `section: ${hasSection}, items: ${hasItems}, pagination: ${hasPagination}`);
      }
    } else {
      printResult(false, 'Failed to verify response structure');
    }

    // Test 10: Test category information in items
    console.log(`\n${YELLOW}Test 10: Verify category info in items${NC}`);
    const catInfoTest = await makeRequest('/api/gallery?page=1&limit=1&category=1');
    if (catInfoTest.data.success && catInfoTest.data.data.items.length > 0) {
      const item = catInfoTest.data.data.items[0];
      const hasCategoryId = 'category_id' in item;
      const hasCategoryName = 'category_name' in item;
      const hasCategorySlug = 'category_slug' in item;
      
      if (hasCategoryId && hasCategoryName && hasCategorySlug) {
        printResult(true, 'Items include category information', 
          `${item.category_name} (${item.category_slug})`);
      } else {
        printResult(false, 'Items missing category information');
      }
    } else {
      printResult(false, 'Failed to verify category info in items');
    }

  } catch (error) {
    console.error(`${RED}Unexpected error: ${error.message}${NC}`);
    testsFailed++;
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
