const Program = require('../models/Program');
const HomeProgramsSection = require('../models/HomeProgramsSection');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * @swagger
 * /api/programs:
 *   get:
 *     summary: Get programs section with all programs
 *     tags:
 *       - Programs
 *     responses:
 *       200:
 *         description: Programs retrieved successfully
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
 *                     section:
 *                       type: object
 *                       properties:
 *                         id:
 *                           type: integer
 *                         title:
 *                           type: string
 *                         subtitle:
 *                           type: string
 *                         is_active:
 *                           type: boolean
 *                     items:
 *                       type: array
 *                       items:
 *                         type: object
 */
const getAllPrograms = async (req, res, next) => {
  try {
    const section = await HomeProgramsSection.getFirst(null);
    const items = await Program.findAll(true);
    
    return successResponse(res, { section, items }, 'Programs retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/programs/{id}:
 *   get:
 *     summary: Get single program by ID
 *     tags:
 *       - Programs
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Program retrieved successfully
 */
const getProgramById = async (req, res, next) => {
  try {
    const item = await Program.findById(req.params.id);
    if (!item) return errorResponse(res, 'Program not found', 404);
    return successResponse(res, item, 'Program retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/programs:
 *   get:
 *     summary: Get all programs (admin)
 *     tags:
 *       - Admin - Programs
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Programs retrieved successfully
 *   post:
 *     summary: Create new program
 *     tags:
 *       - Admin - Programs
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
 *               image_url:
 *                 type: string
 *               is_highlighted:
 *                 type: boolean
 *                 description: Mark this program as highlighted on homepage
 *               order_position:
 *                 type: integer
 *               is_active:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: Program created successfully
 */
const getAllProgramsAdmin = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const { data, total } = await Program.findAllPaginated(page, limit, null);
    return require('../utils/response').paginatedResponse(res, data, page, limit, total, 'Program retrieved');
  } catch (error) {
    next(error);
  }
};

const getProgramByIdAdmin = async (req, res, next) => {
  try {
    const item = await Program.findById(req.params.id);
    if (!item) return errorResponse(res, 'Program not found', 404);
    return successResponse(res, item, 'Program retrieved');
  } catch (error) {
    next(error);
  }
};

const createProgram = async (req, res, next) => {
  try {
    const item = await Program.create(req.body);
    return successResponse(res, item, 'Program created successfully', 201);
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/programs/{id}:
 *   put:
 *     summary: Update program
 *     tags:
 *       - Admin - Programs
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
 *               image_url:
 *                 type: string
 *               is_highlighted:
 *                 type: boolean
 *                 description: Mark this program as highlighted on homepage
 *               order_position:
 *                 type: integer
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Program updated successfully
 *   delete:
 *     summary: Delete program
 *     tags:
 *       - Admin - Programs
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
 *         description: Program deleted successfully
 */
const updateProgram = async (req, res, next) => {
  try {
    const item = await Program.update(req.params.id, req.body);
    if (!item) return errorResponse(res, 'Program not found', 404);
    return successResponse(res, item, 'Program updated successfully');
  } catch (error) {
    next(error);
  }
};

const deleteProgram = async (req, res, next) => {
  try {
    const deleted = await Program.delete(req.params.id);
    if (!deleted) return errorResponse(res, 'Program not found', 404);
    return successResponse(res, null, 'Program deleted successfully');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAll: getAllPrograms,
  getById: getProgramById,
  getAllAdmin: getAllProgramsAdmin,
  getByIdAdmin: getProgramByIdAdmin,
  create: createProgram,
  update: updateProgram,
  delete: deleteProgram
};
