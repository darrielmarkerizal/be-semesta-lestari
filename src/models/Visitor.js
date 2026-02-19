const { pool } = require('../config/database');

class Visitor {
  /**
   * Track a visitor by IP address
   * If the IP visited today already, increment visit_count
   * Otherwise, create a new record
   */
  static async trackVisit(ipAddress, userAgent = null) {
    const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
    
    try {
      await pool.query(
        `INSERT INTO visitors (ip_address, user_agent, visited_date, visit_count) 
         VALUES (?, ?, ?, 1)
         ON DUPLICATE KEY UPDATE 
         visit_count = visit_count + 1,
         updated_at = CURRENT_TIMESTAMP`,
        [ipAddress, userAgent, today]
      );
      return true;
    } catch (error) {
      console.error('Error tracking visitor:', error);
      return false;
    }
  }

  /**
   * Get visitor count by day for the last N days
   */
  static async getVisitorsByDay(days = 7) {
    const [rows] = await pool.query(
      `SELECT 
        DATE_FORMAT(visited_date, '%Y-%m-%d') as date,
        COUNT(DISTINCT ip_address) as count
       FROM visitors
       WHERE visited_date >= DATE_SUB(CURDATE(), INTERVAL ? DAY)
       GROUP BY visited_date
       ORDER BY visited_date ASC`,
      [days]
    );
    return rows;
  }

  /**
   * Get total unique visitors for a date range
   */
  static async getTotalVisitors(days = 7) {
    const [rows] = await pool.query(
      `SELECT COUNT(DISTINCT ip_address) as total
       FROM visitors
       WHERE visited_date >= DATE_SUB(CURDATE(), INTERVAL ? DAY)`,
      [days]
    );
    return rows[0].total;
  }

  /**
   * Get visitor statistics
   */
  static async getStatistics() {
    const [stats] = await pool.query(
      `SELECT 
        COUNT(DISTINCT ip_address) as total_unique_visitors,
        COUNT(*) as total_visits,
        MAX(visited_date) as last_visit_date
       FROM visitors`
    );
    return stats[0];
  }
}

module.exports = Visitor;
