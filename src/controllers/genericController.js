const { successResponse, errorResponse, paginatedResponse } = require('../utils/response');

/**
 * Generic controller factory for simple CRUD operations
 */
const createGenericController = (model, resourceName) => {
  return {
    // Public endpoints
    getAll: async (req, res, next) => {
      try {
        const data = await model.findAll(true);
        return successResponse(res, data, `${resourceName} retrieved`);
      } catch (error) {
        next(error);
      }
    },
    
    getAllPaginated: async (req, res, next) => {
      try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        
        const { data, total } = await model.findAllPaginated(page, limit, true);
        return paginatedResponse(res, data, page, limit, total, `${resourceName} retrieved`);
      } catch (error) {
        next(error);
      }
    },
    
    getById: async (req, res, next) => {
      try {
        const item = await model.findById(req.params.id);
        
        if (!item) {
          return errorResponse(res, `${resourceName} not found`, 404);
        }
        
        return successResponse(res, item, `${resourceName} retrieved`);
      } catch (error) {
        next(error);
      }
    },
    
    getByCategory: async (req, res, next) => {
      try {
        const items = await model.findByCategory(req.params.category, true);
        return successResponse(res, items, `${resourceName} retrieved`);
      } catch (error) {
        next(error);
      }
    },
    
    // Admin endpoints
    getAllAdmin: async (req, res, next) => {
      try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        
        const { data, total } = await model.findAllPaginated(page, limit, null);
        return paginatedResponse(res, data, page, limit, total, `${resourceName} retrieved`);
      } catch (error) {
        next(error);
      }
    },
    
    getByIdAdmin: async (req, res, next) => {
      try {
        const item = await model.findById(req.params.id);
        
        if (!item) {
          return errorResponse(res, `${resourceName} not found`, 404);
        }
        
        return successResponse(res, item, `${resourceName} retrieved`);
      } catch (error) {
        next(error);
      }
    },
    
    create: async (req, res, next) => {
      try {
        const item = await model.create(req.body);
        return successResponse(res, item, `${resourceName} created successfully`, 201);
      } catch (error) {
        next(error);
      }
    },
    
    update: async (req, res, next) => {
      try {
        const item = await model.update(req.params.id, req.body);
        
        if (!item) {
          return errorResponse(res, `${resourceName} not found`, 404);
        }
        
        return successResponse(res, item, `${resourceName} updated successfully`);
      } catch (error) {
        next(error);
      }
    },
    
    delete: async (req, res, next) => {
      try {
        const deleted = await model.delete(req.params.id);
        
        if (!deleted) {
          return errorResponse(res, `${resourceName} not found`, 404);
        }
        
        return successResponse(res, null, `${resourceName} deleted successfully`);
      } catch (error) {
        next(error);
      }
    }
  };
};

module.exports = createGenericController;
