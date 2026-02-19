/**
 * Success response helper
 * @param {Object} res - Express response object
 * @param {Object} data - Response data
 * @param {String} message - Success message
 * @param {Number} statusCode - HTTP status code
 */
const successResponse = (res, data = null, message = 'Success', statusCode = 200) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    error: null
  });
};

/**
 * Error response helper
 * @param {Object} res - Express response object
 * @param {String} message - Error message
 * @param {Number} statusCode - HTTP status code
 * @param {Object} error - Error details
 */
const errorResponse = (res, message = 'Error occurred', statusCode = 500, error = null) => {
  return res.status(statusCode).json({
    success: false,
    message,
    data: null,
    error
  });
};

/**
 * Paginated response helper
 * @param {Object} res - Express response object
 * @param {Array} data - Response data array
 * @param {Number} page - Current page
 * @param {Number} limit - Items per page
 * @param {Number} total - Total items count
 * @param {String} message - Success message
 */
const paginatedResponse = (res, data, page, limit, total, message = 'Success') => {
  const totalPages = Math.ceil(total / limit);
  
  return res.status(200).json({
    success: true,
    message,
    data,
    pagination: {
      currentPage: parseInt(page),
      totalPages,
      totalItems: total,
      itemsPerPage: parseInt(limit),
      hasNextPage: page < totalPages,
      hasPrevPage: page > 1
    },
    error: null
  });
};

module.exports = {
  successResponse,
  errorResponse,
  paginatedResponse
};
