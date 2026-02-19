const { pool } = require('../config/database');
const ContactMessage = require('../models/ContactMessage');
const { successResponse } = require('../utils/response');

/**
 * @swagger
 * /api/admin/dashboard:
 *   get:
 *     summary: Get dashboard statistics
 *     tags:
 *       - Admin - Dashboard
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Dashboard stats retrieved
 */
const getDashboardStats = async (req, res, next) => {
  try {
    const [
      articlesCount,
      awardsCount,
      merchandiseCount,
      galleryCount,
      unreadMessages
    ] = await Promise.all([
      pool.query('SELECT COUNT(*) as count FROM articles WHERE is_active = true'),
      pool.query('SELECT COUNT(*) as count FROM awards WHERE is_active = true'),
      pool.query('SELECT COUNT(*) as count FROM merchandise WHERE is_active = true'),
      pool.query('SELECT COUNT(*) as count FROM gallery_items WHERE is_active = true'),
      ContactMessage.getUnreadCount()
    ]);
    
    return successResponse(res, {
      articles: articlesCount[0][0].count,
      awards: awardsCount[0][0].count,
      merchandise: merchandiseCount[0][0].count,
      gallery: galleryCount[0][0].count,
      unreadMessages
    }, 'Dashboard stats retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/dashboard/stats:
 *   get:
 *     summary: Get detailed statistics
 *     tags:
 *       - Admin - Dashboard
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Detailed stats retrieved
 */
const getDetailedStats = async (req, res, next) => {
  try {
    const [
      totalArticles,
      totalViews,
      recentArticles,
      recentMessages
    ] = await Promise.all([
      pool.query('SELECT COUNT(*) as count FROM articles'),
      pool.query('SELECT SUM(view_count) as total FROM articles'),
      pool.query('SELECT id, title, view_count, created_at FROM articles ORDER BY created_at DESC LIMIT 5'),
      pool.query('SELECT id, name, email, subject, created_at FROM contact_messages ORDER BY created_at DESC LIMIT 5')
    ]);
    
    return successResponse(res, {
      totalArticles: totalArticles[0][0].count,
      totalViews: totalViews[0][0].total || 0,
      recentArticles: recentArticles[0],
      recentMessages: recentMessages[0]
    }, 'Detailed stats retrieved');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getDashboardStats,
  getDetailedStats
};
