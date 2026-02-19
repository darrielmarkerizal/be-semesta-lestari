const { pool } = require('../config/database');

class Settings {
  static async findByKey(key) {
    const [rows] = await pool.query(
      'SELECT * FROM settings WHERE `key` = ?',
      [key]
    );
    return rows[0];
  }
  
  static async findAll() {
    const [rows] = await pool.query('SELECT * FROM settings ORDER BY `key`');
    return rows;
  }
  
  static async upsert(key, value) {
    const existing = await this.findByKey(key);
    
    if (existing) {
      await pool.query(
        'UPDATE settings SET value = ? WHERE `key` = ?',
        [value, key]
      );
    } else {
      await pool.query(
        'INSERT INTO settings (`key`, value) VALUES (?, ?)',
        [key, value]
      );
    }
    
    return this.findByKey(key);
  }
  
  static async delete(key) {
    const [result] = await pool.query('DELETE FROM settings WHERE `key` = ?', [key]);
    return result.affectedRows > 0;
  }
}

module.exports = Settings;
