const Award = require('../models/Award');
const { successResponse, errorResponse, paginatedResponse } = require('../utils/response');

/**
 * @swagger
 * /api/awards:
 *   get:
 *     summary: Get all awards (public)
 *     description: Get paginated list of active awards with image, year, title, issuer, and short description
 *     tags:
 *       - Awards
 *     parameters:
 *       - name: page
 *         in: query
 *         schema:
 *           type: integer
 *           default: 1
 *       - name: limit
 *         in: query
 *         schema:
 *           type: integer
 *           default: 10
 *     responses:
 *       200:
 *         description: Awards retrieved successfully
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
 *                   example: Awards retrieved
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       title:
 *                         type: string
 *                       short_description:
 *                         type: string
 *                       image_url:
 *                         type: string
 *                       year:
 *                         type: integer
 *                       issuer:
 *                         type: string
 *                       order_position:
 *                         type: integer
 *                       is_active:
 *                         type: boolean
 *                 pagination:
 *                   $ref: '#/components/schemas/Pagination'
 */
const getAllAwards = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    
    const { data, total } = await Award.findAllPaginated(page, limit, true);
    return paginatedResponse(res, data, page, limit, total, 'Awards retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/awards/{id}:
 *   get:
 *     summary: Get single award by ID
 *     description: Get detailed information about a specific award
 *     tags:
 *       - Awards
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Award retrieved successfully
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
 *                   example: Award retrieved
 *                 data:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                     title:
 *                       type: string
 *                     short_description:
 *                       type: string
 *                     image_url:
 *                       type: string
 *                     year:
 *                       type: integer
 *                     issuer:
 *                       type: string
 *                     order_position:
 *                       type: integer
 *                     is_active:
 *                       type: boolean
 *       404:
 *         description: Award not found
 */
const getAwardById = async (req, res, next) => {
  try {
    const award = await Award.findById(req.params.id);
    
    if (!award) {
      return errorResponse(res, 'Award not found', 404);
    }
    
    return successResponse(res, award, 'Award retrieved');
  } catch (error) {
    next(error);
  }
};

// Admin endpoints

/**
 * @swagger
 * /api/admin/awards:
 *   get:
 *     summary: Get all awards (admin)
 *     description: Get all awards including inactive ones (admin only)
 *     tags:
 *       - Admin - Awards
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: page
 *         in: query
 *         schema:
 *           type: integer
 *           default: 1
 *       - name: limit
 *         in: query
 *         schema:
 *           type: integer
 *           default: 10
 *     responses:
 *       200:
 *         description: Awards retrieved successfully
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
 *                       title:
 *                         type: string
 *                       short_description:
 *                         type: string
 *                       image_url:
 *                         type: string
 *                       year:
 *                         type: integer
 *                       issuer:
 *                         type: string
 *                       order_position:
 *                         type: integer
 *                       is_active:
 *                         type: boolean
 *                 pagination:
 *                   $ref: '#/components/schemas/Pagination'
 *       401:
 *         description: Unauthorized
 */
const getAllAwardsAdmin = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    
    const { data, total } = await Award.findAllPaginated(page, limit, null);
    return paginatedResponse(res, data, page, limit, total, 'Awards retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/awards/{id}:
 *   get:
 *     summary: Get single award by ID (admin)
 *     description: Get detailed award information (admin only)
 *     tags:
 *       - Admin - Awards
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
 *         description: Award retrieved successfully
 *       404:
 *         description: Award not found
 *       401:
 *         description: Unauthorized
 */
const getAwardByIdAdmin = async (req, res, next) => {
  try {
    const award = await Award.findById(req.params.id);
    
    if (!award) {
      return errorResponse(res, 'Award not found', 404);
    }
    
    return successResponse(res, award, 'Award retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/awards:
 *   post:
 *     summary: Create new award
 *     description: Create a new award entry (admin only)
 *     tags:
 *       - Admin - Awards
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - title
 *               - year
 *               - issuer
 *             properties:
 *               title:
 *                 type: string
 *                 example: Green Innovation Award 2024
 *               short_description:
 *                 type: string
 *                 example: Recognized for outstanding innovation in sustainable waste management
 *               image_url:
 *                 type: string
 *                 example: https://example.com/award.jpg
 *               year:
 *                 type: integer
 *                 example: 2024
 *               issuer:
 *                 type: string
 *                 example: Ministry of Environment and Forestry
 *               order_position:
 *                 type: integer
 *                 example: 1
 *               is_active:
 *                 type: boolean
 *                 default: true
 *     responses:
 *       201:
 *         description: Award created successfully
 *       401:
 *         description: Unauthorized
 */
const createAward = async (req, res, next) => {
  try {
    const award = await Award.create(req.body);
    return successResponse(res, award, 'Award created successfully', 201);
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/awards/{id}:
 *   put:
 *     summary: Update award
 *     description: Update an existing award (admin only)
 *     tags:
 *       - Admin - Awards
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *                 example: Green Innovation Award 2024
 *               short_description:
 *                 type: string
 *                 example: Updated description
 *               image_url:
 *                 type: string
 *                 example: https://example.com/award.jpg
 *               year:
 *                 type: integer
 *                 example: 2024
 *               issuer:
 *                 type: string
 *                 example: Ministry of Environment and Forestry
 *               order_position:
 *                 type: integer
 *                 example: 1
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Award updated successfully
 *       404:
 *         description: Award not found
 *       401:
 *         description: Unauthorized
 *   delete:
 *     summary: Delete award
 *     description: Delete an award permanently (admin only)
 *     tags:
 *       - Admin - Awards
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
 *         description: Award deleted successfully
 *       404:
 *         description: Award not found
 *       401:
 *         description: Unauthorized
 */
const updateAward = async (req, res, next) => {
  try {
    const award = await Award.update(req.params.id, req.body);
    
    if (!award) {
      return errorResponse(res, 'Award not found', 404);
    }
    
    return successResponse(res, award, 'Award updated successfully');
  } catch (error) {
    next(error);
  }
};

const deleteAward = async (req, res, next) => {
  try {
    const deleted = await Award.delete(req.params.id);
    
    if (!deleted) {
      return errorResponse(res, 'Award not found', 404);
    }
    
    return successResponse(res, null, 'Award deleted successfully');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllPaginated: getAllAwards,
  getById: getAwardById,
  getAllAdmin: getAllAwardsAdmin,
  getByIdAdmin: getAwardByIdAdmin,
  create: createAward,
  update: updateAward,
  delete: deleteAward
};
