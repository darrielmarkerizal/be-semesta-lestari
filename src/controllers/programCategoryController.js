const ProgramCategory = require('../models/ProgramCategory');
const createGenericController = require('./genericController');

/**
 * @swagger
 * /api/admin/program-categories:
 *   get:
 *     summary: Get all program categories
 *     tags:
 *       - Admin - Program Categories
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Program categories retrieved successfully
 *   post:
 *     summary: Create new program category
 *     tags:
 *       - Admin - Program Categories
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
 *                 example: Conservation
 *               slug:
 *                 type: string
 *                 example: conservation
 *               description:
 *                 type: string
 *                 example: Programs focused on environmental conservation
 *               icon:
 *                 type: string
 *                 example: 🌳
 *               order_position:
 *                 type: integer
 *                 example: 1
 *               is_active:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       201:
 *         description: Program category created successfully
 */
/**
 * @swagger
 * /api/admin/program-categories/{id}:
 *   put:
 *     summary: Update program category
 *     tags:
 *       - Admin - Program Categories
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
 *               icon:
 *                 type: string
 *               order_position:
 *                 type: integer
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Program category updated successfully
 *   delete:
 *     summary: Delete program category
 *     tags:
 *       - Admin - Program Categories
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
 *         description: Program category deleted successfully
 */

module.exports = createGenericController(ProgramCategory, 'Program Category');
