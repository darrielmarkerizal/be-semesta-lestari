const BaseModel = require('./BaseModel');
const { pool } = require('../config/database');

class FAQ extends BaseModel {
  constructor() {
    super('faqs');
  }

  async findAllPaginatedWithSearch(page = 1, limit = 10, isActive = null, category = null, search = null) {
    const offset = (page - 1) * limit;
    let query = `SELECT * FROM ${this.tableName}`;
    const params = [];
    const conditions = [];
    
    if (isActive !== null) {
      conditions.push('is_active = ?');
      params.push(isActive);
    }
    
    if (category) {
      conditions.push('category = ?');
      params.push(category);
    }
    
    if (search) {
      conditions.push('(question LIKE ? OR answer LIKE ? OR category LIKE ?)');
      const searchPattern = `%${search}%`;
      params.push(searchPattern, searchPattern, searchPattern);
    }
    
    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }
    
    query += ' ORDER BY order_position ASC, created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);
    
    const [rows] = await pool.query(query, params);
    
    // Count query
    let countQuery = `SELECT COUNT(*) as total FROM ${this.tableName}`;
    const countParams = [];
    const countConditions = [];
    
    if (isActive !== null) {
      countConditions.push('is_active = ?');
      countParams.push(isActive);
    }
    
    if (category) {
      countConditions.push('category = ?');
      countParams.push(category);
    }
    
    if (search) {
      countConditions.push('(question LIKE ? OR answer LIKE ? OR category LIKE ?)');
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

module.exports = new FAQ();
