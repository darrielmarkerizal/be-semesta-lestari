const Article = require('../models/Article');
const { successResponse, errorResponse, paginatedResponse } = require('../utils/response');

/**
 * @swagger
 * /api/articles:
 *   get:
 *     summary: Get all articles (public)
 *     description: Get paginated articles with optional category filtering and search. Supports filtering by category ID or slug. All articles include category information (category_id, category_name, category_slug).
 *     tags:
 *       - Articles
 *     parameters:
 *       - name: category
 *         in: query
 *         description: Filter by category ID or slug (optional). Accepts both numeric ID (e.g., 1) or slug (e.g., environmental-conservation).
 *         schema:
 *           type: string
 *           example: 1
 *       - name: search
 *         in: query
 *         description: Search in title, subtitle, content, and excerpt (optional)
 *         schema:
 *           type: string
 *           example: forest conservation
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
 *           example: 9
 *     responses:
 *       200:
 *         description: Articles retrieved successfully with category information
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
 *                   example: Articles retrieved
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Article'
 *                 pagination:
 *                   $ref: '#/components/schemas/Pagination'
 */
const getAllArticles = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const category = req.query.category || null;
    const search = req.query.search || null;
    
    const { articles, total } = await Article.findAll(page, limit, true, category, search);
    
    return paginatedResponse(res, articles, page, limit, total, 'Articles retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/articles/{slug}:
 *   get:
 *     summary: Get article by slug
 *     description: Get a single active article by its slug. Automatically increments the view count when accessed. Includes category information (category_id, category_name, category_slug).
 *     tags:
 *       - Articles
 *     parameters:
 *       - name: slug
 *         in: path
 *         required: true
 *         description: Article slug
 *         schema:
 *           type: string
 *           example: protecting-indonesian-forests
 *     responses:
 *       200:
 *         description: Article retrieved successfully with category information. View count automatically incremented.
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
 *                   example: Article retrieved
 *                 data:
 *                   $ref: '#/components/schemas/Article'
 *       404:
 *         description: Article not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
const getArticleBySlug = async (req, res, next) => {
  try {
    const article = await Article.findBySlug(req.params.slug);
    
    if (!article) {
      return errorResponse(res, 'Article not found', 404);
    }
    
    // Automatically increment view count
    await Article.incrementViewCount(article.id);
    
    // Fetch updated article with new view count
    const updatedArticle = await Article.findById(article.id);
    
    return successResponse(res, updatedArticle, 'Article retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/articles/{id}/increment-views:
 *   post:
 *     summary: Increment article view count
 *     description: Increment the view count for a specific article
 *     tags:
 *       - Articles
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: Article ID
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       200:
 *         description: View count incremented successfully
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
 *                   example: View count incremented
 */
const incrementViews = async (req, res, next) => {
  try {
    await Article.incrementViewCount(req.params.id);
    return successResponse(res, null, 'View count incremented');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/articles:
 *   get:
 *     summary: Get all articles (admin)
 *     description: Get all articles including inactive ones with category information and search. Supports filtering by category ID or slug (admin only).
 *     tags:
 *       - Admin - Articles
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: search
 *         in: query
 *         description: Search in title, subtitle, content, and excerpt (optional)
 *         schema:
 *           type: string
 *           example: forest conservation
 *       - name: category
 *         in: query
 *         description: Filter by category ID or slug (optional). Accepts both numeric ID (e.g., 1) or slug (e.g., environmental-conservation).
 *         schema:
 *           type: string
 *           example: 1
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
 *         description: Articles retrieved successfully with category information
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
 *                   example: Articles retrieved
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Article'
 *                 pagination:
 *                   $ref: '#/components/schemas/Pagination'
 *       401:
 *         description: Unauthorized - Invalid or missing token
 *   post:
 *     summary: Create new article
 *     description: Create a new article with optional category assignment (admin only)
 *     tags:
 *       - Admin - Articles
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
 *               - content
 *             properties:
 *               title:
 *                 type: string
 *                 example: Protecting Indonesian Forests
 *               subtitle:
 *                 type: string
 *                 example: Our commitment to preserving biodiversity
 *               content:
 *                 type: string
 *                 description: Markdown content
 *                 example: "# Introduction\n\nThis article discusses..."
 *               excerpt:
 *                 type: string
 *                 example: A brief overview of our forest conservation efforts
 *               image_url:
 *                 type: string
 *                 example: https://example.com/images/forest.jpg
 *               category_id:
 *                 type: integer
 *                 description: Category ID (foreign key to categories table)
 *                 example: 1
 *               published_at:
 *                 type: string
 *                 format: date-time
 *                 example: 2024-01-15T10:00:00Z
 *               is_active:
 *                 type: boolean
 *                 default: true
 *                 example: true
 *     responses:
 *       201:
 *         description: Article created successfully
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
 *                   example: Article created successfully
 *                 data:
 *                   $ref: '#/components/schemas/Article'
 *       401:
 *         description: Unauthorized - Invalid or missing token
 */
// Admin endpoints
const getAllArticlesAdmin = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const category = req.query.category || null;
    const search = req.query.search || null;
    
    const { articles, total } = await Article.findAll(page, limit, null, category, search);
    
    return paginatedResponse(res, articles, page, limit, total, 'Articles retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/articles/{id}:
 *   get:
 *     summary: Get single article by ID (admin)
 *     description: Get a single article by ID with category information (admin only)
 *     tags:
 *       - Admin - Articles
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: Article ID
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       200:
 *         description: Article retrieved successfully
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
 *                   example: Article retrieved
 *                 data:
 *                   $ref: '#/components/schemas/Article'
 *       404:
 *         description: Article not found
 *       401:
 *         description: Unauthorized - Invalid or missing token
 */
const getArticleById = async (req, res, next) => {
  try {
    const article = await Article.findById(req.params.id);
    
    if (!article) {
      return errorResponse(res, 'Article not found', 404);
    }
    
    return successResponse(res, article, 'Article retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/articles/{id}:
 *   put:
 *     summary: Update article
 *     description: Update an existing article including category assignment (admin only)
 *     tags:
 *       - Admin - Articles
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: Article ID
 *         schema:
 *           type: integer
 *           example: 1
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *                 example: Updated Article Title
 *               subtitle:
 *                 type: string
 *                 example: Updated subtitle
 *               content:
 *                 type: string
 *                 description: Markdown content
 *                 example: "# Updated Content\n\nThis is the updated article..."
 *               excerpt:
 *                 type: string
 *                 example: Updated excerpt
 *               image_url:
 *                 type: string
 *                 example: https://example.com/images/updated.jpg
 *               category_id:
 *                 type: integer
 *                 description: Category ID (foreign key to categories table)
 *                 example: 2
 *               published_at:
 *                 type: string
 *                 format: date-time
 *                 example: 2024-02-15T10:00:00Z
 *               is_active:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       200:
 *         description: Article updated successfully
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
 *                   example: Article updated successfully
 *                 data:
 *                   $ref: '#/components/schemas/Article'
 *       404:
 *         description: Article not found
 *       401:
 *         description: Unauthorized - Invalid or missing token
 *   delete:
 *     summary: Delete article
 *     description: Delete an article permanently (admin only)
 *     tags:
 *       - Admin - Articles
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: Article ID
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       200:
 *         description: Article deleted successfully
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
 *                   example: Article deleted successfully
 *                 data:
 *                   type: null
 *       404:
 *         description: Article not found
 *       401:
 *         description: Unauthorized - Invalid or missing token
 */
const createArticle = async (req, res, next) => {
  try {
    const article = await Article.create(req.body, req.user.id);
    return successResponse(res, article, 'Article created successfully', 201);
  } catch (error) {
    next(error);
  }
};

const updateArticle = async (req, res, next) => {
  try {
    const article = await Article.update(req.params.id, req.body);
    
    if (!article) {
      return errorResponse(res, 'Article not found', 404);
    }
    
    return successResponse(res, article, 'Article updated successfully');
  } catch (error) {
    next(error);
  }
};

const deleteArticle = async (req, res, next) => {
  try {
    const deleted = await Article.delete(req.params.id);
    
    if (!deleted) {
      return errorResponse(res, 'Article not found', 404);
    }
    
    return successResponse(res, null, 'Article deleted successfully');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllArticles,
  getArticleBySlug,
  incrementViews,
  getAllArticlesAdmin,
  getArticleById,
  createArticle,
  updateArticle,
  deleteArticle
};
