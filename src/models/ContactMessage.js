const { pool } = require('../config/database');

class ContactMessage {
  static async findAll(page = 1, limit = 10) {
    const offset = (page - 1) * limit;
    
    const [rows] = await pool.query(
      'SELECT * FROM contact_messages ORDER BY created_at DESC LIMIT ? OFFSET ?',
      [limit, offset]
    );
    
    const [countResult] = await pool.query('SELECT COUNT(*) as total FROM contact_messages');
    const total = countResult[0].total;
    
    return { messages: rows, total };
  }
  
  static async findById(id) {
    const [rows] = await pool.query('SELECT * FROM contact_messages WHERE id = ?', [id]);
    return rows[0];
  }
  
  static async create(messageData) {
    const { name, email, phone, subject, message } = messageData;
    
    const [result] = await pool.query(
      'INSERT INTO contact_messages (name, email, phone, subject, message) VALUES (?, ?, ?, ?, ?)',
      [name, email, phone || null, subject || null, message]
    );
    
    return this.findById(result.insertId);
  }
  
  static async update(id, messageData) {
    const { name, email, phone, subject, message, is_read, is_replied } = messageData;
    
    const updates = [];
    const values = [];
    
    if (name !== undefined) {
      updates.push('name = ?');
      values.push(name);
    }
    if (email !== undefined) {
      updates.push('email = ?');
      values.push(email);
    }
    if (phone !== undefined) {
      updates.push('phone = ?');
      values.push(phone);
    }
    if (subject !== undefined) {
      updates.push('subject = ?');
      values.push(subject);
    }
    if (message !== undefined) {
      updates.push('message = ?');
      values.push(message);
    }
    if (is_read !== undefined) {
      updates.push('is_read = ?');
      values.push(is_read);
    }
    if (is_replied !== undefined) {
      updates.push('is_replied = ?');
      values.push(is_replied);
    }
    
    if (updates.length === 0) {
      return this.findById(id);
    }
    
    values.push(id);
    
    const [result] = await pool.query(
      `UPDATE contact_messages SET ${updates.join(', ')} WHERE id = ?`,
      values
    );
    
    if (result.affectedRows === 0) {
      return null;
    }
    
    return this.findById(id);
  }
  
  static async markAsRead(id) {
    await pool.query('UPDATE contact_messages SET is_read = true WHERE id = ?', [id]);
    return this.findById(id);
  }
  
  static async delete(id) {
    const [result] = await pool.query('DELETE FROM contact_messages WHERE id = ?', [id]);
    return result.affectedRows > 0;
  }
  
  static async getUnreadCount() {
    const [rows] = await pool.query('SELECT COUNT(*) as count FROM contact_messages WHERE is_read = false');
    return rows[0].count;
  }
}

module.exports = ContactMessage;
