const Merchandise = require('../models/Merchandise');
const { successResponse, errorResponse, paginatedResponse } = require('../utils/response');

/**
 * @swagger
 * /api/merchandise:
 *   get:
 *     summary: Get all merchandise (public)
 *     description: Get paginated list of active merchandise products with image, product_name, price, marketplace, and marketplace_link
 *     tags:
 *       - Merchandise
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
 *         description: Merchandise retrieved successfully
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
 *                   example: Merchandise retrieved
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       product_name:
 *                         type: string
 *                       image_url:
 *                         type: string
 *                       price:
 *                         type: number
 *                       marketplace:
 *                         type: string
 *                       marketplace_link:
 *                         type: string
 *                       order_position:
 *                         type: integer
 *                       is_active:
 *                         type: boolean
 *                 pagination:
 *                   $ref: '#/components/schemas/Pagination'
 */
const getAllMerchandise = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    
    const { data, total } = await Merchandise.findAllPaginated(page, limit, true);
    return paginatedResponse(res, data, page, limit, total, 'Merchandise retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/merchandise/{id}:
 *   get:
 *     summary: Get single merchandise by ID
 *     description: Get detailed information about a specific merchandise product
 *     tags:
 *       - Merchandise
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Merchandise retrieved successfully
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
 *                   example: Merchandise retrieved
 *                 data:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                     product_name:
 *                       type: string
 *                     image_url:
 *                       type: string
 *                     price:
 *                       type: number
 *                     marketplace:
 *                       type: string
 *                     marketplace_link:
 *                       type: string
 *                     order_position:
 *                       type: integer
 *                     is_active:
 *                       type: boolean
 *       404:
 *         description: Merchandise not found
 */
const getMerchandiseById = async (req, res, next) => {
  try {
    const item = await Merchandise.findById(req.params.id);
    
    if (!item) {
      return errorResponse(res, 'Merchandise not found', 404);
    }
    
    return successResponse(res, item, 'Merchandise retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/merchandise:
 *   get:
 *     summary: Get all merchandise (admin)
 *     description: Get all merchandise including inactive ones (admin only)
 *     tags:
 *       - Admin - Merchandise
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
 *         description: Merchandise retrieved successfully
 *       401:
 *         description: Unauthorized
 *   post:
 *     summary: Create new merchandise
 *     description: Create a new merchandise product (admin only)
 *     tags:
 *       - Admin - Merchandise
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - product_name
 *               - price
 *               - marketplace
 *               - marketplace_link
 *             properties:
 *               product_name:
 *                 type: string
 *                 example: Eco-Friendly Tote Bag
 *               image_url:
 *                 type: string
 *                 example: https://example.com/product.jpg
 *               price:
 *                 type: number
 *                 example: 75000
 *               marketplace:
 *                 type: string
 *                 example: Tokopedia
 *               marketplace_link:
 *                 type: string
 *                 example: https://tokopedia.com/product
 *               order_position:
 *                 type: integer
 *                 example: 1
 *               is_active:
 *                 type: boolean
 *                 default: true
 *     responses:
 *       201:
 *         description: Merchandise created successfully
 *       401:
 *         description: Unauthorized
 */
const getAllMerchandiseAdmin = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    
    const { data, total } = await Merchandise.findAllPaginated(page, limit, null);
    return paginatedResponse(res, data, page, limit, total, 'Merchandise retrieved');
  } catch (error) {
    next(error);
  }
};

const getMerchandiseByIdAdmin = async (req, res, next) => {
  try {
    const item = await Merchandise.findById(req.params.id);
    
    if (!item) {
      return errorResponse(res, 'Merchandise not found', 404);
    }
    
    return successResponse(res, item, 'Merchandise retrieved');
  } catch (error) {
    next(error);
  }
};

const createMerchandise = async (req, res, next) => {
  try {
    const item = await Merchandise.create(req.body);
    return successResponse(res, item, 'Merchandise created successfully', 201);
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/merchandise/{id}:
 *   get:
 *     summary: Get single merchandise by ID (admin)
 *     description: Get detailed merchandise information (admin only)
 *     tags:
 *       - Admin - Merchandise
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
 *         description: Merchandise retrieved successfully
 *       404:
 *         description: Merchandise not found
 *       401:
 *         description: Unauthorized
 *   put:
 *     summary: Update merchandise
 *     description: Update an existing merchandise product (admin only)
 *     tags:
 *       - Admin - Merchandise
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
 *               product_name:
 *                 type: string
 *                 example: Updated Product Name
 *               image_url:
 *                 type: string
 *                 example: https://example.com/updated.jpg
 *               price:
 *                 type: number
 *                 example: 85000
 *               marketplace:
 *                 type: string
 *                 example: Shopee
 *               marketplace_link:
 *                 type: string
 *                 example: https://shopee.co.id/product
 *               order_position:
 *                 type: integer
 *                 example: 2
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Merchandise updated successfully
 *       404:
 *         description: Merchandise not found
 *       401:
 *         description: Unauthorized
 *   delete:
 *     summary: Delete merchandise
 *     description: Delete a merchandise product permanently (admin only)
 *     tags:
 *       - Admin - Merchandise
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
 *         description: Merchandise deleted successfully
 *       404:
 *         description: Merchandise not found
 *       401:
 *         description: Unauthorized
 */
const updateMerchandise = async (req, res, next) => {
  try {
    const item = await Merchandise.update(req.params.id, req.body);
    
    if (!item) {
      return errorResponse(res, 'Merchandise not found', 404);
    }
    
    return successResponse(res, item, 'Merchandise updated successfully');
  } catch (error) {
    next(error);
  }
};

const deleteMerchandise = async (req, res, next) => {
  try {
    const deleted = await Merchandise.delete(req.params.id);
    
    if (!deleted) {
      return errorResponse(res, 'Merchandise not found', 404);
    }
    
    return successResponse(res, null, 'Merchandise deleted successfully');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllPaginated: getAllMerchandise,
  getById: getMerchandiseById,
  getAllAdmin: getAllMerchandiseAdmin,
  getByIdAdmin: getMerchandiseByIdAdmin,
  create: createMerchandise,
  update: updateMerchandise,
  delete: deleteMerchandise
};
