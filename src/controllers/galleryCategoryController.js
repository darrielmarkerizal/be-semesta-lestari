const GalleryCategory = require('../models/GalleryCategory');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * @swagger
 * /api/gallery-categories:
 *   get:
 *     summary: Get all gallery categories
 *     description: Get all active gallery categories
 *     tags:
 *       - Gallery Categories
 *     responses:
 *       200:
 *         description: Gallery categories retrieved successfully
 */
const getAllCategories = async (req, res, next) => {
  try {
    const categories = await GalleryCategory.findAll(true);
    return successResponse(res, categories, 'Gallery categories retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/gallery-categories/{slug}:
 *   get:
 *     summary: Get gallery category by slug
 *     tags:
 *       - Gallery Categories
 *     parameters:
 *       - name: slug
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Gallery category retrieved successfully
 */
const getCategoryBySlug = async (req, res, next) => {
  try {
    const category = await GalleryCategory.findBySlug(req.params.slug);
    if (!category) return errorResponse(res, 'Gallery category not found', 404);
    return successResponse(res, category, 'Gallery category retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/gallery-categories:
 *   get:
 *     summary: Get all gallery categories (admin)
 *     tags:
 *       - Admin - Gallery Categories
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Gallery categories retrieved successfully
 *   post:
 *     summary: Create new gallery category
 *     tags:
 *       - Admin - Gallery Categories
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
 *               - slug
 *             properties:
 *               name:
 *                 type: string
 *               slug:
 *                 type: string
 *               description:
 *                 type: string
 *               is_active:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: Gallery category created successfully
 */
const getAllCategoriesAdmin = async (req, res, next) => {
  try {
    const categories = await GalleryCategory.findAll();
    return successResponse(res, categories, 'Gallery categories retrieved');
  } catch (error) {
    next(error);
  }
};

const getCategoryByIdAdmin = async (req, res, next) => {
  try {
    const category = await GalleryCategory.findById(req.params.id);
    if (!category) return errorResponse(res, 'Gallery category not found', 404);
    return successResponse(res, category, 'Gallery category retrieved');
  } catch (error) {
    next(error);
  }
};

const createCategory = async (req, res, next) => {
  try {
    const category = await GalleryCategory.create(req.body);
    return successResponse(res, category, 'Gallery category created successfully', 201);
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/gallery-categories/{id}:
 *   put:
 *     summary: Update gallery category
 *     tags:
 *       - Admin - Gallery Categories
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
 *               slug:
 *                 type: string
 *               description:
 *                 type: string
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Gallery category updated successfully
 *   delete:
 *     summary: Delete gallery category
 *     description: Cannot delete if category has related gallery items
 *     tags:
 *       - Admin - Gallery Categories
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
 *         description: Gallery category deleted successfully
 *       400:
 *         description: Cannot delete category with related gallery items
 */
const updateCategory = async (req, res, next) => {
  try {
    const category = await GalleryCategory.update(req.params.id, req.body);
    if (!category) return errorResponse(res, 'Gallery category not found', 404);
    return successResponse(res, category, 'Gallery category updated successfully');
  } catch (error) {
    next(error);
  }
};

const deleteCategory = async (req, res, next) => {
  try {
    // Check if category has related gallery items
    const hasGalleryItems = await GalleryCategory.hasRelatedGalleryItems(req.params.id);
    
    if (hasGalleryItems) {
      return errorResponse(res, 'Cannot delete gallery category with related gallery items. Please reassign or delete the gallery items first.', 400);
    }
    
    const deleted = await GalleryCategory.delete(req.params.id);
    if (!deleted) return errorResponse(res, 'Gallery category not found', 404);
    return successResponse(res, null, 'Gallery category deleted successfully');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAll: getAllCategories,
  getBySlug: getCategoryBySlug,
  getAllAdmin: getAllCategoriesAdmin,
  getByIdAdmin: getCategoryByIdAdmin,
  create: createCategory,
  update: updateCategory,
  delete: deleteCategory
};
