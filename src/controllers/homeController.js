const HeroSection = require('../models/HeroSection');
const Vision = require('../models/Vision');
const Mission = require('../models/Mission');
const ImpactSection = require('../models/ImpactSection');
const DonationCTA = require('../models/DonationCTA');
const ClosingCTA = require('../models/ClosingCTA');
const Program = require('../models/Program');
const Partner = require('../models/Partner');
const FAQ = require('../models/FAQ');
const HomeStatistics = require('../models/HomeStatistics');
const HomePartnersSection = require('../models/HomePartnersSection');
const HomeProgramsSection = require('../models/HomeProgramsSection');
const HomeFaqSection = require('../models/HomeFaqSection');
const Settings = require('../models/Settings');
const Visitor = require('../models/Visitor');
const { successResponse } = require('../utils/response');

/**
 * @swagger
 * /api/home:
 *   get:
 *     summary: Get complete home page data
 *     description: Returns all sections for the home page including hero, visions, missions, programs, statistics, partners, FAQs, and contact information
 *     tags:
 *       - Home
 *     responses:
 *       200:
 *         description: Home page data retrieved successfully
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
 *                   example: Home page data retrieved
 *                 data:
 *                   type: object
 *                   properties:
 *                     hero:
 *                       type: object
 *                       properties:
 *                         title:
 *                           type: string
 *                         subtitle:
 *                           type: string
 *                         description:
 *                           type: string
 *                         image_url:
 *                           type: string
 *                         button_text:
 *                           type: string
 *                         button_url:
 *                           type: string
 *                         button_text_2:
 *                           type: string
 *                         button_url_2:
 *                           type: string
 *                     vision:
 *                       type: object
 *                       properties:
 *                         id:
 *                           type: integer
 *                         title:
 *                           type: string
 *                         description:
 *                           type: string
 *                         icon_url:
 *                           type: string
 *                         image_url:
 *                           type: string
 *                     missions:
 *                       type: array
 *                       items:
 *                         type: object
 *                     impact:
 *                       type: array
 *                       items:
 *                         type: object
 *                     programs:
 *                       type: object
 *                       properties:
 *                         section:
 *                           type: object
 *                           properties:
 *                             title:
 *                               type: string
 *                             subtitle:
 *                               type: string
 *                         items:
 *                           type: array
 *                           items:
 *                             type: object
 *                             properties:
 *                               id:
 *                                 type: integer
 *                               name:
 *                                 type: string
 *                               description:
 *                                 type: string
 *                               is_highlighted:
 *                                 type: boolean
 *                         highlighted:
 *                           type: object
 *                           description: The highlighted program
 *                     statistics:
 *                       type: object
 *                       properties:
 *                         title:
 *                           type: string
 *                         subtitle:
 *                           type: string
 *                         trees_planted:
 *                           type: string
 *                         volunteers:
 *                           type: string
 *                         areas_covered:
 *                           type: string
 *                         partners_count:
 *                           type: string
 *                     donationCta:
 *                       type: object
 *                       properties:
 *                         title:
 *                           type: string
 *                         description:
 *                           type: string
 *                         button_text:
 *                           type: string
 *                         button_url:
 *                           type: string
 *                         button_text_2:
 *                           type: string
 *                         button_url_2:
 *                           type: string
 *                         image_url:
 *                           type: string
 *                     partners:
 *                       type: object
 *                       properties:
 *                         section:
 *                           type: object
 *                           properties:
 *                             title:
 *                               type: string
 *                             subtitle:
 *                               type: string
 *                         items:
 *                           type: array
 *                           items:
 *                             type: object
 *                             properties:
 *                               id:
 *                                 type: integer
 *                               name:
 *                                 type: string
 *                               description:
 *                                 type: string
 *                               logo_url:
 *                                 type: string
 *                               website:
 *                                 type: string
 *                     faq:
 *                       type: object
 *                       properties:
 *                         section:
 *                           type: object
 *                           properties:
 *                             title:
 *                               type: string
 *                             subtitle:
 *                               type: string
 *                         items:
 *                           type: array
 *                           items:
 *                             type: object
 *                             properties:
 *                               id:
 *                                 type: integer
 *                               question:
 *                                 type: string
 *                               answer:
 *                                 type: string
 *                               category:
 *                                 type: string
 *                     contact:
 *                       type: object
 *                       properties:
 *                         email:
 *                           type: string
 *                         phones:
 *                           type: array
 *                           items:
 *                             type: string
 *                         address:
 *                           type: string
 *                         work_hours:
 *                           type: string
 *                     closingCta:
 *                       type: object
 */
const getHomePage = async (req, res, next) => {
  try {
    // Track visitor by IP address
    const ipAddress = req.ip || req.connection.remoteAddress || req.headers['x-forwarded-for'];
    const userAgent = req.headers['user-agent'];
    
    // Track visit asynchronously (don't wait for it)
    Visitor.trackVisit(ipAddress, userAgent).catch(err => {
      console.error('Failed to track visitor:', err);
    });
    
    const [
      hero,
      vision,
      missions,
      impact,
      programsSection,
      programs,
      statistics,
      donationCta,
      partnersSection,
      partners,
      faqSection,
      faqs,
      contactEmail,
      contactPhones,
      contactAddress,
      contactWorkHours,
      closingCta
    ] = await Promise.all([
      HeroSection.getFirst(),
      Vision.getFirst(),
      Mission.findAll(true),
      ImpactSection.findAll(true),
      HomeProgramsSection.getFirst(),
      Program.findAll(true),
      HomeStatistics.getFirst(),
      DonationCTA.getFirst(),
      HomePartnersSection.getFirst(),
      Partner.findAll(true),
      HomeFaqSection.getFirst(),
      FAQ.findAll(true),
      Settings.findByKey('contact_email'),
      Settings.findByKey('contact_phones'),
      Settings.findByKey('contact_address'),
      Settings.findByKey('contact_work_hours'),
      ClosingCTA.getFirst()
    ]);
    
    // Parse phones from JSON string to array
    let phonesArray = [];
    if (contactPhones?.value) {
      try {
        phonesArray = JSON.parse(contactPhones.value);
      } catch (e) {
        phonesArray = [contactPhones.value];
      }
    }
    
    // Get highlighted program
    const highlightedProgram = programs.find(p => p.is_highlighted) || null;
    
    return successResponse(res, {
      hero,
      vision,
      missions,
      impact,
      programs: {
        section: programsSection,
        items: programs,
        highlighted: highlightedProgram
      },
      statistics,
      donationCta,
      partners: {
        section: partnersSection,
        items: partners
      },
      faq: {
        section: faqSection,
        items: faqs
      },
      contact: {
        email: contactEmail?.value || '',
        phones: phonesArray,
        address: contactAddress?.value || '',
        work_hours: contactWorkHours?.value || ''
      },
      closingCta
    }, 'Home page data retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/hero-section:
 *   get:
 *     summary: Get hero section
 *     tags:
 *       - Home
 *     responses:
 *       200:
 *         description: Hero section retrieved
 */
const getHeroSection = async (req, res, next) => {
  try {
    const hero = await HeroSection.getFirst();
    return successResponse(res, hero, 'Hero section retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/vision:
 *   get:
 *     summary: Get vision
 *     tags:
 *       - Home
 *     responses:
 *       200:
 *         description: Vision retrieved
 */
const getVision = async (req, res, next) => {
  try {
    const vision = await Vision.getFirst();
    return successResponse(res, vision, 'Vision retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/missions:
 *   get:
 *     summary: Get all missions
 *     tags:
 *       - Home
 *     responses:
 *       200:
 *         description: Missions retrieved
 */
const getMissions = async (req, res, next) => {
  try {
    const missions = await Mission.findAll(true);
    return successResponse(res, missions, 'Missions retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/impact:
 *   get:
 *     summary: Get impact sections
 *     tags:
 *       - Home
 *     responses:
 *       200:
 *         description: Impact sections retrieved
 */
const getImpact = async (req, res, next) => {
  try {
    const impact = await ImpactSection.findAll(true);
    return successResponse(res, impact, 'Impact sections retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/donation-cta:
 *   get:
 *     summary: Get donation CTA
 *     tags:
 *       - Home
 *     responses:
 *       200:
 *         description: Donation CTA retrieved
 */
const getDonationCTA = async (req, res, next) => {
  try {
    const cta = await DonationCTA.getFirst();
    return successResponse(res, cta, 'Donation CTA retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/closing-cta:
 *   get:
 *     summary: Get closing CTA
 *     tags:
 *       - Home
 *     responses:
 *       200:
 *         description: Closing CTA retrieved
 */
const getClosingCTA = async (req, res, next) => {
  try {
    const cta = await ClosingCTA.getFirst();
    return successResponse(res, cta, 'Closing CTA retrieved');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getHomePage,
  getHeroSection,
  getVision,
  getMissions,
  getImpact,
  getDonationCTA,
  getClosingCTA
};
