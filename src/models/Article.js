const { pool } = require('../config/database');
const slugify = require('slugify');

class Article {
  static async findAll(page = 1, limit = 10, isActive = true, categorySlug = null) {
    const offset = (page - 1) * limit;
    let query = `
      SELECT 
        a.*,
        c.name as category_name,
        c.slug as category_slug
      FROM articles a
      LEFT JOIN categories c ON a.category_id = c.id
    `;
    const params = [];
    const conditions = [];
    
    if (isActive !== null) {
      conditions.push('a.is_active = ?');
      params.push(isActive);
    }
    
    if (categorySlug) {
      conditions.push('c.slug = ?');
      params.push(categorySlug);
    }
    
    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }
    
    query += ' ORDER BY a.published_at DESC, a.created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);
    
    const [rows] = await pool.query(query, params);
    
    // Count query
    let countQuery = 'SELECT COUNT(*) as total FROM articles a';
    const countParams = [];
    
    if (categorySlug) {
      countQuery += ' LEFT JOIN categories c ON a.category_id = c.id';
    }
    
    const countConditions = [];
    if (isActive !== null) {
      countConditions.push('a.is_active = ?');
      countParams.push(isActive);
    }
    
    if (categorySlug) {
      countConditions.push('c.slug = ?');
      countParams.push(categorySlug);
    }
    
    if (countConditions.length > 0) {
      countQuery += ' WHERE ' + countConditions.join(' AND ');
    }
    
    const [countResult] = await pool.query(countQuery, countParams);
    const total = countResult[0].total;
    
    return { articles: rows, total };
  }
  
  static async findById(id) {
    const [rows] = await pool.query(`
      SELECT 
        a.*,
        c.name as category_name,
        c.slug as category_slug
      FROM articles a
      LEFT JOIN categories c ON a.category_id = c.id
      WHERE a.id = ?
    `, [id]);
    return rows[0];
  }
  
  static async findBySlug(slug) {
    const [rows] = await pool.query(`
      SELECT 
        a.*,
        c.name as category_name,
        c.slug as category_slug
      FROM articles a
      LEFT JOIN categories c ON a.category_id = c.id
      WHERE a.slug = ? AND a.is_active = true
    `, [slug]);
    return rows[0];
  }
  
  static async create(articleData, authorId) {
    const { title, subtitle, content, excerpt, image_url, category_id, published_at, is_active } = articleData;
    
    // Generate unique slug
    let slug = slugify(title, { lower: true, strict: true });
    let slugExists = true;
    let counter = 1;
    
    while (slugExists) {
      const [existing] = await pool.query('SELECT id FROM articles WHERE slug = ?', [slug]);
      if (existing.length === 0) {
        slugExists = false;
      } else {
        slug = `${slugify(title, { lower: true, strict: true })}-${counter}`;
        counter++;
      }
    }
    
    const [result] = await pool.query(
      `INSERT INTO articles (title, subtitle, slug, content, excerpt, image_url, author_id, category_id, published_at, is_active) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [title, subtitle || null, slug, content, excerpt || null, image_url || null, authorId, category_id || null, published_at || new Date(), is_active !== undefined ? is_active : true]
    );
    
    return this.findById(result.insertId);
  }
  
  static async update(id, articleData) {
    const updates = [];
    const values = [];
    
    if (articleData.title) {
      updates.push('title = ?');
      values.push(articleData.title);
      
      // Regenerate slug if title changed
      const slug = slugify(articleData.title, { lower: true, strict: true });
      updates.push('slug = ?');
      values.push(slug);
    }
    
    if (articleData.subtitle !== undefined) {
      updates.push('subtitle = ?');
      values.push(articleData.subtitle);
    }
    
    if (articleData.content !== undefined) {
      updates.push('content = ?');
      values.push(articleData.content);
    }
    
    if (articleData.excerpt !== undefined) {
      updates.push('excerpt = ?');
      values.push(articleData.excerpt);
    }
    
    if (articleData.image_url !== undefined) {
      updates.push('image_url = ?');
      values.push(articleData.image_url);
    }
    
    if (articleData.category_id !== undefined) {
      updates.push('category_id = ?');
      values.push(articleData.category_id);
    }
    
    if (articleData.published_at !== undefined) {
      updates.push('published_at = ?');
      values.push(articleData.published_at);
    }
    
    if (articleData.is_active !== undefined) {
      updates.push('is_active = ?');
      values.push(articleData.is_active);
    }
    
    if (updates.length === 0) {
      return this.findById(id);
    }
    
    values.push(id);
    
    await pool.query(`UPDATE articles SET ${updates.join(', ')} WHERE id = ?`, values);
    return this.findById(id);
  }
  
  static async delete(id) {
    const [result] = await pool.query('DELETE FROM articles WHERE id = ?', [id]);
    return result.affectedRows > 0;
  }
  
  static async incrementViewCount(id) {
    await pool.query('UPDATE articles SET view_count = view_count + 1 WHERE id = ?', [id]);
    return this.findById(id);
  }
}

module.exports = Article;
