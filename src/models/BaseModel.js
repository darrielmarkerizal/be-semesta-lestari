const { pool } = require('../config/database');

/**
 * Base model class with common CRUD operations
 */
class BaseModel {
  constructor(tableName) {
    this.tableName = tableName;
  }
  
  async findAll(isActive = null, orderBy = 'order_position ASC, created_at DESC') {
    let query = `SELECT * FROM ${this.tableName}`;
    const params = [];
    
    if (isActive !== null) {
      query += ' WHERE is_active = ?';
      params.push(isActive);
    }
    
    query += ` ORDER BY ${orderBy}`;
    
    const [rows] = await pool.query(query, params);
    return rows;
  }
  
  async findAllPaginated(page = 1, limit = 10, isActive = null) {
    const offset = (page - 1) * limit;
    let query = `SELECT * FROM ${this.tableName}`;
    const params = [];
    
    if (isActive !== null) {
      query += ' WHERE is_active = ?';
      params.push(isActive);
    }
    
    query += ' ORDER BY order_position ASC, created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);
    
    const [rows] = await pool.query(query, params);
    
    const countQuery = isActive !== null 
      ? `SELECT COUNT(*) as total FROM ${this.tableName} WHERE is_active = ?`
      : `SELECT COUNT(*) as total FROM ${this.tableName}`;
    const countParams = isActive !== null ? [isActive] : [];
    
    const [countResult] = await pool.query(countQuery, countParams);
    const total = countResult[0].total;
    
    return { data: rows, total };
  }
  
  async findById(id) {
    const [rows] = await pool.query(`SELECT * FROM ${this.tableName} WHERE id = ?`, [id]);
    return rows[0];
  }
  
  async findByCategory(category, isActive = true) {
    const [rows] = await pool.query(
      `SELECT * FROM ${this.tableName} WHERE category = ? AND is_active = ? ORDER BY order_position ASC`,
      [category, isActive]
    );
    return rows;
  }
  
  async create(data) {
    const fields = Object.keys(data);
    const values = Object.values(data);
    const placeholders = fields.map(() => '?').join(', ');
    
    const [result] = await pool.query(
      `INSERT INTO ${this.tableName} (${fields.join(', ')}) VALUES (${placeholders})`,
      values
    );
    
    return this.findById(result.insertId);
  }
  
  async update(id, data) {
    const updates = [];
    const values = [];
    
    Object.entries(data).forEach(([key, value]) => {
      if (value !== undefined) {
        updates.push(`${key} = ?`);
        values.push(value);
      }
    });
    
    if (updates.length === 0) {
      return this.findById(id);
    }
    
    values.push(id);
    
    await pool.query(
      `UPDATE ${this.tableName} SET ${updates.join(', ')} WHERE id = ?`,
      values
    );
    
    return this.findById(id);
  }
  
  async delete(id) {
    const [result] = await pool.query(`DELETE FROM ${this.tableName} WHERE id = ?`, [id]);
    return result.affectedRows > 0;
  }
  
  async getFirst(isActive = true) {
    const [rows] = await pool.query(
      `SELECT * FROM ${this.tableName} WHERE is_active = ? LIMIT 1`,
      [isActive]
    );
    return rows[0];
  }
}

module.exports = BaseModel;
