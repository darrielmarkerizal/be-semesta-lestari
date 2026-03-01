#!/usr/bin/env node

/**
 * Synchronize Gallery Categories and Gallery Items
 * This script ensures all gallery items have valid category references
 */

const { pool } = require('../config/database');

const GREEN = '\x1b[32m';
const RED = '\x1b[31m';
const YELLOW = '\x1b[33m';
const NC = '\x1b[0m';

async function syncGalleryCategories() {
  console.log(`${YELLOW}=== Gallery Categories Synchronization ===${NC}\n`);

  try {
    // Step 1: Check current state
    console.log(`${YELLOW}Step 1: Checking current state...${NC}`);
    
    const [categories] = await pool.query('SELECT * FROM gallery_categories ORDER BY id');
    console.log(`Found ${categories.length} gallery categories:`);
    categories.forEach(cat => {
      console.log(`  - ID: ${cat.id}, Name: ${cat.name}, Slug: ${cat.slug}, Active: ${cat.is_active}`);
    });

    const [items] = await pool.query('SELECT id, title, category_id FROM gallery_items ORDER BY id');
    console.log(`\nFound ${items.length} gallery items:`);
    items.forEach(item => {
      console.log(`  - ID: ${item.id}, Title: ${item.title}, Category ID: ${item.category_id}`);
    });

    // Step 2: Check for items with NULL or invalid category_id
    console.log(`\n${YELLOW}Step 2: Checking for items with invalid categories...${NC}`);
    
    const [invalidItems] = await pool.query(`
      SELECT gi.id, gi.title, gi.category_id
      FROM gallery_items gi
      LEFT JOIN gallery_categories gc ON gi.category_id = gc.id
      WHERE gi.category_id IS NULL OR gc.id IS NULL
    `);

    if (invalidItems.length > 0) {
      console.log(`${RED}Found ${invalidItems.length} items with invalid categories:${NC}`);
      invalidItems.forEach(item => {
        console.log(`  - ID: ${item.id}, Title: ${item.title}, Category ID: ${item.category_id || 'NULL'}`);
      });

      // Get or create default category
      let defaultCategory;
      const [existingDefault] = await pool.query(
        "SELECT * FROM gallery_categories WHERE slug = 'events' LIMIT 1"
      );

      if (existingDefault.length > 0) {
        defaultCategory = existingDefault[0];
        console.log(`\n${GREEN}Using existing 'Events' category (ID: ${defaultCategory.id}) as default${NC}`);
      } else {
        // Create default category
        const [result] = await pool.query(`
          INSERT INTO gallery_categories (name, slug, description, is_active)
          VALUES ('Events', 'events', 'Event photos and activities', true)
        `);
        defaultCategory = { id: result.insertId, name: 'Events', slug: 'events' };
        console.log(`\n${GREEN}Created default 'Events' category (ID: ${defaultCategory.id})${NC}`);
      }

      // Update items with invalid categories
      console.log(`\n${YELLOW}Updating items with invalid categories...${NC}`);
      for (const item of invalidItems) {
        await pool.query(
          'UPDATE gallery_items SET category_id = ? WHERE id = ?',
          [defaultCategory.id, item.id]
        );
        console.log(`${GREEN}✓${NC} Updated item ${item.id} (${item.title}) to category ${defaultCategory.id}`);
      }
    } else {
      console.log(`${GREEN}✓ All items have valid categories${NC}`);
    }

    // Step 3: Ensure all required categories exist
    console.log(`\n${YELLOW}Step 3: Ensuring required categories exist...${NC}`);
    
    const requiredCategories = [
      { name: 'Events', slug: 'events', description: 'Event photos and activities' },
      { name: 'Projects', slug: 'projects', description: 'Project documentation and progress' },
      { name: 'Community', slug: 'community', description: 'Community engagement activities' },
      { name: 'Nature', slug: 'nature', description: 'Nature and wildlife photography' }
    ];

    for (const cat of requiredCategories) {
      const [existing] = await pool.query(
        'SELECT * FROM gallery_categories WHERE slug = ?',
        [cat.slug]
      );

      if (existing.length === 0) {
        await pool.query(`
          INSERT INTO gallery_categories (name, slug, description, is_active)
          VALUES (?, ?, ?, true)
        `, [cat.name, cat.slug, cat.description]);
        console.log(`${GREEN}✓${NC} Created category: ${cat.name}`);
      } else {
        console.log(`  Category '${cat.name}' already exists`);
      }
    }

    // Step 4: Show final state
    console.log(`\n${YELLOW}Step 4: Final state...${NC}`);
    
    const [finalCategories] = await pool.query('SELECT * FROM gallery_categories ORDER BY id');
    console.log(`\nGallery Categories (${finalCategories.length} total):`);
    for (const cat of finalCategories) {
      const [count] = await pool.query(
        'SELECT COUNT(*) as count FROM gallery_items WHERE category_id = ?',
        [cat.id]
      );
      console.log(`  - ${cat.name} (ID: ${cat.id}, Slug: ${cat.slug}) - ${count[0].count} items`);
    }

    // Step 5: Verify all items now have valid categories
    console.log(`\n${YELLOW}Step 5: Verification...${NC}`);
    
    const [verification] = await pool.query(`
      SELECT 
        gi.id,
        gi.title,
        gi.category_id,
        gc.name as category_name,
        gc.slug as category_slug
      FROM gallery_items gi
      LEFT JOIN gallery_categories gc ON gi.category_id = gc.id
      ORDER BY gi.id
    `);

    let allValid = true;
    verification.forEach(item => {
      if (!item.category_name) {
        console.log(`${RED}✗${NC} Item ${item.id} still has invalid category`);
        allValid = false;
      }
    });

    if (allValid) {
      console.log(`${GREEN}✓ All ${verification.length} gallery items have valid categories${NC}`);
    }

    console.log(`\n${GREEN}=== Synchronization Complete ===${NC}`);

  } catch (error) {
    console.error(`${RED}Error: ${error.message}${NC}`);
    console.error(error.stack);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run synchronization
syncGalleryCategories().catch(error => {
  console.error(`${RED}Fatal error: ${error.message}${NC}`);
  process.exit(1);
});
