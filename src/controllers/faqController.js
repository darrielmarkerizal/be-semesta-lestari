const FAQ = require('../models/FAQ');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * @swagger
 * /api/faqs:
 *   get:
 *     summary: Get all FAQs
 *     tags:
 *       - FAQs
 *     responses:
 *       200:
 *         description: FAQs retrieved successfully
 */
const getAllFAQs = async (req, res, next) => {
  try {
    const data = await FAQ.findAll(true);
    return successResponse(res, data, 'FAQ retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/faqs/{id}:
 *   get:
 *     summary: Get single FAQ by ID
 *     tags:
 *       - FAQs
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: FAQ retrieved successfully
 */
const getFAQById = async (req, res, next) => {
  try {
    const item = await FAQ.findById(req.params.id);
    if (!item) return errorResponse(res, 'FAQ not found', 404);
    return successResponse(res, item, 'FAQ retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/faqs:
 *   get:
 *     summary: Get all FAQs (admin)
 *     tags:
 *       - Admin - FAQs
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: FAQs retrieved successfully
 *   post:
 *     summary: Create new FAQ
 *     tags:
 *       - Admin - FAQs
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - question
 *               - answer
 *             properties:
 *               question:
 *                 type: string
 *               answer:
 *                 type: string
 *               category:
 *                 type: string
 *               order_position:
 *                 type: integer
 *               is_active:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: FAQ created successfully
 */
const getAllFAQsAdmin = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const { data, total } = await FAQ.findAllPaginated(page, limit, null);
    return require('../utils/response').paginatedResponse(res, data, page, limit, total, 'FAQ retrieved');
  } catch (error) {
    next(error);
  }
};

const getFAQByIdAdmin = async (req, res, next) => {
  try {
    const item = await FAQ.findById(req.params.id);
    if (!item) return errorResponse(res, 'FAQ not found', 404);
    return successResponse(res, item, 'FAQ retrieved');
  } catch (error) {
    next(error);
  }
};

const createFAQ = async (req, res, next) => {
  try {
    const item = await FAQ.create(req.body);
    return successResponse(res, item, 'FAQ created successfully', 201);
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/faqs/{id}:
 *   put:
 *     summary: Update FAQ
 *     tags:
 *       - Admin - FAQs
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
 *               question:
 *                 type: string
 *               answer:
 *                 type: string
 *               category:
 *                 type: string
 *               order_position:
 *                 type: integer
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: FAQ updated successfully
 *   delete:
 *     summary: Delete FAQ
 *     tags:
 *       - Admin - FAQs
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
 *         description: FAQ deleted successfully
 */
const updateFAQ = async (req, res, next) => {
  try {
    const item = await FAQ.update(req.params.id, req.body);
    if (!item) return errorResponse(res, 'FAQ not found', 404);
    return successResponse(res, item, 'FAQ updated successfully');
  } catch (error) {
    next(error);
  }
};

const deleteFAQ = async (req, res, next) => {
  try {
    const deleted = await FAQ.delete(req.params.id);
    if (!deleted) return errorResponse(res, 'FAQ not found', 404);
    return successResponse(res, null, 'FAQ deleted successfully');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAll: getAllFAQs,
  getById: getFAQById,
  getAllAdmin: getAllFAQsAdmin,
  getByIdAdmin: getFAQByIdAdmin,
  create: createFAQ,
  update: updateFAQ,
  delete: deleteFAQ
};
