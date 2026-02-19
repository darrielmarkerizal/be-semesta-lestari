const logger = require('../utils/logger');
const { errorResponse } = require('../utils/response');

/**
 * Global error handler middleware
 */
const errorHandler = (err, req, res, next) => {
  logger.error('Error:', {
    message: err.message,
    stack: err.stack,
    url: req.originalUrl,
    method: req.method
  });
  
  // Handle specific error types
  if (err.name === 'ValidationError') {
    return errorResponse(res, 'Validation error', 400, { details: err.message });
  }
  
  if (err.name === 'UnauthorizedError') {
    return errorResponse(res, 'Unauthorized access', 401);
  }
  
  if (err.code === 'ER_DUP_ENTRY') {
    return errorResponse(res, 'Duplicate entry - Record already exists', 409);
  }
  
  if (err.code === 'ER_NO_REFERENCED_ROW_2') {
    return errorResponse(res, 'Referenced record does not exist', 400);
  }
  
  // Default error response
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal server error';
  
  return errorResponse(res, message, statusCode, {
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
};

/**
 * 404 Not Found handler
 */
const notFoundHandler = (req, res) => {
  return errorResponse(res, `Route ${req.originalUrl} not found`, 404);
};

module.exports = {
  errorHandler,
  notFoundHandler
};
