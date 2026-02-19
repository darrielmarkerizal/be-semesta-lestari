require('dotenv').config();
const mysql = require('mysql2/promise');
const config = require('../config/environment');
const logger = require('../utils/logger');

const addImageUrlColumns = async () => {
  let connection;
  
  try {
    connection = await mysql.createConnection({
      host: config.database.host,
      user: config.database.user,
      password: config.database.password,
      database: config.database.name,
      port: config.database.port
    });
    
    logger.info('Connected to database');
    
    // Add image_url to visions table if not exists
    try {
      await connection.query(`
        ALTER TABLE visions 
        ADD COLUMN image_url VARCHAR(500) AFTER icon_url
      `);
      logger.info('✅ Added image_url column to visions table');
    } catch (error) {
      if (error.code === 'ER_DUP_FIELDNAME') {
        logger.info('⚠️  image_url column already exists in visions table');
      } else {
        throw error;
      }
    }
    
    // Add image_url to impact_sections table if not exists
    try {
      await connection.query(`
        ALTER TABLE impact_sections 
        ADD COLUMN image_url VARCHAR(500) AFTER icon_url
      `);
      logger.info('✅ Added image_url column to impact_sections table');
    } catch (error) {
      if (error.code === 'ER_DUP_FIELDNAME') {
        logger.info('⚠️  image_url column already exists in impact_sections table');
      } else {
        throw error;
      }
    }
    
    logger.info('✅ Migration completed successfully');
    
  } catch (error) {
    logger.error('Error during migration:', error);
    throw error;
  } finally {
    if (connection) {
      await connection.end();
    }
  }
};

// Run the script
addImageUrlColumns()
  .then(() => {
    logger.info('Migration script completed');
    process.exit(0);
  })
  .catch((error) => {
    logger.error('Migration script failed:', error);
    process.exit(1);
  });
