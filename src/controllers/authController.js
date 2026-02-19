const User = require('../models/User');
const { generateToken, generateRefreshToken, verifyToken } = require('../utils/jwt');
const { successResponse, errorResponse } = require('../utils/response');
const logger = require('../utils/logger');

/**
 * @swagger
 * /api/admin/auth/login:
 *   post:
 *     summary: Admin login
 *     description: Authenticate admin user and receive JWT token
 *     tags:
 *       - Authentication
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *               password:
 *                 type: string
 *     responses:
 *       200:
 *         description: Login successful
 *       401:
 *         description: Invalid credentials
 */
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    
    // Find user
    const user = await User.findByEmail(email);
    
    if (!user) {
      return errorResponse(res, 'Invalid email or password', 401);
    }
    
    // Check if user is active
    if (user.status !== 'active') {
      return errorResponse(res, 'Account is inactive', 403);
    }
    
    // Verify password
    const isValidPassword = await User.verifyPassword(password, user.password);
    
    if (!isValidPassword) {
      return errorResponse(res, 'Invalid email or password', 401);
    }
    
    // Generate tokens
    const tokenPayload = {
      id: user.id,
      email: user.email,
      role: user.role
    };
    
    const accessToken = generateToken(tokenPayload);
    const refreshToken = generateRefreshToken(tokenPayload);
    
    logger.info(`User logged in: ${user.email}`);
    
    return successResponse(res, {
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role
      },
      accessToken,
      refreshToken
    }, 'Login successful');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/auth/me:
 *   get:
 *     summary: Get current user info
 *     tags:
 *       - Authentication
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: User info retrieved
 *       401:
 *         description: Unauthorized
 */
const getCurrentUser = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);
    
    if (!user) {
      return errorResponse(res, 'User not found', 404);
    }
    
    return successResponse(res, user, 'User info retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/auth/refresh-token:
 *   post:
 *     summary: Refresh access token
 *     tags:
 *       - Authentication
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Token refreshed
 *       401:
 *         description: Invalid token
 */
const refreshToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.substring(7);
    
    if (!token) {
      return errorResponse(res, 'No token provided', 401);
    }
    
    const decoded = verifyToken(token);
    
    const newAccessToken = generateToken({
      id: decoded.id,
      email: decoded.email,
      role: decoded.role
    });
    
    return successResponse(res, { accessToken: newAccessToken }, 'Token refreshed');
  } catch (error) {
    return errorResponse(res, 'Invalid or expired token', 401);
  }
};

/**
 * @swagger
 * /api/admin/auth/logout:
 *   post:
 *     summary: Logout user
 *     tags:
 *       - Authentication
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Logout successful
 */
const logout = async (req, res) => {
  logger.info(`User logged out: ${req.user.email}`);
  return successResponse(res, null, 'Logout successful');
};

module.exports = {
  login,
  getCurrentUser,
  refreshToken,
  logout
};
