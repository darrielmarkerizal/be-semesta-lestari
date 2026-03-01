const { pool } = require('../config/database');
const BaseModel = require('./BaseModel');

class GalleryItem extends BaseModel {
  constructor() {
    super('gallery_items');
  }
  
  async findAllPaginated(page = 1, limit = 10, isActive = null, category = null, search = null) {
    const offset = (page - 1) * limit;
    let query = `
      SELECT 
        g.*,
        gc.name as category_name,
        gc.slug as category_slug
      FROM gallery_items g
      LEFT JOIN gallery_categories gc ON g.category_id = gc.id
    `;
    const params = [];
    const conditions = [];
    
    if (isActive !== null) {
      conditions.push('g.is_active = ?');
      params.push(isActive);
    }
    
    // Support both category ID and slug
    if (category) {
      if (!isNaN(category)) {
        // Numeric value - filter by category ID
        conditions.push('g.category_id = ?');
        params.push(parseInt(category));
      } else {
        // String value - filter by category slug
        conditions.push('gc.slug = ?');
        params.push(category);
      }
    }
    
    if (search) {
      conditions.push('(g.title LIKE ? OR gc.name LIKE ?)');
      const searchPattern = `%${search}%`;
      params.push(searchPattern, searchPattern);
    }
    
    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }
    
    query += ' ORDER BY g.gallery_date DESC, g.created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);
    
    const [rows] = await pool.query(query, params);
    
    // Count query
    let countQuery = 'SELECT COUNT(*) as total FROM gallery_items g';
    const countParams = [];
    
    if (category || search) {
      countQuery += ' LEFT JOIN gallery_categories gc ON g.category_id = gc.id';
    }
    
    const countConditions = [];
    if (isActive !== null) {
      countConditions.push('g.is_active = ?');
      countParams.push(isActive);
    }
    
    // Support both category ID and slug in count
    if (category) {
      if (!isNaN(category)) {
        countConditions.push('g.category_id = ?');
        countParams.push(parseInt(category));
      } else {
        countConditions.push('gc.slug = ?');
        countParams.push(category);
      }
    }
    
    if (search) {
      countConditions.push('(g.title LIKE ? OR gc.name LIKE ?)');
      const searchPattern = `%${search}%`;
      countParams.push(searchPattern, searchPattern);
    }
    
    if (countConditions.length > 0) {
      countQuery += ' WHERE ' + countConditions.join(' AND ');
    }
    
    const [countResult] = await pool.query(countQuery, countParams);
    const total = countResult[0].total;
    
    return { data: rows, total };
  }
  
  async findById(id) {
    const [rows] = await pool.query(`
      SELECT 
        g.*,
        gc.name as category_name,
        gc.slug as category_slug
      FROM gallery_items g
      LEFT JOIN gallery_categories gc ON g.category_id = gc.id
      WHERE g.id = ?
    `, [id]);
    return rows[0];
  }
}

module.exports = new GalleryItem();

