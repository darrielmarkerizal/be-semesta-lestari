require('dotenv').config();
const { pool } = require('../config/database');
const logger = require('../utils/logger');

const addProgramCategoryId = async () => {
  try {
    logger.info('Adding category_id column to programs table...');
    
    // Check if column already exists
    const [columns] = await pool.query(`
      SELECT COLUMN_NAME 
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = ? 
      AND TABLE_NAME = 'programs' 
      AND COLUMN_NAME = 'category_id'
    `, [process.env.DB_NAME || 'semesta_lestari']);
    
    if (columns.length > 0) {
      logger.info('✅ category_id column already exists in programs table');
      return;
    }
    
    // Add category_id column
    await pool.query(`
      ALTER TABLE programs 
      ADD COLUMN category_id INT AFTER image_url,
      ADD FOREIGN KEY (category_id) REFERENCES program_categories(id) ON DELETE SET NULL
    `);
    
    logger.info('✅ category_id column added to programs table successfully');
    
  } catch (error) {
    logger.error('Error adding category_id column:', error);
    throw error;
  } finally {
    await pool.end();
  }
};

addProgramCategoryId()
  .then(() => {
    logger.info('Migration completed');
    process.exit(0);
  })
  .catch((error) => {
    logger.error('Migration failed:', error);
    process.exit(1);
  });
