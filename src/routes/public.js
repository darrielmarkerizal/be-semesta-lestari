const express = require('express');
const router = express.Router();
const { validate } = require('../middleware/validation');
const { contactSchema } = require('../utils/validation');

// Controllers
const homeController = require('../controllers/homeController');
const aboutController = require('../controllers/aboutController');
const articleController = require('../controllers/articleController');
const awardController = require('../controllers/awardController');
const merchandiseController = require('../controllers/merchandiseController');
const galleryController = require('../controllers/galleryController');
const galleryCategoryController = require('../controllers/galleryCategoryController');
const contactController = require('../controllers/contactController');
const pageController = require('../controllers/pageController');
const programController = require('../controllers/programController');
const partnerController = require('../controllers/partnerController');
const faqController = require('../controllers/faqController');
const categoryController = require('../controllers/categoryController');
const Settings = require('../models/Settings');
const { successResponse } = require('../utils/response');

/**
 * @swagger
 * /api/health:
 *   get:
 *     summary: Health check endpoint
 *     tags:
 *       - Health
 *     responses:
 *       200:
 *         description: API is healthy
 */
router.get('/health', (req, res) => {
  successResponse(res, { status: 'OK', timestamp: new Date().toISOString() }, 'API is healthy');
});

// Home page endpoints
router.get('/home', homeController.getHomePage);
router.get('/hero-section', homeController.getHeroSection);
router.get('/vision', homeController.getVision);
router.get('/missions', homeController.getMissions);
router.get('/impact', homeController.getImpact);
router.get('/donation-cta', homeController.getDonationCTA);
router.get('/closing-cta', homeController.getClosingCTA);

// About page endpoints
router.get('/about/history', aboutController.getHistory);
router.get('/about/vision', aboutController.getVision);
router.get('/about/missions', aboutController.getMissions);
router.get('/about/leadership', aboutController.getLeadership);

// Articles
router.get('/articles', articleController.getAllArticles);
router.get('/articles/:slug', articleController.getArticleBySlug);
router.post('/articles/:id/increment-views', articleController.incrementViews);

// Awards
router.get('/awards', awardController.getAllPaginated);
router.get('/awards/:id', awardController.getById);

// Merchandise
router.get('/merchandise', merchandiseController.getAllPaginated);
router.get('/merchandise/:id', merchandiseController.getById);

// Gallery
router.get('/gallery', galleryController.getAllPaginated);
router.get('/gallery/:id', galleryController.getById);

// Gallery Categories
router.get('/gallery-categories', galleryCategoryController.getAll);
router.get('/gallery-categories/:slug', galleryCategoryController.getBySlug);

// Programs
router.get('/programs', programController.getAll);
router.get('/programs/:id', programController.getById);

// Partners
router.get('/partners', partnerController.getAll);
router.get('/partners/:id', partnerController.getById);

// FAQs
router.get('/faqs', faqController.getAll);
router.get('/faqs/:id', faqController.getById);

// Categories
router.get('/categories', categoryController.getAll);
router.get('/categories/:slug', categoryController.getBySlug);

// Contact
router.get('/contact/info', contactController.getContactInfo);
router.post('/contact/send-message', validate(contactSchema), contactController.sendMessage);

// Page info
router.get('/pages/:slug/info', pageController.getPageInfo);

// Config/Settings (public)
router.get('/config/:key', async (req, res, next) => {
  try {
    const setting = await Settings.findByKey(req.params.key);
    successResponse(res, setting || null, 'Setting retrieved');
  } catch (error) {
    next(error);
  }
});

router.get('/config', async (req, res, next) => {
  try {
    const settings = await Settings.findAll();
    successResponse(res, settings, 'Settings retrieved');
  } catch (error) {
    next(error);
  }
});

module.exports = router;
