const History = require('../models/History');
const Vision = require('../models/Vision');
const Mission = require('../models/Mission');
const Leadership = require('../models/Leadership');
const { successResponse } = require('../utils/response');

/**
 * @swagger
 * /api/about/history:
 *   get:
 *     summary: Get history/about content
 *     tags:
 *       - About
 *     responses:
 *       200:
 *         description: History retrieved
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
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       year:
 *                         type: integer
 *                         example: 2024
 *                       title:
 *                         type: string
 *                       content:
 *                         type: string
 *                       image_url:
 *                         type: string
 *                       order_position:
 *                         type: integer
 */
const getHistory = async (req, res, next) => {
  try {
    const history = await History.findAll(true);
    return successResponse(res, history, 'History retrieved');
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
 *     summary: Get leadership/organization
 *     tags:
 *       - About
 *     responses:
 *       200:
 *         description: Leadership retrieved
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
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       name:
 *                         type: string
 *                       position:
 *                         type: string
 *                       bio:
 *                         type: string
 *                       image_url:
 *                         type: string
 *                       email:
 *                         type: string
 *                       phone:
 *                         type: string
 *                       linkedin_link:
 *                         type: string
 *                       instagram_link:
 *                         type: string
 *                       is_highlighted:
 *                         type: boolean
 *                       order_position:
 *                         type: integer
 */
const getLeadership = async (req, res, next) => {
  try {
    const leadership = await Leadership.findAll(true);
    return successResponse(res, leadership, 'Leadership retrieved');
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
