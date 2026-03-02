require('dotenv').config();
const { pool } = require('../config/database');

async function fixLeadershipHighlight() {
  try {
    console.log('Checking highlighted leadership members...');
    
    // Get all highlighted leadership members
    const [highlighted] = await pool.query(
      'SELECT id, name, is_highlighted FROM leadership WHERE is_highlighted = TRUE ORDER BY id ASC'
    );
    
    console.log(`Found ${highlighted.length} highlighted leadership members:`);
    highlighted.forEach(p => {
      console.log(`  - ID ${p.id}: ${p.name}`);
    });
    
    if (highlighted.length <= 1) {
      console.log('\n✅ No fix needed. Only 0 or 1 leadership member is highlighted.');
      process.exit(0);
    }
    
    // Keep the first one, unhighlight the rest
    const keepId = highlighted[0].id;
    const unhighlightIds = highlighted.slice(1).map(p => p.id);
    
    console.log(`\nKeeping Leadership ID ${keepId} as highlighted`);
    console.log(`Unhighlighting Leadership IDs: ${unhighlightIds.join(', ')}`);
    
    // Unhighlight all except the first one
    await pool.query(
      'UPDATE leadership SET is_highlighted = FALSE WHERE id != ?',
      [keepId]
    );
    
    console.log('\n✅ Fixed! Now only 1 leadership member is highlighted.');
    
    // Verify
    const [verify] = await pool.query(
      'SELECT id, name, is_highlighted FROM leadership WHERE is_highlighted = TRUE'
    );
    
    console.log('\nCurrent highlighted leadership member:');
    verify.forEach(p => {
      console.log(`  - ID ${p.id}: ${p.name}`);
    });
    
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

fixLeadershipHighlight();
