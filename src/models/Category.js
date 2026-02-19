const { pool } = require('../config/database');
const BaseModel = require('./BaseModel');

class Category extends BaseModel {
  constructor() {
    super('categories');
  }
  
  async findAll(isActive = null) {
    let query = `SELECT * FROM ${this.tableName}`;
    const params = [];
    
    if (isActive !== null) {
      query += ' WHERE is_active = ?';
      params.push(isActive);
    }
    
    query += ' ORDER BY name ASC';
    
    const [rows] = await pool.query(query, params);
    return rows;
  }
  
  async findBySlug(slug) {
    const [rows] = await pool.query(
      `SELECT * FROM ${this.tableName} WHERE slug = ? AND is_active = TRUE`,
      [slug]
    );
    return rows[0] || null;
  }
  
  async hasRelatedArticles(categoryId) {
    const [rows] = await pool.query(
      'SELECT COUNT(*) as count FROM articles WHERE category_id = ?',
      [categoryId]
    );
    return rows[0].count > 0;
  }
}

module.exports = new Category();
