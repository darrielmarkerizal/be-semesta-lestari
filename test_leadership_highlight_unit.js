require('dotenv').config();
const { pool } = require('./src/config/database');
const Leadership = require('./src/models/Leadership');

// Test utilities
let testResults = {
  passed: 0,
  failed: 0,
  tests: []
};

function assert(condition, testName, expected, actual) {
  if (condition) {
    testResults.passed++;
    testResults.tests.push({ name: testName, status: 'PASSED', expected, actual });
    console.log(`✅ PASSED: ${testName}`);
  } else {
    testResults.failed++;
    testResults.tests.push({ name: testName, status: 'FAILED', expected, actual });
    console.log(`❌ FAILED: ${testName}`);
    console.log(`   Expected: ${JSON.stringify(expected)}`);
    console.log(`   Actual: ${JSON.stringify(actual)}`);
  }
}

async function cleanup() {
  // Delete test leadership members
  await pool.query("DELETE FROM leadership WHERE name LIKE 'Test Leader%'");
  // Reset all highlights
  await pool.query("UPDATE leadership SET is_highlighted = FALSE");
}

async function getHighlightedCount() {
  const [rows] = await pool.query('SELECT COUNT(*) as count FROM leadership WHERE is_highlighted = TRUE');
  return rows[0].count;
}

async function getHighlightedIds() {
  const [rows] = await pool.query('SELECT id FROM leadership WHERE is_highlighted = TRUE ORDER BY id');
  return rows.map(r => r.id);
}

async function runTests() {
  console.log('========================================');
  console.log('Leadership Highlight Feature - Unit Tests');
  console.log('========================================\n');

  try {
    // Setup: Clean database
    console.log('Setting up test environment...');
    await cleanup();
    console.log('✅ Test environment ready\n');

    // TEST 1: Create leadership without highlight
    console.log('TEST 1: Create leadership without highlight');
    const member1 = await Leadership.create({
      name: 'Test Leader 1',
      position: 'CEO',
      bio: 'Test bio 1',
      is_highlighted: false,
      is_active: true
    });
    
    let highlightedCount = await getHighlightedCount();
    assert(
      highlightedCount === 0,
      'Create without highlight should not create any highlighted member',
      0,
      highlightedCount
    );
    console.log('');

    // TEST 2: Create leadership with highlight
    console.log('TEST 2: Create leadership with highlight');
    const member2 = await Leadership.create({
      name: 'Test Leader 2',
      position: 'CTO',
      bio: 'Test bio 2',
      is_highlighted: true,
      is_active: true
    });
    
    highlightedCount = await getHighlightedCount();
    assert(
      highlightedCount === 1,
      'Create with highlight should create exactly 1 highlighted member',
      1,
      highlightedCount
    );
    
    let highlightedIds = await getHighlightedIds();
    assert(
      highlightedIds[0] === member2.id,
      'Newly created member should be highlighted',
      member2.id,
      highlightedIds[0]
    );
    console.log('');

    // TEST 3: Create another leadership with highlight (should unhighlight previous)
    console.log('TEST 3: Create another leadership with highlight');
    const member3 = await Leadership.create({
      name: 'Test Leader 3',
      position: 'CFO',
      bio: 'Test bio 3',
      is_highlighted: true,
      is_active: true
    });
    
    highlightedCount = await getHighlightedCount();
    assert(
      highlightedCount === 1,
      'Creating new highlighted member should maintain only 1 highlight',
      1,
      highlightedCount
    );
    
    highlightedIds = await getHighlightedIds();
    assert(
      highlightedIds[0] === member3.id,
      'Newest member should be highlighted',
      member3.id,
      highlightedIds[0]
    );
    
    const member2Updated = await Leadership.findById(member2.id);
    assert(
      member2Updated.is_highlighted === 0,
      'Previous highlighted member should be unhighlighted',
      0,
      member2Updated.is_highlighted
    );
    console.log('');

    // TEST 4: Update non-highlighted member to highlighted
    console.log('TEST 4: Update non-highlighted member to highlighted');
    await Leadership.update(member1.id, { is_highlighted: true });
    
    highlightedCount = await getHighlightedCount();
    assert(
      highlightedCount === 1,
      'Update to highlight should maintain only 1 highlight',
      1,
      highlightedCount
    );
    
    highlightedIds = await getHighlightedIds();
    assert(
      highlightedIds[0] === member1.id,
      'Updated member should be highlighted',
      member1.id,
      highlightedIds[0]
    );
    
    const member3Updated = await Leadership.findById(member3.id);
    assert(
      member3Updated.is_highlighted === 0,
      'Previous highlighted member should be unhighlighted after update',
      0,
      member3Updated.is_highlighted
    );
    console.log('');

    // TEST 5: Update highlighted member to unhighlighted
    console.log('TEST 5: Update highlighted member to unhighlighted');
    await Leadership.update(member1.id, { is_highlighted: false });
    
    highlightedCount = await getHighlightedCount();
    assert(
      highlightedCount === 0,
      'Update to unhighlight should result in 0 highlights',
      0,
      highlightedCount
    );
    console.log('');

    // TEST 6: Update member with highlight using value 1 (integer)
    console.log('TEST 6: Update member with highlight using integer value 1');
    await Leadership.update(member2.id, { is_highlighted: 1 });
    
    highlightedCount = await getHighlightedCount();
    assert(
      highlightedCount === 1,
      'Update with is_highlighted: 1 should work',
      1,
      highlightedCount
    );
    
    highlightedIds = await getHighlightedIds();
    assert(
      highlightedIds[0] === member2.id,
      'Member updated with integer 1 should be highlighted',
      member2.id,
      highlightedIds[0]
    );
    console.log('');

    // TEST 7: Delete non-highlighted member (should not affect highlight)
    console.log('TEST 7: Delete non-highlighted member');
    const currentHighlightedId = member2.id;
    await Leadership.delete(member3.id);
    
    highlightedCount = await getHighlightedCount();
    assert(
      highlightedCount === 1,
      'Deleting non-highlighted member should not affect highlight count',
      1,
      highlightedCount
    );
    
    highlightedIds = await getHighlightedIds();
    assert(
      highlightedIds[0] === currentHighlightedId,
      'Highlight should remain on same member after deleting non-highlighted',
      currentHighlightedId,
      highlightedIds[0]
    );
    console.log('');

    // TEST 8: Delete highlighted member (should assign to random)
    console.log('TEST 8: Delete highlighted member');
    await Leadership.delete(member2.id);
    
    highlightedCount = await getHighlightedCount();
    assert(
      highlightedCount === 1,
      'Deleting highlighted member should assign highlight to another member',
      1,
      highlightedCount
    );
    
    highlightedIds = await getHighlightedIds();
    const remainingMember = await Leadership.findById(member1.id);
    assert(
      remainingMember !== null && highlightedIds.length === 1,
      'A random active member should receive highlight',
      'one highlighted member',
      `${highlightedIds.length} highlighted member(s)`
    );
    console.log('');

    // TEST 9: Create multiple members and verify only one can be highlighted
    console.log('TEST 9: Create multiple members and verify highlight exclusivity');
    const member4 = await Leadership.create({
      name: 'Test Leader 4',
      position: 'COO',
      bio: 'Test bio 4',
      is_highlighted: false,
      is_active: true
    });
    
    const member5 = await Leadership.create({
      name: 'Test Leader 5',
      position: 'CMO',
      bio: 'Test bio 5',
      is_highlighted: false,
      is_active: true
    });
    
    // Highlight member 4
    await Leadership.update(member4.id, { is_highlighted: true });
    
    // Highlight member 5
    await Leadership.update(member5.id, { is_highlighted: true });
    
    highlightedCount = await getHighlightedCount();
    assert(
      highlightedCount === 1,
      'Multiple updates should maintain only 1 highlight',
      1,
      highlightedCount
    );
    
    highlightedIds = await getHighlightedIds();
    assert(
      highlightedIds[0] === member5.id,
      'Last updated member should be highlighted',
      member5.id,
      highlightedIds[0]
    );
    console.log('');

    // TEST 10: Delete all members except one and verify highlight assignment
    console.log('TEST 10: Delete all but one member');
    await Leadership.delete(member4.id);
    await Leadership.delete(member5.id);
    
    highlightedCount = await getHighlightedCount();
    assert(
      highlightedCount === 1,
      'Should still have 1 highlighted member',
      1,
      highlightedCount
    );
    
    highlightedIds = await getHighlightedIds();
    const testMembers = await pool.query('SELECT id FROM leadership WHERE name LIKE "Test Leader%"');
    assert(
      highlightedIds.length === 1 && testMembers[0].length > 0,
      'One of remaining test members should be highlighted',
      'one highlighted member',
      `${highlightedIds.length} highlighted member(s)`
    );
    console.log('');

    // TEST 11: Update other fields without touching is_highlighted
    console.log('TEST 11: Update other fields without affecting highlight');
    const beforeUpdate = await Leadership.findById(member1.id);
    await Leadership.update(member1.id, { 
      position: 'Updated Position',
      bio: 'Updated bio'
    });
    
    const afterUpdate = await Leadership.findById(member1.id);
    assert(
      afterUpdate.is_highlighted === beforeUpdate.is_highlighted,
      'Updating other fields should not affect highlight status',
      beforeUpdate.is_highlighted,
      afterUpdate.is_highlighted
    );
    
    assert(
      afterUpdate.position === 'Updated Position',
      'Other fields should be updated correctly',
      'Updated Position',
      afterUpdate.position
    );
    console.log('');

    // TEST 12: Create inactive member with highlight (should still work)
    console.log('TEST 12: Create inactive member with highlight');
    const member6 = await Leadership.create({
      name: 'Test Leader 6',
      position: 'Advisor',
      bio: 'Test bio 6',
      is_highlighted: true,
      is_active: false
    });
    
    highlightedCount = await getHighlightedCount();
    assert(
      highlightedCount === 1,
      'Inactive member can be highlighted',
      1,
      highlightedCount
    );
    
    highlightedIds = await getHighlightedIds();
    assert(
      highlightedIds[0] === member6.id,
      'Inactive member should be highlighted',
      member6.id,
      highlightedIds[0]
    );
    console.log('');

    // TEST 13: Delete inactive highlighted member (should assign to active member)
    console.log('TEST 13: Delete inactive highlighted member');
    await Leadership.delete(member6.id);
    
    highlightedCount = await getHighlightedCount();
    assert(
      highlightedCount === 1,
      'Should assign highlight to active member',
      1,
      highlightedCount
    );
    
    highlightedIds = await getHighlightedIds();
    const activeMembers = await pool.query('SELECT id FROM leadership WHERE name LIKE "Test Leader%" AND is_active = TRUE');
    assert(
      highlightedIds.length === 1 && activeMembers[0].length > 0,
      'A random active member should receive highlight',
      'one highlighted active member',
      `${highlightedIds.length} highlighted member(s)`
    );
    console.log('');

    // Cleanup
    console.log('Cleaning up test data...');
    await cleanup();
    console.log('✅ Cleanup complete\n');

  } catch (error) {
    console.error('❌ Test error:', error);
    testResults.failed++;
  } finally {
    // Print summary
    console.log('========================================');
    console.log('Test Summary');
    console.log('========================================');
    console.log(`Total Tests: ${testResults.passed + testResults.failed}`);
    console.log(`✅ Passed: ${testResults.passed}`);
    console.log(`❌ Failed: ${testResults.failed}`);
    console.log('========================================\n');

    if (testResults.failed === 0) {
      console.log('🎉 All tests passed!\n');
    } else {
      console.log('⚠️  Some tests failed. Please review the output above.\n');
    }

    // Close database connection
    await pool.end();
    process.exit(testResults.failed > 0 ? 1 : 0);
  }
}

// Run tests
runTests();
