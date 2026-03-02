const BaseModel = require('./BaseModel');
const { pool } = require('../config/database');

class Program extends BaseModel {
  constructor() {
    super('programs');
  }

  async findAllPaginatedWithSearch(page = 1, limit = 10, isActive = null, categoryId = null, search = null) {
    const offset = (page - 1) * limit;
    
    // Check if category_id column exists
    const [columns] = await pool.query('SHOW COLUMNS FROM programs LIKE "category_id"');
    const hasCategoryId = columns.length > 0;
    
    let query = hasCategoryId 
      ? `SELECT 
          p.*,
          pc.name as category_name,
          pc.slug as category_slug
        FROM programs p
        LEFT JOIN program_categories pc ON p.category_id = pc.id`
      : `SELECT * FROM programs p`;
    
    const params = [];
    const conditions = [];
    
    if (isActive !== null) {
      conditions.push('p.is_active = ?');
      params.push(isActive);
    }
    
    if (hasCategoryId && categoryId) {
      conditions.push('p.category_id = ?');
      params.push(categoryId);
    }
    
    if (search) {
      if (hasCategoryId) {
        conditions.push('(p.name LIKE ? OR p.description LIKE ? OR pc.name LIKE ?)');
        const searchPattern = `%${search}%`;
        params.push(searchPattern, searchPattern, searchPattern);
      } else {
        conditions.push('(p.name LIKE ? OR p.description LIKE ?)');
        const searchPattern = `%${search}%`;
        params.push(searchPattern, searchPattern);
      }
    }
    
    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }
    
    query += ' ORDER BY p.order_position ASC, p.created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);
    
    const [rows] = await pool.query(query, params);
    
    // Count query
    let countQuery = hasCategoryId
      ? 'SELECT COUNT(*) as total FROM programs p LEFT JOIN program_categories pc ON p.category_id = pc.id'
      : 'SELECT COUNT(*) as total FROM programs p';
    const countParams = [];
    const countConditions = [];
    
    if (isActive !== null) {
      countConditions.push('p.is_active = ?');
      countParams.push(isActive);
    }
    
    if (hasCategoryId && categoryId) {
      countConditions.push('p.category_id = ?');
      countParams.push(categoryId);
    }
    
    if (search) {
      if (hasCategoryId) {
        countConditions.push('(p.name LIKE ? OR p.description LIKE ? OR pc.name LIKE ?)');
        const searchPattern = `%${search}%`;
        countParams.push(searchPattern, searchPattern, searchPattern);
      } else {
        countConditions.push('(p.name LIKE ? OR p.description LIKE ?)');
        const searchPattern = `%${search}%`;
        countParams.push(searchPattern, searchPattern);
      }
    }
    
    if (countConditions.length > 0) {
      countQuery += ' WHERE ' + countConditions.join(' AND ');
    }
    
    const [countResult] = await pool.query(countQuery, countParams);
    const total = countResult[0].total;
    
    return { data: rows, total };
  }

  async update(id, data) {
    // If setting is_highlighted to true, first unhighlight all other programs
    if (data.is_highlighted === true || data.is_highlighted === 1) {
      await pool.query(
        'UPDATE programs SET is_highlighted = FALSE WHERE id != ?',
        [id]
      );
    }
    
    // Call parent update method
    return super.update(id, data);
  }
}

module.exports = new Program();
