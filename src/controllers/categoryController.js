const Category = require('../models/Category');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * @swagger
 * /api/categories:
 *   get:
 *     summary: Get all active categories
 *     description: Retrieve all active categories for public use
 *     tags:
 *       - Categories
 *     responses:
 *       200:
 *         description: Categories retrieved successfully
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
 *                   example: Categories retrieved
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Category'
 */
const getAllCategories = async (req, res, next) => {
  try {
    const categories = await Category.findAll(true);
    return successResponse(res, categories, 'Categories retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/categories/{slug}:
 *   get:
 *     summary: Get category by slug
 *     description: Retrieve a single active category by its slug
 *     tags:
 *       - Categories
 *     parameters:
 *       - name: slug
 *         in: path
 *         required: true
 *         description: Category slug
 *         schema:
 *           type: string
 *           example: environmental-conservation
 *     responses:
 *       200:
 *         description: Category retrieved successfully
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
 *                   example: Category retrieved
 *                 data:
 *                   $ref: '#/components/schemas/Category'
 *       404:
 *         description: Category not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
const getCategoryBySlug = async (req, res, next) => {
  try {
    const category = await Category.findBySlug(req.params.slug);
    if (!category) return errorResponse(res, 'Category not found', 404);
    return successResponse(res, category, 'Category retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/categories:
 *   get:
 *     summary: Get all categories (admin)
 *     description: Retrieve all categories including inactive ones (admin only)
 *     tags:
 *       - Admin - Categories
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Categories retrieved successfully
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
 *                   example: Categories retrieved
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Category'
 *       401:
 *         description: Unauthorized - Invalid or missing token
 *   post:
 *     summary: Create new category
 *     description: Create a new category (admin only)
 *     tags:
 *       - Admin - Categories
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
 *                 example: Environmental Conservation
 *               slug:
 *                 type: string
 *                 example: environmental-conservation
 *               description:
 *                 type: string
 *                 example: Articles about environmental conservation efforts
 *               is_active:
 *                 type: boolean
 *                 default: true
 *     responses:
 *       201:
 *         description: Category created successfully
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
 *                   example: Category created successfully
 *                 data:
 *                   $ref: '#/components/schemas/Category'
 *       401:
 *         description: Unauthorized - Invalid or missing token
 */
const getAllCategoriesAdmin = async (req, res, next) => {
  try {
    const categories = await Category.findAll();
    return successResponse(res, categories, 'Categories retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/categories/{id}:
 *   get:
 *     summary: Get category by ID (admin)
 *     description: Retrieve a single category by ID (admin only)
 *     tags:
 *       - Admin - Categories
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: Category ID
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       200:
 *         description: Category retrieved successfully
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
 *                   example: Category retrieved
 *                 data:
 *                   $ref: '#/components/schemas/Category'
 *       404:
 *         description: Category not found
 *       401:
 *         description: Unauthorized - Invalid or missing token
 */
const getCategoryByIdAdmin = async (req, res, next) => {
  try {
    const category = await Category.findById(req.params.id);
    if (!category) return errorResponse(res, 'Category not found', 404);
    return successResponse(res, category, 'Category retrieved');
  } catch (error) {
    next(error);
  }
};

const createCategory = async (req, res, next) => {
  try {
    const category = await Category.create(req.body);
    return successResponse(res, category, 'Category created successfully', 201);
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/categories/{id}:
 *   put:
 *     summary: Update category
 *     description: Update an existing category (admin only)
 *     tags:
 *       - Admin - Categories
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: Category ID
 *         schema:
 *           type: integer
 *           example: 1
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: Environmental Conservation
 *               slug:
 *                 type: string
 *                 example: environmental-conservation
 *               description:
 *                 type: string
 *                 example: Updated description for environmental conservation
 *               is_active:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       200:
 *         description: Category updated successfully
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
 *                   example: Category updated successfully
 *                 data:
 *                   $ref: '#/components/schemas/Category'
 *       404:
 *         description: Category not found
 *       401:
 *         description: Unauthorized - Invalid or missing token
 *   delete:
 *     summary: Delete category
 *     description: Delete a category. Cannot delete if category has related articles. (admin only)
 *     tags:
 *       - Admin - Categories
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: Category ID
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       200:
 *         description: Category deleted successfully
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
 *                   example: Category deleted successfully
 *                 data:
 *                   type: null
 *       400:
 *         description: Cannot delete category with related articles
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: false
 *                 message:
 *                   type: string
 *                   example: Cannot delete category with related articles. Please reassign or delete the articles first.
 *       404:
 *         description: Category not found
 *       401:
 *         description: Unauthorized - Invalid or missing token
 */
const updateCategory = async (req, res, next) => {
  try {
    const category = await Category.update(req.params.id, req.body);
    if (!category) return errorResponse(res, 'Category not found', 404);
    return successResponse(res, category, 'Category updated successfully');
  } catch (error) {
    next(error);
  }
};

const deleteCategory = async (req, res, next) => {
  try {
    // Check if category has related articles
    const hasArticles = await Category.hasRelatedArticles(req.params.id);
    
    if (hasArticles) {
      return errorResponse(res, 'Cannot delete category with related articles. Please reassign or delete the articles first.', 400);
    }
    
    const deleted = await Category.delete(req.params.id);
    if (!deleted) return errorResponse(res, 'Category not found', 404);
    return successResponse(res, null, 'Category deleted successfully');
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
