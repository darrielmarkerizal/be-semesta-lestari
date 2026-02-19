const { pool } = require('../config/database');

class PageSettings {
  static async findBySlug(slug) {
    const [rows] = await pool.query(
      'SELECT * FROM page_settings WHERE page_slug = ?',
      [slug]
    );
    return rows[0];
  }
  
  static async upsert(slug, data) {
    const existing = await this.findBySlug(slug);
    
    if (existing) {
      const updates = [];
      const values = [];
      
      Object.entries(data).forEach(([key, value]) => {
        if (value !== undefined && key !== 'page_slug') {
          updates.push(`${key} = ?`);
          values.push(value);
        }
      });
      
      if (updates.length > 0) {
        values.push(slug);
        await pool.query(
          `UPDATE page_settings SET ${updates.join(', ')} WHERE page_slug = ?`,
          values
        );
      }
    } else {
      const fields = ['page_slug', ...Object.keys(data)];
      const values = [slug, ...Object.values(data)];
      const placeholders = fields.map(() => '?').join(', ');
      
      await pool.query(
        `INSERT INTO page_settings (${fields.join(', ')}) VALUES (${placeholders})`,
        values
      );
    }
    
    return this.findBySlug(slug);
  }
}

module.exports = PageSettings;
