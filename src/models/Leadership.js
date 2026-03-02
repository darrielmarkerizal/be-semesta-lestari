const BaseModel = require('./BaseModel');
const { pool } = require('../config/database');

class Leadership extends BaseModel {
  constructor() {
    super('leadership');
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
      conditions.push('(name LIKE ? OR position LIKE ? OR bio LIKE ? OR email LIKE ?)');
      const searchPattern = `%${search}%`;
      params.push(searchPattern, searchPattern, searchPattern, searchPattern);
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
    
    if (search) {
      countConditions.push('(name LIKE ? OR position LIKE ? OR bio LIKE ? OR email LIKE ?)');
      const searchPattern = `%${search}%`;
      countParams.push(searchPattern, searchPattern, searchPattern, searchPattern);
    }
    
    if (countConditions.length > 0) {
      countQuery += ' WHERE ' + countConditions.join(' AND ');
    }
    
    const [countResult] = await pool.query(countQuery, countParams);
    const total = countResult[0].total;
    
    return { data: rows, total };
  }

  async update(id, data) {
    // If setting is_highlighted to true, first unhighlight all other leadership members
    if (data.is_highlighted === true || data.is_highlighted === 1) {
      await pool.query(
        'UPDATE leadership SET is_highlighted = FALSE WHERE id != ?',
        [id]
      );
    }
    
    // Call parent update method
    return super.update(id, data);
  }
}

module.exports = new Leadership();
