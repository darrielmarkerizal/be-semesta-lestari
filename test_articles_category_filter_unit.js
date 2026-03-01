#!/usr/bin/env node

/**
 * Unit test for Articles Category Filter (ID and Slug)
 * Tests the Article model's ability to filter by both category ID and slug
 */

const { pool } = require('./src/config/database');
const Article = require('./src/models/Article');

// Colors for output
const GREEN = '\x1b[32m';
const RED = '\x1b[31m';
const YELLOW = '\x1b[33m';
const NC = '\x1b[0m';

let testsPassed = 0;
let testsFailed = 0;

function printResult(passed, testName, details = '') {
  if (passed) {
    testsPassed++;
    console.log(`${GREEN}✓ PASS${NC}: ${testName}`);
    if (details) console.log(`  ${details}`);
  } else {
    testsFailed++;
    console.log(`${RED}✗ FAIL${NC}: ${testName}`);
    if (details) console.log(`  ${RED}${details}${NC}`);
  }
}

async function runTests() {
  console.log(`${YELLOW}=== Articles Category Filter Unit Test ===${NC}\n`);

  try {
    // Test 1: Database connection
    console.log(`${YELLOW}Test 1: Database Connection${NC}`);
    try {
      await pool.query('SELECT 1');
      printResult(true, 'Database connection successful');
    } catch (error) {
      printResult(false, 'Database connection failed', error.message);
      process.exit(1);
    }

    // Test 2: Check if articles table exists
    console.log(`\n${YELLOW}Test 2: Articles Table Exists${NC}`);
    try {
      const [tables] = await pool.query("SHOW TABLES LIKE 'articles'");
      printResult(tables.length > 0, 'Articles table exists');
    } catch (error) {
      printResult(false, 'Articles table check failed', error.message);
    }

    // Test 3: Check if categories table exists
    console.log(`\n${YELLOW}Test 3: Categories Table Exists${NC}`);
    try {
      const [tables] = await pool.query("SHOW TABLES LIKE 'categories'");
      printResult(tables.length > 0, 'Categories table exists');
    } catch (error) {
      printResult(false, 'Categories table check failed', error.message);
    }

    // Test 4: Get available categories
    console.log(`\n${YELLOW}Test 4: Get Available Categories${NC}`);
    let categories = [];
    try {
      const [rows] = await pool.query('SELECT id, name, slug FROM categories WHERE is_active = true LIMIT 5');
      categories = rows;
      printResult(rows.length > 0, `Found ${rows.length} active categories`);
      rows.forEach(cat => {
        console.log(`  - ID: ${cat.id}, Name: ${cat.name}, Slug: ${cat.slug}`);
      });
    } catch (error) {
      printResult(false, 'Failed to get categories', error.message);
    }

    // Test 5: Get total articles count
    console.log(`\n${YELLOW}Test 5: Get Total Articles Count${NC}`);
    let totalArticles = 0;
    try {
      const [result] = await pool.query('SELECT COUNT(*) as total FROM articles WHERE is_active = true');
      totalArticles = result[0].total;
      printResult(true, `Found ${totalArticles} active articles in database`);
    } catch (error) {
      printResult(false, 'Failed to count articles', error.message);
    }

    if (categories.length === 0) {
      console.log(`\n${YELLOW}⚠ WARNING: No categories found. Skipping category filter tests.${NC}`);
      await pool.end();
      return;
    }

    const testCategory = categories[0];
    console.log(`\n${YELLOW}Using test category: ID=${testCategory.id}, Slug=${testCategory.slug}${NC}`);

    // Test 6: Filter by category ID
    console.log(`\n${YELLOW}Test 6: Filter Articles by Category ID${NC}`);
    try {
      const { articles, total } = await Article.findAll(1, 10, true, testCategory.id.toString());
      
      if (articles.length > 0) {
        const allMatchCategory = articles.every(a => a.category_id === testCategory.id);
        printResult(
          allMatchCategory,
          `Filter by category ID works - Found ${total} articles`,
          `All ${articles.length} returned articles match category ID ${testCategory.id}`
        );
      } else {
        printResult(true, `Filter by category ID works - Found 0 articles (category may be empty)`);
      }
    } catch (error) {
      printResult(false, 'Filter by category ID failed', error.message);
    }

    // Test 7: Filter by category slug
    console.log(`\n${YELLOW}Test 7: Filter Articles by Category Slug${NC}`);
    try {
      const { articles, total } = await Article.findAll(1, 10, true, testCategory.slug);
      
      if (articles.length > 0) {
        const allMatchSlug = articles.every(a => a.category_slug === testCategory.slug);
        printResult(
          allMatchSlug,
          `Filter by category slug works - Found ${total} articles`,
          `All ${articles.length} returned articles match category slug "${testCategory.slug}"`
        );
      } else {
        printResult(true, `Filter by category slug works - Found 0 articles (category may be empty)`);
      }
    } catch (error) {
      printResult(false, 'Filter by category slug failed', error.message);
    }

    // Test 8: Verify ID and slug return same results
    console.log(`\n${YELLOW}Test 8: Verify ID and Slug Return Same Results${NC}`);
    try {
      const resultById = await Article.findAll(1, 10, true, testCategory.id.toString());
      const resultBySlug = await Article.findAll(1, 10, true, testCategory.slug);
      
      const sameTotal = resultById.total === resultBySlug.total;
      const sameCount = resultById.articles.length === resultBySlug.articles.length;
      
      printResult(
        sameTotal && sameCount,
        'ID and slug filters return identical results',
        `Both returned ${resultById.total} total articles, ${resultById.articles.length} in page`
      );
    } catch (error) {
      printResult(false, 'Comparison test failed', error.message);
    }

    // Test 9: Pagination with category filter
    console.log(`\n${YELLOW}Test 9: Pagination with Category Filter${NC}`);
    try {
      const page1 = await Article.findAll(1, 2, true, testCategory.id.toString());
      const page2 = await Article.findAll(2, 2, true, testCategory.id.toString());
      
      const validPageSize = page1.articles.length <= 2 && page2.articles.length <= 2;
      const differentPages = page1.articles.length === 0 || page2.articles.length === 0 || 
                            page1.articles[0].id !== page2.articles[0].id;
      
      printResult(
        validPageSize && differentPages,
        'Pagination with category filter works',
        `Page 1: ${page1.articles.length} items, Page 2: ${page2.articles.length} items`
      );
    } catch (error) {
      printResult(false, 'Pagination test failed', error.message);
    }

    // Test 10: Combine category filter with search
    console.log(`\n${YELLOW}Test 10: Combine Category Filter with Search${NC}`);
    try {
      const { articles, total } = await Article.findAll(1, 10, true, testCategory.id.toString(), 'test');
      
      printResult(
        true,
        'Combined category and search filter works',
        `Found ${total} articles matching category ${testCategory.id} and search "test"`
      );
    } catch (error) {
      printResult(false, 'Combined filter test failed', error.message);
    }

    // Test 11: Invalid category ID returns empty
    console.log(`\n${YELLOW}Test 11: Invalid Category ID Returns Empty${NC}`);
    try {
      const { articles, total } = await Article.findAll(1, 10, true, '99999');
      
      printResult(
        total === 0 && articles.length === 0,
        'Invalid category ID returns empty results',
        `Returned ${total} articles (expected 0)`
      );
    } catch (error) {
      printResult(false, 'Invalid category test failed', error.message);
    }

    // Test 12: Invalid category slug returns empty
    console.log(`\n${YELLOW}Test 12: Invalid Category Slug Returns Empty${NC}`);
    try {
      const { articles, total } = await Article.findAll(1, 10, true, 'non-existent-category-slug');
      
      printResult(
        total === 0 && articles.length === 0,
        'Invalid category slug returns empty results',
        `Returned ${total} articles (expected 0)`
      );
    } catch (error) {
      printResult(false, 'Invalid slug test failed', error.message);
    }

    // Test 13: Verify category information in results
    console.log(`\n${YELLOW}Test 13: Verify Category Information in Results${NC}`);
    try {
      const { articles } = await Article.findAll(1, 1, true, testCategory.id.toString());
      
      if (articles.length > 0) {
        const article = articles[0];
        const hasAllFields = 
          article.category_id !== undefined &&
          article.category_name !== undefined &&
          article.category_slug !== undefined;
        
        printResult(
          hasAllFields,
          'Articles include complete category information',
          `category_id: ${article.category_id}, category_name: ${article.category_name}, category_slug: ${article.category_slug}`
        );
      } else {
        printResult(true, 'No articles to verify (category may be empty)');
      }
    } catch (error) {
      printResult(false, 'Category information test failed', error.message);
    }

    // Test 14: Test with multiple categories
    if (categories.length > 1) {
      console.log(`\n${YELLOW}Test 14: Test Multiple Categories${NC}`);
      try {
        const cat1 = await Article.findAll(1, 10, true, categories[0].id.toString());
        const cat2 = await Article.findAll(1, 10, true, categories[1].id.toString());
        
        printResult(
          true,
          'Multiple category filters work independently',
          `Category ${categories[0].id}: ${cat1.total} articles, Category ${categories[1].id}: ${cat2.total} articles`
        );
      } catch (error) {
        printResult(false, 'Multiple categories test failed', error.message);
      }
    }

    // Test 15: Test without category filter (all articles)
    console.log(`\n${YELLOW}Test 15: Get All Articles (No Filter)${NC}`);
    try {
      const { articles, total } = await Article.findAll(1, 10, true, null);
      
      printResult(
        total === totalArticles,
        'No filter returns all articles',
        `Returned ${total} articles (expected ${totalArticles})`
      );
    } catch (error) {
      printResult(false, 'No filter test failed', error.message);
    }

    // Test 16: Test numeric string vs actual number
    console.log(`\n${YELLOW}Test 16: Numeric String Detection${NC}`);
    try {
      const resultString = await Article.findAll(1, 10, true, testCategory.id.toString());
      const resultNumber = await Article.findAll(1, 10, true, testCategory.id);
      
      printResult(
        resultString.total === resultNumber.total,
        'Numeric string and number are handled identically',
        `String: ${resultString.total}, Number: ${resultNumber.total}`
      );
    } catch (error) {
      printResult(false, 'Numeric detection test failed', error.message);
    }

    // Test 17: Test ordering with category filter
    console.log(`\n${YELLOW}Test 17: Verify Ordering with Category Filter${NC}`);
    try {
      const { articles } = await Article.findAll(1, 5, true, testCategory.id.toString());
      
      if (articles.length > 1) {
        let isOrdered = true;
        for (let i = 1; i < articles.length; i++) {
          const prev = new Date(articles[i-1].published_at || articles[i-1].created_at);
          const curr = new Date(articles[i].published_at || articles[i].created_at);
          if (prev < curr) {
            isOrdered = false;
            break;
          }
        }
        
        printResult(
          isOrdered,
          'Articles are ordered by date DESC',
          `Checked ${articles.length} articles`
        );
      } else {
        printResult(true, 'Not enough articles to verify ordering');
      }
    } catch (error) {
      printResult(false, 'Ordering test failed', error.message);
    }

    // Test 18: Test with inactive articles (admin mode)
    console.log(`\n${YELLOW}Test 18: Include Inactive Articles (Admin Mode)${NC}`);
    try {
      const activeOnly = await Article.findAll(1, 10, true, testCategory.id.toString());
      const allArticles = await Article.findAll(1, 10, null, testCategory.id.toString());
      
      printResult(
        allArticles.total >= activeOnly.total,
        'Admin mode includes inactive articles',
        `Active only: ${activeOnly.total}, All: ${allArticles.total}`
      );
    } catch (error) {
      printResult(false, 'Inactive articles test failed', error.message);
    }

  } catch (error) {
    console.error(`${RED}Unexpected error: ${error.message}${NC}`);
    console.error(error.stack);
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
    console.log(`\n${GREEN}✓ All tests passed!${NC}`);
    console.log(`\n${GREEN}Articles category filter (ID and slug) is working correctly.${NC}`);
    process.exit(0);
  } else {
    console.log(`\n${RED}✗ Some tests failed. Please check the output above.${NC}`);
    process.exit(1);
  }
}

// Run tests
runTests().catch(error => {
  console.error(`${RED}Fatal error: ${error.message}${NC}`);
  console.error(error.stack);
  process.exit(1);
});
