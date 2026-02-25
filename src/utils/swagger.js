const swaggerJsdoc = require('swagger-jsdoc');
const config = require('../config/environment');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Semesta Lestari API',
      version: '1.0.0',
      description: 'Complete REST API for Semesta Lestari dynamic website with JWT authentication',
      contact: {
        name: 'API Support',
        email: 'support@senestalestari.org'
      }
    },
    servers: [
      {
        url: `http://localhost:${config.port}`,
        description: 'Development server'
      },
      {
        url: 'https://api.senestalestari.org',
        description: 'Production server'
      }
    ],
    components: {
      securitySchemes: {
        BearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Enter JWT token in format: Bearer <token>'
        }
      },
      schemas: {
        Error: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            message: { type: 'string' },
            data: { type: 'null' },
            error: { type: 'object' }
          }
        },
        Pagination: {
          type: 'object',
          properties: {
            currentPage: { type: 'integer' },
            totalPages: { type: 'integer' },
            totalItems: { type: 'integer' },
            itemsPerPage: { type: 'integer' },
            hasNextPage: { type: 'boolean' },
            hasPrevPage: { type: 'boolean' }
          }
        },
        User: {
          type: 'object',
          properties: {
            id: { type: 'integer' },
            username: { type: 'string' },
            email: { type: 'string' },
            role: { type: 'string', enum: ['admin', 'editor'] },
            status: { type: 'string', enum: ['active', 'inactive'] },
            created_at: { type: 'string', format: 'date-time' },
            updated_at: { type: 'string', format: 'date-time' }
          }
        },
        Article: {
          type: 'object',
          properties: {
            id: { type: 'integer' },
            title: { type: 'string' },
            subtitle: { type: 'string', nullable: true },
            slug: { type: 'string' },
            content: { type: 'string', description: 'Markdown content' },
            excerpt: { type: 'string', nullable: true },
            image_url: { type: 'string', nullable: true },
            author_id: { type: 'integer' },
            category_id: { type: 'integer', nullable: true },
            category_name: { type: 'string', nullable: true },
            category_slug: { type: 'string', nullable: true },
            published_at: { type: 'string', format: 'date-time' },
            is_active: { type: 'boolean' },
            view_count: { type: 'integer' },
            created_at: { type: 'string', format: 'date-time' },
            updated_at: { type: 'string', format: 'date-time' }
          }
        },
        Category: {
          type: 'object',
          properties: {
            id: { type: 'integer' },
            name: { type: 'string' },
            slug: { type: 'string' },
            description: { type: 'string', nullable: true },
            is_active: { type: 'boolean' },
            created_at: { type: 'string', format: 'date-time' },
            updated_at: { type: 'string', format: 'date-time' }
          }
        },
        ProgramCategory: {
          type: 'object',
          properties: {
            id: { type: 'integer' },
            name: { type: 'string' },
            slug: { type: 'string' },
            description: { type: 'string', nullable: true },
            icon: { type: 'string', nullable: true, description: 'Emoji or icon identifier' },
            order_position: { type: 'integer' },
            is_active: { type: 'boolean' },
            created_at: { type: 'string', format: 'date-time' },
            updated_at: { type: 'string', format: 'date-time' }
          }
        },
        FooterData: {
          type: 'object',
          properties: {
            contact: {
              type: 'object',
              properties: {
                email: { type: 'string', format: 'email' },
                phones: { type: 'array', items: { type: 'string' } },
                address: { type: 'string' },
                work_hours: { type: 'string' }
              }
            },
            social_media: {
              type: 'object',
              properties: {
                facebook: { type: 'string', format: 'uri' },
                instagram: { type: 'string', format: 'uri' },
                twitter: { type: 'string', format: 'uri' },
                youtube: { type: 'string', format: 'uri' },
                linkedin: { type: 'string', format: 'uri' },
                tiktok: { type: 'string', format: 'uri' }
              }
            },
            program_categories: {
              type: 'array',
              items: { $ref: '#/components/schemas/ProgramCategory' }
            }
          }
        }
      }
    },
    tags: [
      { name: 'Health', description: 'Health check endpoints' },
      { name: 'Authentication', description: 'Authentication endpoints' },
      { name: 'Home', description: 'Homepage content endpoints' },
      { name: 'About', description: 'About page endpoints' },
      { name: 'Articles', description: 'Article management' },
      { name: 'Categories', description: 'Category management' },
      { name: 'Awards', description: 'Award management' },
      { name: 'Merchandise', description: 'Merchandise management' },
      { name: 'Gallery', description: 'Gallery management' },
      { name: 'Gallery Categories', description: 'Gallery category management' },
      { name: 'Contact', description: 'Contact endpoints' },
      { name: 'Programs', description: 'Program management' },
      { name: 'Partners', description: 'Partner management' },
      { name: 'FAQs', description: 'FAQ management' },
      { name: 'Pages', description: 'Page settings and metadata' },
      { name: 'Admin - Dashboard', description: 'Admin dashboard endpoints' },
      { name: 'Admin - Homepage', description: 'Admin homepage management' },
      { name: 'Admin - About', description: 'Admin about page management' },
      { name: 'Admin - Pages', description: 'Admin page settings' },
      { name: 'Admin - Articles', description: 'Admin article management' },
      { name: 'Admin - Categories', description: 'Admin category management' },
      { name: 'Admin - Awards', description: 'Admin award management' },
      { name: 'Admin - Merchandise', description: 'Admin merchandise management' },
      { name: 'Admin - Gallery', description: 'Admin gallery management' },
      { name: 'Admin - Gallery Categories', description: 'Admin gallery category management' },
      { name: 'Admin - Programs', description: 'Admin program management' },
      { name: 'Admin - Partners', description: 'Admin partner management' },
      { name: 'Admin - FAQs', description: 'Admin FAQ management' },
      { name: 'Admin - Contact', description: 'Admin contact info and message management' },
      { name: 'Admin - Users', description: 'Admin user management' },
      { name: 'Admin - Settings', description: 'Admin settings management' },
      { name: 'Admin - Program Categories', description: 'Admin program category management' },
      { name: 'Admin - Statistics', description: 'Admin statistics and analytics' },
      { name: 'Admin - Image Upload', description: 'Admin image upload management' },
      { name: 'Footer', description: 'Footer data endpoint' }
    ]
  },
  apis: ['./src/routes/*.js', './src/controllers/*.js']
};

const swaggerSpec = swaggerJsdoc(options);

module.exports = swaggerSpec;
