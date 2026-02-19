const Joi = require('joi');

// User validation schemas
const userSchemas = {
  register: Joi.object({
    username: Joi.string().min(3).max(50).required(),
    email: Joi.string().email().required(),
    password: Joi.string().min(6).required(),
    role: Joi.string().valid('admin', 'editor').default('admin')
  }),
  
  login: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().required()
  }),
  
  update: Joi.object({
    username: Joi.string().min(3).max(50),
    email: Joi.string().email(),
    password: Joi.string().min(6),
    role: Joi.string().valid('admin', 'editor'),
    status: Joi.string().valid('active', 'inactive')
  })
};

// Article validation schemas
const articleSchemas = {
  create: Joi.object({
    title: Joi.string().required(),
    subtitle: Joi.string().max(200).allow('', null),
    content: Joi.string().required(),
    excerpt: Joi.string().max(500).allow('', null),
    image_url: Joi.string().uri().allow('', null),
    category_id: Joi.number().integer().positive().allow(null),
    published_at: Joi.date(),
    is_active: Joi.boolean().default(true)
  }),
  
  update: Joi.object({
    title: Joi.string(),
    subtitle: Joi.string().max(200).allow('', null),
    content: Joi.string(),
    excerpt: Joi.string().max(500).allow('', null),
    image_url: Joi.string().uri().allow('', null),
    category_id: Joi.number().integer().positive().allow(null),
    published_at: Joi.date(),
    is_active: Joi.boolean()
  })
};

// Category validation schemas
const categorySchemas = {
  create: Joi.object({
    name: Joi.string().required(),
    slug: Joi.string().required(),
    description: Joi.string().max(500).allow('', null),
    is_active: Joi.boolean().default(true)
  }),
  
  update: Joi.object({
    name: Joi.string(),
    slug: Joi.string(),
    description: Joi.string().max(500).allow('', null),
    is_active: Joi.boolean()
  })
};

// Generic content validation
const contentSchemas = {
  withTitle: Joi.object({
    title: Joi.string().required(),
    description: Joi.string(),
    image_url: Joi.string().uri().allow(''),
    order_position: Joi.number().integer().min(0),
    is_active: Joi.boolean()
  }),
  
  withName: Joi.object({
    name: Joi.string().required(),
    description: Joi.string(),
    image_url: Joi.string().uri().allow(''),
    order_position: Joi.number().integer().min(0),
    is_active: Joi.boolean()
  })
};

// Contact message validation
const contactSchema = Joi.object({
  name: Joi.string().required(),
  email: Joi.string().email().required(),
  phone: Joi.string().allow(''),
  subject: Joi.string(),
  message: Joi.string().required()
});

module.exports = {
  userSchemas,
  articleSchemas,
  categorySchemas,
  contentSchemas,
  contactSchema
};
