require('dotenv').config();
const { pool } = require('../config/database');

async function fixProgramHighlight() {
  try {
    console.log('Checking highlighted programs...');
    
    // Get all highlighted programs
    const [highlighted] = await pool.query(
      'SELECT id, name, is_highlighted FROM programs WHERE is_highlighted = TRUE ORDER BY id ASC'
    );
    
    console.log(`Found ${highlighted.length} highlighted programs:`);
    highlighted.forEach(p => {
      console.log(`  - ID ${p.id}: ${p.name}`);
    });
    
    if (highlighted.length <= 1) {
      console.log('\n✅ No fix needed. Only 0 or 1 program is highlighted.');
      process.exit(0);
    }
    
    // Keep the first one, unhighlight the rest
    const keepId = highlighted[0].id;
    const unhighlightIds = highlighted.slice(1).map(p => p.id);
    
    console.log(`\nKeeping Program ID ${keepId} as highlighted`);
    console.log(`Unhighlighting Program IDs: ${unhighlightIds.join(', ')}`);
    
    // Unhighlight all except the first one
    await pool.query(
      'UPDATE programs SET is_highlighted = FALSE WHERE id != ?',
      [keepId]
    );
    
    console.log('\n✅ Fixed! Now only 1 program is highlighted.');
    
    // Verify
    const [verify] = await pool.query(
      'SELECT id, name, is_highlighted FROM programs WHERE is_highlighted = TRUE'
    );
    
    console.log('\nCurrent highlighted program:');
    verify.forEach(p => {
      console.log(`  - ID ${p.id}: ${p.name}`);
    });
    
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

fixProgramHighlight();
