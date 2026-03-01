#!/usr/bin/env node

/**
 * Gallery Image Seeder
 * Seeds gallery with public images from Unsplash
 */

const { pool } = require('../config/database');

// Public images from Unsplash (free to use)
const galleryImages = [
  // Events Category (id: 1)
  {
    title: 'Community Tree Planting Event 2024',
    image_url: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
    category_id: 1,
    gallery_date: '2024-03-15',
    order_position: 1,
    is_active: true
  },
  {
    title: 'Environmental Workshop with Students',
    image_url: 'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=800',
    category_id: 1,
    gallery_date: '2024-03-10',
    order_position: 2,
    is_active: true
  },
  {
    title: 'Beach Cleanup Campaign',
    image_url: 'https://images.unsplash.com/photo-1618477461853-cf6ed80faba5?w=800',
    category_id: 1,
    gallery_date: '2024-02-28',
    order_position: 3,
    is_active: true
  },
  {
    title: 'Annual Environmental Conference',
    image_url: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
    category_id: 1,
    gallery_date: '2024-02-15',
    order_position: 4,
    is_active: true
  },

  // Projects Category (id: 2)
  {
    title: 'Reforestation Project - Phase 1',
    image_url: 'https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?w=800',
    category_id: 2,
    gallery_date: '2024-03-20',
    order_position: 5,
    is_active: true
  },
  {
    title: 'Solar Panel Installation',
    image_url: 'https://images.unsplash.com/photo-1509391366360-2e959784a276?w=800',
    category_id: 2,
    gallery_date: '2024-03-05',
    order_position: 6,
    is_active: true
  },
  {
    title: 'Water Conservation System',
    image_url: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800',
    category_id: 2,
    gallery_date: '2024-02-20',
    order_position: 7,
    is_active: true
  },
  {
    title: 'Wildlife Habitat Restoration',
    image_url: 'https://images.unsplash.com/photo-1535083783855-76ae62b2914e?w=800',
    category_id: 2,
    gallery_date: '2024-02-10',
    order_position: 8,
    is_active: true
  },

  // Community Category (id: 3)
  {
    title: 'Community Garden Initiative',
    image_url: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800',
    category_id: 3,
    gallery_date: '2024-03-18',
    order_position: 9,
    is_active: true
  },
  {
    title: 'Youth Environmental Education',
    image_url: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800',
    category_id: 3,
    gallery_date: '2024-03-08',
    order_position: 10,
    is_active: true
  },
  {
    title: 'Local Farmers Training Program',
    image_url: 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=800',
    category_id: 3,
    gallery_date: '2024-02-25',
    order_position: 11,
    is_active: true
  },
  {
    title: 'Community Recycling Program',
    image_url: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=800',
    category_id: 3,
    gallery_date: '2024-02-12',
    order_position: 12,
    is_active: true
  },

  // Nature Category (id: 4)
  {
    title: 'Protected Forest Area',
    image_url: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
    category_id: 4,
    gallery_date: '2024-03-22',
    order_position: 13,
    is_active: true
  },
  {
    title: 'Mountain Conservation Zone',
    image_url: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
    category_id: 4,
    gallery_date: '2024-03-12',
    order_position: 14,
    is_active: true
  },
  {
    title: 'Coastal Ecosystem',
    image_url: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800',
    category_id: 4,
    gallery_date: '2024-02-28',
    order_position: 15,
    is_active: true
  },
  {
    title: 'Wildlife Sanctuary',
    image_url: 'https://images.unsplash.com/photo-1564760055775-d63b17a55c44?w=800',
    category_id: 4,
    gallery_date: '2024-02-18',
    order_position: 16,
    is_active: true
  }
];

async function seedGallery() {
  console.log('🌱 Starting gallery seeding...\n');

  try {
    // Check if gallery items already exist
    const [existing] = await pool.query('SELECT COUNT(*) as count FROM gallery_items');
    
    if (existing[0].count > 0) {
      console.log(`⚠️  Found ${existing[0].count} existing gallery items.`);
      console.log('   Skipping seeding to avoid duplicates.');
      console.log('   To reseed, delete existing items first.\n');
      return;
    }

    // Insert gallery items
    console.log('📸 Inserting gallery items...');
    let inserted = 0;

    for (const item of galleryImages) {
      try {
        await pool.query(
          `INSERT INTO gallery_items (title, image_url, category_id, gallery_date, order_position, is_active)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [item.title, item.image_url, item.category_id, item.gallery_date, item.order_position, item.is_active]
        );
        inserted++;
        console.log(`   ✓ ${item.title}`);
      } catch (error) {
        console.error(`   ✗ Failed to insert: ${item.title}`);
        console.error(`     Error: ${error.message}`);
      }
    }

    console.log(`\n✅ Successfully seeded ${inserted} gallery items!`);

    // Show summary by category
    const [summary] = await pool.query(`
      SELECT gc.name, COUNT(gi.id) as count
      FROM gallery_categories gc
      LEFT JOIN gallery_items gi ON gc.id = gi.category_id
      GROUP BY gc.id, gc.name
      ORDER BY gc.id
    `);

    console.log('\n📊 Gallery Summary by Category:');
    summary.forEach(cat => {
      console.log(`   ${cat.name}: ${cat.count} items`);
    });

  } catch (error) {
    console.error('❌ Error seeding gallery:', error.message);
    throw error;
  } finally {
    await pool.end();
  }
}

// Run seeder
seedGallery()
  .then(() => {
    console.log('\n🎉 Gallery seeding completed!');
    process.exit(0);
  })
  .catch(error => {
    console.error('\n💥 Gallery seeding failed:', error.message);
    process.exit(1);
  });
