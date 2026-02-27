const Partner = require('../models/Partner');
const HomePartnersSection = require('../models/HomePartnersSection');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * @swagger
 * /api/partners:
 *   get:
 *     summary: Get partners section with header and items
 *     description: Returns partners section settings (title, subtitle, image) and all partner items
 *     tags:
 *       - Partners
 *     responses:
 *       200:
 *         description: Partners section retrieved successfully
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
 *                   example: Partners section retrieved
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
 *                           example: Our Partners
 *                         subtitle:
 *                           type: string
 *                           example: Working together for a sustainable future
 *                         image_url:
 *                           type: string
 *                           nullable: true
 *                           example: /uploads/partners/hero.jpg
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
 *                           description:
 *                             type: string
 *                           logo_url:
 *                             type: string
 *                           website:
 *                             type: string
 *                           order_position:
 *                             type: integer
 *                           is_active:
 *                             type: boolean
 */
const getAllPartners = async (req, res, next) => {
  try {
    const [partnersSettings, partnerItems] = await Promise.all([
      HomePartnersSection.findAll(true, 'created_at DESC'),
      Partner.findAll(true)
    ]);
    
    const response = {
      section: partnersSettings[0] || null,
      items: partnerItems
    };
    
    return successResponse(res, response, 'Partners section retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/partners/{id}:
 *   get:
 *     summary: Get single partner by ID
 *     tags:
 *       - Partners
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Partner retrieved successfully
 */
const getPartnerById = async (req, res, next) => {
  try {
    const item = await Partner.findById(req.params.id);
    if (!item) return errorResponse(res, 'Partner not found', 404);
    return successResponse(res, item, 'Partner retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/partners:
 *   get:
 *     summary: Get all partners (admin)
 *     tags:
 *       - Admin - Partners
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Partners retrieved successfully
 *   post:
 *     summary: Create new partner
 *     tags:
 *       - Admin - Partners
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *             properties:
 *               name:
 *                 type: string
 *               description:
 *                 type: string
 *               logo_url:
 *                 type: string
 *               website:
 *                 type: string
 *               order_position:
 *                 type: integer
 *               is_active:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: Partner created successfully
 */
const getAllPartnersAdmin = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const { data, total } = await Partner.findAllPaginated(page, limit, null);
    return require('../utils/response').paginatedResponse(res, data, page, limit, total, 'Partner retrieved');
  } catch (error) {
    next(error);
  }
};

const getPartnerByIdAdmin = async (req, res, next) => {
  try {
    const item = await Partner.findById(req.params.id);
    if (!item) return errorResponse(res, 'Partner not found', 404);
    return successResponse(res, item, 'Partner retrieved');
  } catch (error) {
    next(error);
  }
};

const createPartner = async (req, res, next) => {
  try {
    const item = await Partner.create(req.body);
    return successResponse(res, item, 'Partner created successfully', 201);
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/partners/{id}:
 *   put:
 *     summary: Update partner
 *     tags:
 *       - Admin - Partners
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               description:
 *                 type: string
 *               logo_url:
 *                 type: string
 *               website:
 *                 type: string
 *               order_position:
 *                 type: integer
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Partner updated successfully
 *   delete:
 *     summary: Delete partner
 *     tags:
 *       - Admin - Partners
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Partner deleted successfully
 */
const updatePartner = async (req, res, next) => {
  try {
    const item = await Partner.update(req.params.id, req.body);
    if (!item) return errorResponse(res, 'Partner not found', 404);
    return successResponse(res, item, 'Partner updated successfully');
  } catch (error) {
    next(error);
  }
};

const deletePartner = async (req, res, next) => {
  try {
    const deleted = await Partner.delete(req.params.id);
    if (!deleted) return errorResponse(res, 'Partner not found', 404);
    return successResponse(res, null, 'Partner deleted successfully');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAll: getAllPartners,
  getById: getPartnerById,
  getAllAdmin: getAllPartnersAdmin,
  getByIdAdmin: getPartnerByIdAdmin,
  create: createPartner,
  update: updatePartner,
  delete: deletePartner
};
