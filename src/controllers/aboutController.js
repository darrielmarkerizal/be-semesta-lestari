const History = require('../models/History');
const HistorySection = require('../models/HistorySection');
const Vision = require('../models/Vision');
const Mission = require('../models/Mission');
const Leadership = require('../models/Leadership');
const LeadershipSection = require('../models/LeadershipSection');
const { successResponse } = require('../utils/response');

/**
 * @swagger
 * /api/about/history:
 *   get:
 *     summary: Get history section with header and items
 *     description: Returns history section settings (title, subtitle, image) and all history items
 *     tags:
 *       - About
 *     responses:
 *       200:
 *         description: History section retrieved successfully
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
 *                   example: History section retrieved
 *                 data:
 *                   type: object
 *                   properties:
 *                     section:
 *                       type: object
 *                       properties:
 *                         id:
 *                           type: integer
 *                         title:
 *                           type: string
 *                           example: Our History
 *                         subtitle:
 *                           type: string
 *                           example: The journey of environmental conservation
 *                         image_url:
 *                           type: string
 *                           nullable: true
 *                           example: /uploads/history/hero.jpg
 *                         is_active:
 *                           type: boolean
 *                     items:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: integer
 *                           year:
 *                             type: integer
 *                             example: 2024
 *                           title:
 *                             type: string
 *                           content:
 *                             type: string
 *                           image_url:
 *                             type: string
 *                           order_position:
 *                             type: integer
 *                           is_active:
 *                             type: boolean
 */
const getHistory = async (req, res, next) => {
  try {
    const [historySettings, historyItems] = await Promise.all([
      HistorySection.findAll(true, 'created_at DESC'),
      History.findAll(true, 'year ASC, order_position ASC')
    ]);
    
    const response = {
      section: historySettings[0] || null,
      items: historyItems
    };
    
    return successResponse(res, response, 'History section retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/about/vision:
 *   get:
 *     summary: Get about vision
 *     tags:
 *       - About
 *     responses:
 *       200:
 *         description: Vision retrieved
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 data:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                     title:
 *                       type: string
 *                     description:
 *                       type: string
 *                     icon_url:
 *                       type: string
 */
const getVision = async (req, res, next) => {
  try {
    const vision = await Vision.getFirst();
    return successResponse(res, vision, 'Vision retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/about/missions:
 *   get:
 *     summary: Get about missions
 *     tags:
 *       - About
 *     responses:
 *       200:
 *         description: Missions retrieved
 */
const getMissions = async (req, res, next) => {
  try {
    const missions = await Mission.findAll(true);
    return successResponse(res, missions, 'Missions retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/about/leadership:
 *   get:
 *     summary: Get leadership section with header and items
 *     description: Returns leadership section settings (title, subtitle, image) and all leadership members
 *     tags:
 *       - About
 *     responses:
 *       200:
 *         description: Leadership section retrieved successfully
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
 *                   example: Leadership section retrieved
 *                 data:
 *                   type: object
 *                   properties:
 *                     section:
 *                       type: object
 *                       properties:
 *                         id:
 *                           type: integer
 *                         title:
 *                           type: string
 *                           example: Our Leadership
 *                         subtitle:
 *                           type: string
 *                           example: Meet the team driving environmental change
 *                         image_url:
 *                           type: string
 *                           nullable: true
 *                           example: /uploads/leadership/hero.jpg
 *                         is_active:
 *                           type: boolean
 *                     items:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: integer
 *                           name:
 *                             type: string
 *                           position:
 *                             type: string
 *                           bio:
 *                             type: string
 *                           image_url:
 *                             type: string
 *                           email:
 *                             type: string
 *                           phone:
 *                             type: string
 *                           linkedin_link:
 *                             type: string
 *                           instagram_link:
 *                             type: string
 *                           is_highlighted:
 *                             type: boolean
 *                           order_position:
 *                             type: integer
 *                           is_active:
 *                             type: boolean
 */
const getLeadership = async (req, res, next) => {
  try {
    const [leadershipSettings, leadershipItems] = await Promise.all([
      LeadershipSection.findAll(true, 'created_at DESC'),
      Leadership.findAll(true)
    ]);
    
    const response = {
      section: leadershipSettings[0] || null,
      items: leadershipItems
    };
    
    return successResponse(res, response, 'Leadership section retrieved');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getHistory,
  getVision,
  getMissions,
  getLeadership
};
