const { verifyToken } = require('../utils/jwt');
const { errorResponse } = require('../utils/response');
const logger = require('../utils/logger');

/**
 * Authentication middleware - Verify JWT Bearer token
 */
const authenticate = async (req, res, next) => {
  try {
    // Get token from Authorization header
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return errorResponse(res, 'No token provided. Authorization header must be in format: Bearer <token>', 401);
    }
    
    // Extract token
    const token = authHeader.substring(7);
    
    if (!token) {
      return errorResponse(res, 'Invalid token format', 401);
    }
    
    // Verify token
    const decoded = verifyToken(token);
    
    // Attach user info to request
    req.user = {
      id: decoded.id,
      email: decoded.email,
      role: decoded.role
    };
    
    next();
  } catch (error) {
    logger.error('Authentication error:', error);
    return errorResponse(res, 'Invalid or expired token', 401);
  }
};

/**
 * Role-based authorization middleware
 * @param {Array} roles - Allowed roles
 */
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return errorResponse(res, 'Unauthorized', 401);
    }
    
    if (roles.length && !roles.includes(req.user.role)) {
      return errorResponse(res, 'Forbidden - Insufficient permissions', 403);
    }
    
    next();
  };
};

module.exports = {
  authenticate,
  authorize
};
