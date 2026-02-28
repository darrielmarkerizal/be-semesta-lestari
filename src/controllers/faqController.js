const FAQ = require("../models/FAQ");
const HomeFaqSection = require("../models/HomeFaqSection");
const { successResponse, errorResponse } = require("../utils/response");

/**
 * @swagger
 * /api/faqs:
 *   get:
 *     summary: Get FAQs section with header and items
 *     description: Returns FAQ section settings (title, subtitle, image) and all FAQ items
 *     tags:
 *       - FAQs
 *     responses:
 *       200:
 *         description: FAQs section retrieved successfully
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
 *                   example: FAQs section retrieved
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
 *                           example: Frequently Asked Questions
 *                         subtitle:
 *                           type: string
 *                           example: Find answers to common questions
 *                         image_url:
 *                           type: string
 *                           nullable: true
 *                           example: /uploads/faqs/hero.jpg
 *                         is_active:
 *                           type: boolean
 *                     items:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: integer
 *                           question:
 *                             type: string
 *                           answer:
 *                             type: string
 *                           category:
 *                             type: string
 *                           order_position:
 *                             type: integer
 *                           is_active:
 *                             type: boolean
 */
const getAllFAQs = async (req, res, next) => {
  try {
    const [faqSettings, faqItems] = await Promise.all([
      HomeFaqSection.findAll(true, 'created_at DESC'),
      FAQ.findAll(true)
    ]);
    
    const response = {
      section: faqSettings[0] || null,
      items: faqItems
    };
    
    return successResponse(res, response, "FAQs section retrieved");
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
    if (!item) return errorResponse(res, "FAQ not found", 404);
    return successResponse(res, item, "FAQ retrieved");
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/faqs:
 *   get:
 *     summary: Get all FAQs with pagination and search (admin)
 *     tags:
 *       - Admin - FAQs
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: search
 *         in: query
 *         description: Search in question, answer, and category (optional)
 *         schema:
 *           type: string
 *           example: donation
 *       - name: category
 *         in: query
 *         description: Filter by category (optional)
 *         schema:
 *           type: string
 *           example: General
 *       - name: page
 *         in: query
 *         description: Page number for pagination
 *         schema:
 *           type: integer
 *           default: 1
 *           example: 1
 *       - name: limit
 *         in: query
 *         description: Number of items per page
 *         schema:
 *           type: integer
 *           default: 10
 *           example: 10
 *       - name: all
 *         in: query
 *         description: Return all items without pagination (set to "true")
 *         schema:
 *           type: string
 *           example: "true"
 *     responses:
 *       200:
 *         description: FAQs retrieved successfully
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
 *                 pagination:
 *                   type: object
 *                   properties:
 *                     currentPage:
 *                       type: integer
 *                     totalPages:
 *                       type: integer
 *                     totalItems:
 *                       type: integer
 *                     itemsPerPage:
 *                       type: integer
 *                     hasNextPage:
 *                       type: boolean
 *                     hasPrevPage:
 *                       type: boolean
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
    // If client requests all items, return full list (no pagination)
    if (req.query.all === "true") {
      const data = await FAQ.findAll(null);
      return successResponse(res, data, "FAQs retrieved");
    }

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const search = req.query.search || null;
    const category = req.query.category || null;
    
    const { data, total } = await FAQ.findAllPaginatedWithSearch(page, limit, null, category, search);
    return require("../utils/response").paginatedResponse(
      res,
      data,
      page,
      limit,
      total,
      "FAQs retrieved",
    );
  } catch (error) {
    next(error);
  }
};

const getFAQByIdAdmin = async (req, res, next) => {
  try {
    const item = await FAQ.findById(req.params.id);
    if (!item) return errorResponse(res, "FAQ not found", 404);
    return successResponse(res, item, "FAQ retrieved");
  } catch (error) {
    next(error);
  }
};

const createFAQ = async (req, res, next) => {
  try {
    const item = await FAQ.create(req.body);
    return successResponse(res, item, "FAQ created successfully", 201);
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
    if (!item) return errorResponse(res, "FAQ not found", 404);
    return successResponse(res, item, "FAQ updated successfully");
  } catch (error) {
    next(error);
  }
};

const deleteFAQ = async (req, res, next) => {
  try {
    const deleted = await FAQ.delete(req.params.id);
    if (!deleted) return errorResponse(res, "FAQ not found", 404);
    return successResponse(res, null, "FAQ deleted successfully");
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
  delete: deleteFAQ,
};
