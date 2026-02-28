const BaseModel = require('./BaseModel');
const { pool } = require('../config/database');

class History extends BaseModel {
  constructor() {
    super('history');
  }

  async findAllPaginatedWithSearch(page = 1, limit = 10, isActive = null, search = null) {
    const offset = (page - 1) * limit;
    let query = `SELECT * FROM ${this.tableName}`;
    const params = [];
    const conditions = [];
    
    if (isActive !== null) {
      conditions.push('is_active = ?');
      params.push(isActive);
    }
    
    if (search) {
      conditions.push('(title LIKE ? OR content LIKE ? OR year LIKE ?)');
      const searchPattern = `%${search}%`;
      params.push(searchPattern, searchPattern, searchPattern);
    }
    
    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }
    
    query += ' ORDER BY year ASC, order_position ASC LIMIT ? OFFSET ?';
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
    
    if (search) {
      countConditions.push('(title LIKE ? OR content LIKE ? OR year LIKE ?)');
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

module.exports = new History();
