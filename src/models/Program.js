const BaseModel = require('./BaseModel');
const { pool } = require('../config/database');

class Program extends BaseModel {
  constructor() {
    super('programs');
  }

  async findAllPaginatedWithSearch(page = 1, limit = 10, isActive = null, categoryId = null, search = null) {
    const offset = (page - 1) * limit;
    let query = `
      SELECT 
        p.*,
        pc.name as category_name,
        pc.slug as category_slug
      FROM programs p
      LEFT JOIN program_categories pc ON p.category_id = pc.id
    `;
    const params = [];
    const conditions = [];
    
    if (isActive !== null) {
      conditions.push('p.is_active = ?');
      params.push(isActive);
    }
    
    if (categoryId) {
      conditions.push('p.category_id = ?');
      params.push(categoryId);
    }
    
    if (search) {
      conditions.push('(p.name LIKE ? OR p.description LIKE ? OR pc.name LIKE ?)');
      const searchPattern = `%${search}%`;
      params.push(searchPattern, searchPattern, searchPattern);
    }
    
    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }
    
    query += ' ORDER BY p.order_position ASC, p.created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);
    
    const [rows] = await pool.query(query, params);
    
    // Count query
    let countQuery = 'SELECT COUNT(*) as total FROM programs p';
    const countParams = [];
    
    if (categoryId || search) {
      countQuery += ' LEFT JOIN program_categories pc ON p.category_id = pc.id';
    }
    
    const countConditions = [];
    if (isActive !== null) {
      countConditions.push('p.is_active = ?');
      countParams.push(isActive);
    }
    
    if (categoryId) {
      countConditions.push('p.category_id = ?');
      countParams.push(categoryId);
    }
    
    if (search) {
      countConditions.push('(p.name LIKE ? OR p.description LIKE ? OR pc.name LIKE ?)');
      const searchPattern = `%${search}%`;
      countParams.push(searchPattern, searchPattern, searchPattern);
    }
    
    if (countConditions.length > 0) {
      countQuery += ' WHERE ' + countConditions.join(' AND ');
    }
    
    const [countResult] = await pool.query(countQuery, countParams);
    const total = countResult[0].total;
    
    return { data: rows, total };
  }
}

module.exports = new Program();
