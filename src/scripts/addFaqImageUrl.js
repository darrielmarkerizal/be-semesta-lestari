const pool = require('../config/db');
const logger = require('../utils/logger');

async function addFaqImageUrl() {
  try {
    // Check if column exists
    const [columns] = await pool.query(`
      SHOW COLUMNS FROM home_faq_section LIKE 'image_url'
    `);
    
    if (columns.length === 0) {
      // Add image_url column to home_faq_section table
      await pool.query(`
        ALTER TABLE home_faq_section 
        ADD COLUMN image_url VARCHAR(500) AFTER subtitle
      `);
      logger.info('✅ Added image_url column to home_faq_section table');
    } else {
      logger.info('✅ image_url column already exists in home_faq_section table');
    }
    
    process.exit(0);
  } catch (error) {
    logger.error('Failed to add image_url column:', error);
    process.exit(1);
  }
}

addFaqImageUrl();
