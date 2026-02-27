const pool = require('../config/db');
const logger = require('../utils/logger');

async function cleanupDuplicates() {
  try {
    // Get all records
    const [records] = await pool.query(`
      SELECT * FROM home_faq_section ORDER BY id ASC
    `);
    
    logger.info(`Found ${records.length} records in home_faq_section`);
    
    if (records.length > 1) {
      // Keep the first record, delete the rest
      const keepId = records[0].id;
      logger.info(`Keeping record with id: ${keepId}`);
      
      await pool.query(`
        DELETE FROM home_faq_section WHERE id != ?
      `, [keepId]);
      
      logger.info(`✅ Deleted ${records.length - 1} duplicate records`);
    } else {
      logger.info('✅ No duplicates found');
    }
    
    process.exit(0);
  } catch (error) {
    logger.error('Failed to cleanup duplicates:', error);
    process.exit(1);
  }
}

cleanupDuplicates();
