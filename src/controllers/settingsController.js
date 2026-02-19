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
 *     summary: Get all users
 *     tags:
 *       - Admin - Users
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
 *         description: Users retrieved successfully
 *   post:
 *     summary: Create new user
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
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *               role:
 *                 type: string
 *                 enum: [admin, editor]
 *     responses:
 *       201:
 *         description: User created successfully
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
