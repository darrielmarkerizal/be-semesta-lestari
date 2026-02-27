require('dotenv').config();
const { pool } = require('../config/database');
const logger = require('../utils/logger');

const cleanupDuplicates = async () => {
  try {
    logger.info('Starting cleanup of leadership_section duplicates...');
    
    // Get all records
    const [records] = await pool.query('SELECT * FROM leadership_section ORDER BY id ASC');
    
    if (records.length <= 1) {
      logger.info('No duplicates found. Only one or zero records exist.');
      return;
    }
    
    // Keep the first record, delete the rest
    const keepId = records[0].id;
    const deleteIds = records.slice(1).map(r => r.id);
    
    logger.info(`Found ${records.length} records. Keeping ID ${keepId}, deleting ${deleteIds.length} duplicates.`);
    
    if (deleteIds.length > 0) {
      await pool.query('DELETE FROM leadership_section WHERE id IN (?)', [deleteIds]);
      logger.info(`✅ Deleted ${deleteIds.length} duplicate records`);
    }
    
    logger.info('✅ Cleanup completed successfully');
    
  } catch (error) {
    logger.error('Error during cleanup:', error);
    throw error;
  } finally {
    await pool.end();
  }
};

cleanupDuplicates()
  .then(() => process.exit(0))
  .catch((error) => {
    logger.error('Cleanup failed:', error);
    process.exit(1);
  });
