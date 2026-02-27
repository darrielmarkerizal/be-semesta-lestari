const Settings = require('../models/Settings');
const User = require('../models/User');
const { successResponse, errorResponse, paginatedResponse } = require('../utils/response');

/**
 * @swagger
 * /api/admin/config:
 *   get:
 *     summary: Get all settings
 *     tags:
 *       - Admin - Settings
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Settings retrieved successfully
 */
const getAllSettings = async (req, res, next) => {
  try {
    const settings = await Settings.findAll();
    return successResponse(res, settings, 'Settings retrieved');
  } catch (error) {
    next(error);
  }
};

const getSettingByKey = async (req, res, next) => {
  try {
    const setting = await Settings.findByKey(req.params.key);
    
    if (!setting) {
      return errorResponse(res, 'Setting not found', 404);
    }
    
    return successResponse(res, setting, 'Setting retrieved');
  } catch (error) {
    next(error);
  }
};

const updateSetting = async (req, res, next) => {
  try {
    const { value } = req.body;
    const setting = await Settings.upsert(req.params.key, value);
    
    return successResponse(res, setting, 'Setting updated successfully');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/users:
 *   get:
 *     summary: Get all users with pagination
 *     description: Retrieve a paginated list of all users in the system
 *     tags:
 *       - Admin - Users
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: page
 *         in: query
 *         description: Page number
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
 *         description: Users retrieved successfully
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
 *                   example: Users retrieved
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                         example: 1
 *                       username:
 *                         type: string
 *                         example: admin
 *                       email:
 *                         type: string
 *                         example: admin@example.com
 *                       role:
 *                         type: string
 *                         enum: [admin, editor]
 *                         example: admin
 *                       status:
 *                         type: string
 *                         enum: [active, inactive]
 *                         example: active
 *                       created_at:
 *                         type: string
 *                         format: date-time
 *                       updated_at:
 *                         type: string
 *                         format: date-time
 *                 pagination:
 *                   type: object
 *                   properties:
 *                     currentPage:
 *                       type: integer
 *                       example: 1
 *                     totalPages:
 *                       type: integer
 *                       example: 5
 *                     totalItems:
 *                       type: integer
 *                       example: 50
 *                     itemsPerPage:
 *                       type: integer
 *                       example: 10
 *                     hasNextPage:
 *                       type: boolean
 *                       example: true
 *                     hasPrevPage:
 *                       type: boolean
 *                       example: false
 *                 error:
 *                   type: null
 *       401:
 *         description: Unauthorized - Invalid or missing token
 *   post:
 *     summary: Create new user
 *     description: Create a new user account with specified credentials and role
 *     tags:
 *       - Admin - Users
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - username
 *               - email
 *               - password
 *             properties:
 *               username:
 *                 type: string
 *                 example: johndoe
 *                 description: Unique username for the user
 *               email:
 *                 type: string
 *                 format: email
 *                 example: john@example.com
 *                 description: Unique email address
 *               password:
 *                 type: string
 *                 example: securepass123
 *                 description: User password (will be hashed)
 *               role:
 *                 type: string
 *                 enum: [admin, editor]
 *                 default: editor
 *                 example: editor
 *                 description: User role
 *               status:
 *                 type: string
 *                 enum: [active, inactive]
 *                 default: active
 *                 example: active
 *                 description: User account status
 *     responses:
 *       201:
 *         description: User created successfully
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
 *                   example: User created successfully
 *                 data:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                       example: 5
 *                     username:
 *                       type: string
 *                       example: johndoe
 *                     email:
 *                       type: string
 *                       example: john@example.com
 *                     role:
 *                       type: string
 *                       example: editor
 *                     status:
 *                       type: string
 *                       example: active
 *                     created_at:
 *                       type: string
 *                       format: date-time
 *                     updated_at:
 *                       type: string
 *                       format: date-time
 *                 error:
 *                   type: null
 *       400:
 *         description: Bad request - Validation error or duplicate username/email
 *       401:
 *         description: Unauthorized - Invalid or missing token
 */
// User management
const getAllUsers = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    
    const { users, total } = await User.findAll(page, limit);
    
    return paginatedResponse(res, users, page, limit, total, 'Users retrieved');
  } catch (error) {
    next(error);
  }
};

const getUserById = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);
    
    if (!user) {
      return errorResponse(res, 'User not found', 404);
    }
    
    return successResponse(res, user, 'User retrieved');
  } catch (error) {
    next(error);
  }
};

const createUser = async (req, res, next) => {
  try {
    const user = await User.create(req.body);
    return successResponse(res, user, 'User created successfully', 201);
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/users/{id}:
 *   get:
 *     summary: Get user by ID
 *     description: Retrieve detailed information about a specific user
 *     tags:
 *       - Admin - Users
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: User ID
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       200:
 *         description: User retrieved successfully
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
 *                   example: User retrieved
 *                 data:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                       example: 1
 *                     username:
 *                       type: string
 *                       example: admin
 *                     email:
 *                       type: string
 *                       example: admin@example.com
 *                     role:
 *                       type: string
 *                       enum: [admin, editor]
 *                       example: admin
 *                     status:
 *                       type: string
 *                       enum: [active, inactive]
 *                       example: active
 *                     created_at:
 *                       type: string
 *                       format: date-time
 *                     updated_at:
 *                       type: string
 *                       format: date-time
 *                 error:
 *                   type: null
 *       404:
 *         description: User not found
 *       401:
 *         description: Unauthorized - Invalid or missing token
 *   put:
 *     summary: Update user
 *     description: Update user information (username, email, password, role, or status)
 *     tags:
 *       - Admin - Users
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: User ID
 *         schema:
 *           type: integer
 *           example: 1
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               username:
 *                 type: string
 *                 example: johndoe
 *                 description: New username (must be unique)
 *               email:
 *                 type: string
 *                 format: email
 *                 example: john@example.com
 *                 description: New email address (must be unique)
 *               password:
 *                 type: string
 *                 example: newpassword123
 *                 description: New password (will be hashed)
 *               role:
 *                 type: string
 *                 enum: [admin, editor]
 *                 example: admin
 *                 description: User role
 *               status:
 *                 type: string
 *                 enum: [active, inactive]
 *                 example: active
 *                 description: Account status
 *           examples:
 *             updateUsername:
 *               summary: Update username only
 *               value:
 *                 username: newusername
 *             updatePassword:
 *               summary: Update password only
 *               value:
 *                 password: newsecurepass123
 *             updateRole:
 *               summary: Update role only
 *               value:
 *                 role: admin
 *             updateMultiple:
 *               summary: Update multiple fields
 *               value:
 *                 username: johndoe
 *                 email: john.doe@example.com
 *                 role: admin
 *                 status: active
 *     responses:
 *       200:
 *         description: User updated successfully
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
 *                   example: User updated successfully
 *                 data:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                       example: 1
 *                     username:
 *                       type: string
 *                       example: johndoe
 *                     email:
 *                       type: string
 *                       example: john@example.com
 *                     role:
 *                       type: string
 *                       example: admin
 *                     status:
 *                       type: string
 *                       example: active
 *                     created_at:
 *                       type: string
 *                       format: date-time
 *                     updated_at:
 *                       type: string
 *                       format: date-time
 *                 error:
 *                   type: null
 *       400:
 *         description: Bad request - Validation error or duplicate username/email
 *       404:
 *         description: User not found
 *       401:
 *         description: Unauthorized - Invalid or missing token
 *   delete:
 *     summary: Delete user
 *     description: Permanently delete a user account (cannot delete your own account)
 *     tags:
 *       - Admin - Users
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         description: User ID to delete
 *         schema:
 *           type: integer
 *           example: 5
 *     responses:
 *       200:
 *         description: User deleted successfully
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
 *                   example: User deleted successfully
 *                 data:
 *                   type: null
 *                 error:
 *                   type: null
 *       400:
 *         description: Cannot delete your own account
 *       404:
 *         description: User not found
 *       401:
 *         description: Unauthorized - Invalid or missing token
 */
const updateUser = async (req, res, next) => {
  try {
    const user = await User.update(req.params.id, req.body);
    
    if (!user) {
      return errorResponse(res, 'User not found', 404);
    }
    
    return successResponse(res, user, 'User updated successfully');
  } catch (error) {
    next(error);
  }
};

const deleteUser = async (req, res, next) => {
  try {
    // Prevent deleting self
    if (parseInt(req.params.id) === req.user.id) {
      return errorResponse(res, 'Cannot delete your own account', 400);
    }
    
    const deleted = await User.delete(req.params.id);
    
    if (!deleted) {
      return errorResponse(res, 'User not found', 404);
    }
    
    return successResponse(res, null, 'User deleted successfully');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllSettings,
  getSettingByKey,
  updateSetting,
  getAllUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser
};
