require('dotenv').config();
const { pool } = require('../config/database');
const logger = require('../utils/logger');

const addSubtitleColumn = async () => {
  try {
    logger.info('Adding subtitle column to history table...');
    
    // Check if column already exists
    const [columns] = await pool.query(`
      SELECT COLUMN_NAME 
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = ? 
      AND TABLE_NAME = 'history' 
      AND COLUMN_NAME = 'subtitle'
    `, [process.env.DB_NAME || 'semesta_lestari']);
    
    if (columns.length > 0) {
      logger.info('subtitle column already exists');
      return;
    }
    
    // Add subtitle column after title
    await pool.query(`
      ALTER TABLE history 
      ADD COLUMN subtitle VARCHAR(255) AFTER title
    `);
    
    logger.info('✅ subtitle column added successfully');
    
  } catch (error) {
    logger.error('Error adding subtitle column:', error);
    throw error;
  } finally {
    await pool.end();
  }
};

addSubtitleColumn()
  .then(() => {
    logger.info('Migration completed successfully');
    process.exit(0);
  })
  .catch((error) => {
    logger.error('Migration failed:', error);
    process.exit(1);
  });
