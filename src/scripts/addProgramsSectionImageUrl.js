require('dotenv').config();
const db = require('../config/db');

async function addProgramsSectionImageUrl() {
  try {
    console.log('Adding image_url column to home_programs_section table...');
    
    // Check if column exists
    const [columns] = await db.query(`
      SELECT COLUMN_NAME 
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = DATABASE() 
      AND TABLE_NAME = 'home_programs_section' 
      AND COLUMN_NAME = 'image_url'
    `);
    
    if (columns.length === 0) {
      // Add image_url column
      await db.query(`
        ALTER TABLE home_programs_section 
        ADD COLUMN image_url VARCHAR(500) AFTER subtitle
      `);
      console.log('✓ image_url column added successfully to home_programs_section');
    } else {
      console.log('✓ image_url column already exists in home_programs_section');
    }
    
    process.exit(0);
  } catch (error) {
    console.error('Error adding image_url column:', error.message);
    process.exit(1);
  }
}

addProgramsSectionImageUrl();
