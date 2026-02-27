require('dotenv').config();
const { pool } = require('../config/database');
const logger = require('../utils/logger');

const cleanupHistorySection = async () => {
  try {
    logger.info('Starting history_section cleanup...');
    
    // Get all history_section records
    const [sections] = await pool.query(
      'SELECT * FROM history_section ORDER BY id ASC'
    );
    
    logger.info(`Found ${sections.length} history_section records`);
    
    if (sections.length <= 1) {
      logger.info('Only one or no records found. No cleanup needed.');
      return;
    }
    
    // Keep the first record, delete the rest
    const keepId = sections[0].id;
    logger.info(`Keeping record with id: ${keepId}`);
    
    // Delete all other records
    const [result] = await pool.query(
      'DELETE FROM history_section WHERE id != ?',
      [keepId]
    );
    
    logger.info(`✅ Deleted ${result.affectedRows} duplicate records`);
    logger.info('✅ History section cleanup completed!');
    
  } catch (error) {
    logger.error('Error cleaning up history_section:', error);
    throw error;
  } finally {
    await pool.end();
  }
};

cleanupHistorySection()
  .then(() => process.exit(0))
  .catch((error) => {
    logger.error('Cleanup failed:', error);
    process.exit(1);
  });
