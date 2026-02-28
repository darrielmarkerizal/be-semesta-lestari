const GalleryItem = require('../models/GalleryItem');
const { successResponse, errorResponse, paginatedResponse } = require('../utils/response');

/**
 * @swagger
 * /api/gallery:
 *   get:
 *     summary: Get all gallery items (public)
 *     description: Get paginated gallery items with optional category filtering
 *     tags:
 *       - Gallery
 *     parameters:
 *       - name: category
 *         in: query
 *         description: Filter by category slug (optional)
 *         schema:
 *           type: string
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
 *         description: Gallery items retrieved successfully
 */
const getAllGallery = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const categorySlug = req.query.category || null;
    
    const { data, total } = await GalleryItem.findAllPaginated(page, limit, true, categorySlug);
    return paginatedResponse(res, data, page, limit, total, 'Gallery items retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/gallery/{id}:
 *   get:
 *     summary: Get single gallery item by ID
 *     tags:
 *       - Gallery
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Gallery item retrieved successfully
 */
const getGalleryById = async (req, res, next) => {
  try {
    const item = await GalleryItem.findById(req.params.id);
    
    if (!item) {
      return errorResponse(res, 'Gallery item not found', 404);
    }
    
    return successResponse(res, item, 'Gallery item retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/gallery:
 *   get:
 *     summary: Get all gallery items (admin)
 *     description: Get all gallery items including inactive ones with search and category filtering (admin only)
 *     tags:
 *       - Admin - Gallery
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: search
 *         in: query
 *         description: Search in title and category name (optional)
 *         schema:
 *           type: string
 *           example: tree planting
 *       - name: category
 *         in: query
 *         description: Filter by category slug (optional)
 *         schema:
 *           type: string
 *           example: events
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
 *     responses:
 *       200:
 *         description: Gallery items retrieved successfully
 *   post:
 *     summary: Create new gallery item
 *     tags:
 *       - Admin - Gallery
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
 *               - image_url
 *               - gallery_date
 *             properties:
 *               title:
 *                 type: string
 *               image_url:
 *                 type: string
 *               category_id:
 *                 type: integer
 *               gallery_date:
 *                 type: string
 *                 format: date
 *               order_position:
 *                 type: integer
 *               is_active:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: Gallery item created successfully
 */
const getAllGalleryAdmin = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const categorySlug = req.query.category || null;
    const search = req.query.search || null;
    
    const { data, total } = await GalleryItem.findAllPaginated(page, limit, null, categorySlug, search);
    return paginatedResponse(res, data, page, limit, total, 'Gallery items retrieved');
  } catch (error) {
    next(error);
  }
};

const getGalleryByIdAdmin = async (req, res, next) => {
  try {
    const item = await GalleryItem.findById(req.params.id);
    
    if (!item) {
      return errorResponse(res, 'Gallery item not found', 404);
    }
    
    return successResponse(res, item, 'Gallery item retrieved');
  } catch (error) {
    next(error);
  }
};

const createGallery = async (req, res, next) => {
  try {
    const item = await GalleryItem.create(req.body);
    return successResponse(res, item, 'Gallery item created successfully', 201);
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/gallery/{id}:
 *   put:
 *     summary: Update gallery item
 *     tags:
 *       - Admin - Gallery
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
 *               image_url:
 *                 type: string
 *               category_id:
 *                 type: integer
 *               gallery_date:
 *                 type: string
 *                 format: date
 *               order_position:
 *                 type: integer
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Gallery item updated successfully
 *   delete:
 *     summary: Delete gallery item
 *     tags:
 *       - Admin - Gallery
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
 *         description: Gallery item deleted successfully
 */
const updateGallery = async (req, res, next) => {
  try {
    const item = await GalleryItem.update(req.params.id, req.body);
    
    if (!item) {
      return errorResponse(res, 'Gallery item not found', 404);
    }
    
    return successResponse(res, item, 'Gallery item updated successfully');
  } catch (error) {
    next(error);
  }
};

const deleteGallery = async (req, res, next) => {
  try {
    const deleted = await GalleryItem.delete(req.params.id);
    
    if (!deleted) {
      return errorResponse(res, 'Gallery item not found', 404);
    }
    
    return successResponse(res, null, 'Gallery item deleted successfully');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllPaginated: getAllGallery,
  getById: getGalleryById,
  getAllAdmin: getAllGalleryAdmin,
  getByIdAdmin: getGalleryByIdAdmin,
  create: createGallery,
  update: updateGallery,
  delete: deleteGallery
};
