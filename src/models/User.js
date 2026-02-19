const { pool } = require('../config/database');
const bcrypt = require('bcryptjs');

class User {
  /**
   * Find user by email
   */
  static async findByEmail(email) {
    const [rows] = await pool.query(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );
    return rows[0];
  }
  
  /**
   * Find user by ID
   */
  static async findById(id) {
    const [rows] = await pool.query(
      'SELECT id, username, email, role, status, created_at, updated_at FROM users WHERE id = ?',
      [id]
    );
    return rows[0];
  }
  
  /**
   * Get all users with pagination
   */
  static async findAll(page = 1, limit = 10) {
    const offset = (page - 1) * limit;
    
    const [rows] = await pool.query(
      'SELECT id, username, email, role, status, created_at, updated_at FROM users ORDER BY created_at DESC LIMIT ? OFFSET ?',
      [limit, offset]
    );
    
    const [countResult] = await pool.query('SELECT COUNT(*) as total FROM users');
    const total = countResult[0].total;
    
    return { users: rows, total };
  }
  
  /**
   * Create new user
   */
  static async create(userData) {
    const { username, email, password, role = 'admin' } = userData;
    
    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);
    
    const [result] = await pool.query(
      'INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)',
      [username, email, hashedPassword, role]
    );
    
    return this.findById(result.insertId);
  }
  
  /**
   * Update user
   */
  static async update(id, userData) {
    const updates = [];
    const values = [];
    
    if (userData.username) {
      updates.push('username = ?');
      values.push(userData.username);
    }
    
    if (userData.email) {
      updates.push('email = ?');
      values.push(userData.email);
    }
    
    if (userData.password) {
      const hashedPassword = await bcrypt.hash(userData.password, 10);
      updates.push('password = ?');
      values.push(hashedPassword);
    }
    
    if (userData.role) {
      updates.push('role = ?');
      values.push(userData.role);
    }
    
    if (userData.status) {
      updates.push('status = ?');
      values.push(userData.status);
    }
    
    if (updates.length === 0) {
      return this.findById(id);
    }
    
    values.push(id);
    
    await pool.query(
      `UPDATE users SET ${updates.join(', ')} WHERE id = ?`,
      values
    );
    
    return this.findById(id);
  }
  
  /**
   * Delete user
   */
  static async delete(id) {
    const [result] = await pool.query('DELETE FROM users WHERE id = ?', [id]);
    return result.affectedRows > 0;
  }
  
  /**
   * Verify password
   */
  static async verifyPassword(plainPassword, hashedPassword) {
    return bcrypt.compare(plainPassword, hashedPassword);
  }
}

module.exports = User;
