const { pool } = require('../config/database');
const { successResponse } = require('../utils/response');
const Visitor = require('../models/Visitor');

/**
 * @swagger
 * /api/admin/statistics:
 *   get:
 *     summary: Get admin dashboard statistics
 *     description: Returns comprehensive statistics including total article views, counts of programs/gallery/partners, top 5 articles by views, and visitor count by day for last 7 days
 *     tags:
 *       - Admin - Statistics
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Statistics retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: Statistics retrieved successfully
 *                 data:
 *                   type: object
 *                   properties:
 *                     total_article_views:
 *                       type: integer
 *                       description: Sum of all article view counts
 *                       example: 15420
 *                     total_programs:
 *                       type: integer
 *                       description: Total number of programs
 *                       example: 12
 *                     total_gallery:
 *                       type: integer
 *                       description: Total number of gallery items
 *                       example: 48
 *                     total_partners:
 *                       type: integer
 *                       description: Total number of partners
 *                       example: 8
 *                     top_articles:
 *                       type: array
 *                       description: Top 5 articles by view count
 *                       items:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: integer
 *                           title:
 *                             type: string
 *                           slug:
 *                             type: string
 *                           view_count:
 *                             type: integer
 *                           category_name:
 *                             type: string
 *                           published_at:
 *                             type: string
 *                             format: date-time
 *                     visitors_last_7_days:
 *                       type: array
 *                       description: Visitor count by day for the last 7 days
 *                       items:
 *                         type: object
 *                         properties:
 *                           date:
 *                             type: string
 *                             format: date
 *                             example: "2026-02-19"
 *                           count:
 *                             type: integer
 *                             example: 15
 */
const getAdminStatistics = async (req, res, next) => {
  try {
    // Get total article views (sum of all view_count)
    const [totalViewsResult] = await pool.query(
      'SELECT COALESCE(SUM(view_count), 0) as total_views FROM articles WHERE is_active = true'
    );
    const total_article_views = parseInt(totalViewsResult[0].total_views) || 0;

    // Get total programs count
    const [totalProgramsResult] = await pool.query(
      'SELECT COUNT(*) as total FROM programs WHERE is_active = true'
    );
    const total_programs = totalProgramsResult[0].total;

    // Get total gallery items count
    const [totalGalleryResult] = await pool.query(
      'SELECT COUNT(*) as total FROM gallery_items WHERE is_active = true'
    );
    const total_gallery = totalGalleryResult[0].total;

    // Get total partners count
    const [totalPartnersResult] = await pool.query(
      'SELECT COUNT(*) as total FROM partners WHERE is_active = true'
    );
    const total_partners = totalPartnersResult[0].total;

    // Get top 5 articles by views
    const [topArticles] = await pool.query(`
      SELECT 
        a.id,
        a.title,
        a.slug,
        a.view_count,
        a.published_at,
        c.name as category_name
      FROM articles a
      LEFT JOIN categories c ON a.category_id = c.id
      WHERE a.is_active = true
      ORDER BY a.view_count DESC
      LIMIT 5
    `);

    // Get visitors by day for last 7 days from visitors table
    const visitorsByDay = await Visitor.getVisitorsByDay(7);

    // Convert database results to a map for easy lookup
    const visitorsMap = {};
    visitorsByDay.forEach(v => {
      visitorsMap[v.date] = parseInt(v.count);
    });

    // Create array for all 7 days (fill missing days with 0)
    const visitors_last_7_days = [];
    
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      // Format as YYYY-MM-DD in local timezone
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const dateStr = `${year}-${month}-${day}`;
      
      visitors_last_7_days.push({
        date: dateStr,
        count: visitorsMap[dateStr] || 0
      });
    }

    const statistics = {
      total_article_views,
      total_programs,
      total_gallery,
      total_partners,
      top_articles: topArticles,
      visitors_last_7_days
    };

    return successResponse(res, statistics, 'Statistics retrieved successfully');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAdminStatistics
};
