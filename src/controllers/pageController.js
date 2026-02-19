const PageSettings = require('../models/PageSettings');
const { successResponse } = require('../utils/response');

/**
 * @swagger
 * /api/pages/{slug}/info:
 *   get:
 *     summary: Get page hero info by slug
 *     description: Returns page hero section with title, subtitle, and image
 *     tags:
 *       - Pages
 *     parameters:
 *       - name: slug
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *         description: Page slug (articles, awards, merchandise, gallery, programs, partners, contact, about)
 *     responses:
 *       200:
 *         description: Page info retrieved
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
 *                     page_slug:
 *                       type: string
 *                     title:
 *                       type: string
 *                     sub_title:
 *                       type: string
 *                     description:
 *                       type: string
 *                     image_url:
 *                       type: string
 *                     meta_title:
 *                       type: string
 *                     meta_description:
 *                       type: string
 *                     is_active:
 *                       type: boolean
 */
const getPageInfo = async (req, res, next) => {
  try {
    const pageInfo = await PageSettings.findBySlug(req.params.slug);
    return successResponse(res, pageInfo || {}, 'Page info retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/pages/articles:
 *   get:
 *     summary: Get articles page settings
 *     tags:
 *       - Admin - Pages
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Page settings retrieved successfully
 *   put:
 *     summary: Update articles page settings
 *     tags:
 *       - Admin - Pages
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               sub_title:
 *                 type: string
 *               description:
 *                 type: string
 *               image_url:
 *                 type: string
 *               meta_title:
 *                 type: string
 *               meta_description:
 *                 type: string
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Page settings updated successfully
 */
/**
 * @swagger
 * /api/admin/pages/awards:
 *   get:
 *     summary: Get awards page settings
 *     tags:
 *       - Admin - Pages
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Page settings retrieved successfully
 *   put:
 *     summary: Update awards page settings
 *     tags:
 *       - Admin - Pages
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               image_url:
 *                 type: string
 *               meta_title:
 *                 type: string
 *               meta_description:
 *                 type: string
 *     responses:
 *       200:
 *         description: Page settings updated successfully
 */
/**
 * @swagger
 * /api/admin/pages/merchandise:
 *   get:
 *     summary: Get merchandise page settings
 *     tags:
 *       - Admin - Pages
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Page settings retrieved successfully
 *   put:
 *     summary: Update merchandise page settings
 *     tags:
 *       - Admin - Pages
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               image_url:
 *                 type: string
 *               meta_title:
 *                 type: string
 *               meta_description:
 *                 type: string
 *     responses:
 *       200:
 *         description: Page settings updated successfully
 */
/**
 * @swagger
 * /api/admin/pages/gallery:
 *   get:
 *     summary: Get gallery page settings
 *     tags:
 *       - Admin - Pages
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Page settings retrieved successfully
 *   put:
 *     summary: Update gallery page settings
 *     tags:
 *       - Admin - Pages
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               image_url:
 *                 type: string
 *               meta_title:
 *                 type: string
 *               meta_description:
 *                 type: string
 *     responses:
 *       200:
 *         description: Page settings updated successfully
 */
/**
 * @swagger
 * /api/admin/pages/leadership:
 *   get:
 *     summary: Get leadership page settings
 *     tags:
 *       - Admin - Pages
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Page settings retrieved successfully
 *   put:
 *     summary: Update leadership page settings
 *     tags:
 *       - Admin - Pages
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               image_url:
 *                 type: string
 *               meta_title:
 *                 type: string
 *               meta_description:
 *                 type: string
 *     responses:
 *       200:
 *         description: Page settings updated successfully
 */
/**
 * @swagger
 * /api/admin/pages/contact:
 *   get:
 *     summary: Get contact page settings
 *     tags:
 *       - Admin - Pages
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Page settings retrieved successfully
 *   put:
 *     summary: Update contact page settings
 *     tags:
 *       - Admin - Pages
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               image_url:
 *                 type: string
 *               meta_title:
 *                 type: string
 *               meta_description:
 *                 type: string
 *     responses:
 *       200:
 *         description: Page settings updated successfully
 */
// Admin endpoints
const getPageSettings = async (req, res, next) => {
  try {
    const pageInfo = await PageSettings.findBySlug(req.params.slug);
    return successResponse(res, pageInfo || {}, 'Page settings retrieved');
  } catch (error) {
    next(error);
  }
};

const updatePageSettings = async (req, res, next) => {
  try {
    const pageInfo = await PageSettings.upsert(req.params.slug, req.body);
    return successResponse(res, pageInfo, 'Page settings updated successfully');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getPageInfo,
  getPageSettings,
  updatePageSettings
};
