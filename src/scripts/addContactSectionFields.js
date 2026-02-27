require('dotenv').config();
const db = require('../config/db');

async function addContactSectionFields() {
  try {
    console.log('Adding subtitle and image_url columns to home_contact_section table...');
    
    // Check if subtitle column exists
    const [subtitleColumns] = await db.query(`
      SELECT COLUMN_NAME 
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = DATABASE() 
      AND TABLE_NAME = 'home_contact_section' 
      AND COLUMN_NAME = 'subtitle'
    `);
    
    if (subtitleColumns.length === 0) {
      await db.query(`
        ALTER TABLE home_contact_section 
        ADD COLUMN subtitle VARCHAR(255) AFTER title
      `);
      console.log('✓ subtitle column added');
    } else {
      console.log('✓ subtitle column already exists');
    }
    
    // Check if image_url column exists
    const [imageColumns] = await db.query(`
      SELECT COLUMN_NAME 
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = DATABASE() 
      AND TABLE_NAME = 'home_contact_section' 
      AND COLUMN_NAME = 'image_url'
    `);
    
    if (imageColumns.length === 0) {
      await db.query(`
        ALTER TABLE home_contact_section 
        ADD COLUMN image_url VARCHAR(500) AFTER subtitle
      `);
      console.log('✓ image_url column added');
    } else {
      console.log('✓ image_url column already exists');
    }
    
    console.log('✓ Migration completed successfully');
    process.exit(0);
  } catch (error) {
    console.error('Error adding columns:', error.message);
    process.exit(1);
  }
}

addContactSectionFields();
