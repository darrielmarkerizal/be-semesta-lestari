const HeroSection = require("../models/HeroSection");
const Vision = require("../models/Vision");
const Mission = require("../models/Mission");
const ImpactSection = require("../models/ImpactSection");
const HomeImpactSection = require("../models/HomeImpactSection");
const DonationCTA = require("../models/DonationCTA");
const ClosingCTA = require("../models/ClosingCTA");
const History = require("../models/History");
const Leadership = require("../models/Leadership");
const HomeStatistics = require("../models/HomeStatistics");
const HomePartnersSection = require("../models/HomePartnersSection");
const HomeProgramsSection = require("../models/HomeProgramsSection");
const HomeFaqSection = require("../models/HomeFaqSection");
const FAQ = require("../models/FAQ");
const createGenericController = require("./genericController");

/**
 * @swagger
 * /api/admin/homepage/hero:
 *   get:
 *     summary: Get hero section
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Hero section retrieved successfully
 *   put:
 *     summary: Update hero section
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               subtitle:
 *                 type: string
 *               description:
 *                 type: string
 *               image_url:
 *                 type: string
 *               button_text:
 *                 type: string
 *               button_url:
 *                 type: string
 *               button_text_2:
 *                 type: string
 *               button_url_2:
 *                 type: string
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Hero section updated successfully
 */
// Hero Section
const heroController = {
  get: async (req, res, next) => {
    try {
      const hero = await HeroSection.getFirst();
      return require("../utils/response").successResponse(
        res,
        hero,
        "Hero section retrieved",
      );
    } catch (error) {
      next(error);
    }
  },
  update: async (req, res, next) => {
    try {
      const hero = await HeroSection.getFirst();
      const updated = await HeroSection.update(hero?.id || 1, req.body);
      return require("../utils/response").successResponse(
        res,
        updated,
        "Hero section updated",
      );
    } catch (error) {
      next(error);
    }
  },
};

/**
 * @swagger
 * /api/admin/homepage/vision:
 *   get:
 *     summary: Get vision
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Vision retrieved successfully
 *   put:
 *     summary: Update vision
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               icon_url:
 *                 type: string
 *               image_url:
 *                 type: string
 *                 description: Main image for vision section
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Vision updated successfully
 */
// Vision controller
const visionController = {
  get: async (req, res, next) => {
    try {
      const vision = await Vision.getFirst();
      return require("../utils/response").successResponse(
        res,
        vision,
        "Vision retrieved",
      );
    } catch (error) {
      next(error);
    }
  },
  update: async (req, res, next) => {
    try {
      const vision = await Vision.getFirst();
      const updated = await Vision.update(vision?.id || 1, req.body);
      return require("../utils/response").successResponse(
        res,
        updated,
        "Vision updated",
      );
    } catch (error) {
      next(error);
    }
  },
};

/**
 * @swagger
 * /api/admin/homepage/missions:
 *   get:
 *     summary: Get all missions
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Missions retrieved successfully
 *   post:
 *     summary: Create new mission
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - title
 *               - description
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               icon_url:
 *                 type: string
 *               order_position:
 *                 type: integer
 *               is_active:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: Mission created successfully
 */
/**
 * @swagger
 * /api/admin/homepage/missions/{id}:
 *   put:
 *     summary: Update mission
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               icon_url:
 *                 type: string
 *               order_position:
 *                 type: integer
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Mission updated successfully
 *   delete:
 *     summary: Delete mission
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Mission deleted successfully
 */
const missionController = createGenericController(Mission, "Mission");
/**
 * @swagger
 * /api/admin/homepage/impact:
 *   get:
 *     summary: Get all impact items
 *     description: Returns all impact items (stats/achievements). Use /api/admin/homepage/impact-section for section header settings.
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Impact items retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       title:
 *                         type: string
 *                         example: Trees Planted
 *                       description:
 *                         type: string
 *                         example: Trees planted across communities
 *                       icon_url:
 *                         type: string
 *                         nullable: true
 *                       image_url:
 *                         type: string
 *                         nullable: true
 *                         description: Main image for impact item
 *                       stats_number:
 *                         type: string
 *                         example: 10,000+
 *                       order_position:
 *                         type: integer
 *                       is_active:
 *                         type: boolean
 *   post:
 *     summary: Create new impact item
 *     description: Create a new impact stat/achievement item
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - title
 *             properties:
 *               title:
 *                 type: string
 *                 example: Trees Planted
 *               description:
 *                 type: string
 *                 example: Trees planted across communities
 *               icon_url:
 *                 type: string
 *                 example: /uploads/icons/tree.svg
 *               image_url:
 *                 type: string
 *                 example: /uploads/impact_section/trees.jpg
 *                 description: Main image for impact item
 *               stats_number:
 *                 type: string
 *                 example: 10,000+
 *               order_position:
 *                 type: integer
 *                 example: 1
 *               is_active:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       201:
 *         description: Impact item created successfully
 */
/**
 * @swagger
 * /api/admin/homepage/impact/{id}:
 *   put:
 *     summary: Update impact item
 *     description: Update an existing impact stat/achievement item
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *                 example: Trees Planted
 *               description:
 *                 type: string
 *                 example: Trees planted across communities
 *               icon_url:
 *                 type: string
 *                 example: /uploads/icons/tree.svg
 *               image_url:
 *                 type: string
 *                 example: /uploads/impact_section/trees.jpg
 *                 description: Main image for impact item
 *               stats_number:
 *                 type: string
 *                 example: 15,000+
 *               order_position:
 *                 type: integer
 *                 example: 1
 *               is_active:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       200:
 *         description: Impact item updated successfully
 *   delete:
 *     summary: Delete impact item
 *     description: Delete an impact stat/achievement item
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Impact item deleted successfully
 */
const impactController = createGenericController(
  ImpactSection,
  "Impact Section",
);

/**
 * @swagger
 * /api/admin/homepage/impact-section:
 *   get:
 *     summary: Get impact section settings
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Impact section settings retrieved successfully
 *   put:
 *     summary: Update impact section settings
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *                 example: Our Impact
 *               subtitle:
 *                 type: string
 *                 example: See the difference we've made together
 *               image_url:
 *                 type: string
 *                 example: /uploads/impact/hero.jpg
 *     responses:
 *       200:
 *         description: Impact section settings updated successfully
 */
const impactSectionController = {
  get: async (req, res, next) => {
    try {
      const section = await HomeImpactSection.getFirst();
      return require("../utils/response").successResponse(
        res,
        section,
        "Impact section settings retrieved",
      );
    } catch (error) {
      next(error);
    }
  },
  update: async (req, res, next) => {
    try {
      const section = await HomeImpactSection.getFirst();
      const updated = await HomeImpactSection.update(
        section?.id || 1,
        req.body,
      );
      return require("../utils/response").successResponse(
        res,
        updated,
        "Impact section settings updated",
      );
    } catch (error) {
      next(error);
    }
  },
};

/**
 * @swagger
 * /api/admin/about/history:
 *   get:
 *     summary: Get all history records
 *     tags:
 *       - Admin - About
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: History records retrieved successfully
 *   post:
 *     summary: Create new history record
 *     tags:
 *       - Admin - About
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - year
 *               - title
 *               - content
 *             properties:
 *               year:
 *                 type: integer
 *                 example: 2024
 *               title:
 *                 type: string
 *                 example: Foundation Year
 *               subtitle:
 *                 type: string
 *                 example: The beginning of our journey
 *               content:
 *                 type: string
 *                 example: Semesta Lestari was founded with a vision...
 *               image_url:
 *                 type: string
 *                 example: /uploads/history/2024.jpg
 *               order_position:
 *                 type: integer
 *                 example: 1
 *               is_active:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       201:
 *         description: History record created successfully
 */
/**
 * @swagger
 * /api/admin/about/history/{id}:
 *   put:
 *     summary: Update history record
 *     tags:
 *       - Admin - About
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               year:
 *                 type: integer
 *                 example: 2024
 *               title:
 *                 type: string
 *                 example: Foundation Year
 *               subtitle:
 *                 type: string
 *                 example: The beginning of our journey
 *               content:
 *                 type: string
 *                 example: Semesta Lestari was founded with a vision...
 *               image_url:
 *                 type: string
 *                 example: /uploads/history/2024.jpg
 *               order_position:
 *                 type: integer
 *                 example: 1
 *               is_active:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       200:
 *         description: History record updated successfully
 *   delete:
 *     summary: Delete history record
 *     tags:
 *       - Admin - About
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: History record deleted successfully
 */
const historyController = createGenericController(History, "History");

/**
 * @swagger
 * /api/admin/about/history-section:
 *   get:
 *     summary: Get history section settings
 *     tags:
 *       - Admin - About
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: History section settings retrieved successfully
 *   put:
 *     summary: Update history section settings
 *     tags:
 *       - Admin - About
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *                 example: Our History
 *               subtitle:
 *                 type: string
 *                 example: The journey of environmental conservation
 *               image_url:
 *                 type: string
 *                 example: /uploads/history/hero.jpg
 *     responses:
 *       200:
 *         description: History section settings updated successfully
 */
const historySectionController = {
  get: async (req, res, next) => {
    try {
      const section = await require('../models/HistorySection').getFirst();
      return require("../utils/response").successResponse(
        res,
        section,
        "History section settings retrieved",
      );
    } catch (error) {
      next(error);
    }
  },
  update: async (req, res, next) => {
    try {
      const section = await require('../models/HistorySection').getFirst();
      const updated = await require('../models/HistorySection').update(
        section?.id || 1,
        req.body,
      );
      return require("../utils/response").successResponse(
        res,
        updated,
        "History section settings updated",
      );
    } catch (error) {
      next(error);
    }
  },
};

/**
 * @swagger
 * /api/admin/about/leadership-section:
 *   get:
 *     summary: Get leadership section settings
 *     tags:
 *       - Admin - About
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Leadership section settings retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 data:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                     title:
 *                       type: string
 *                       example: Our Leadership
 *                     subtitle:
 *                       type: string
 *                       example: Meet the team driving environmental change
 *                     image_url:
 *                       type: string
 *                       nullable: true
 *                       example: /uploads/leadership/hero.jpg
 *                     is_active:
 *                       type: boolean
 *   put:
 *     summary: Update leadership section settings
 *     tags:
 *       - Admin - About
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *                 example: Our Leadership
 *               subtitle:
 *                 type: string
 *                 example: Meet the team driving environmental change
 *               image_url:
 *                 type: string
 *                 example: /uploads/leadership/hero.jpg
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Leadership section settings updated successfully
 */
const leadershipSectionController = {
  get: async (req, res, next) => {
    try {
      const section = await require('../models/LeadershipSection').getFirst();
      return require("../utils/response").successResponse(
        res,
        section,
        "Leadership section settings retrieved",
      );
    } catch (error) {
      next(error);
    }
  },
  update: async (req, res, next) => {
    try {
      const section = await require('../models/LeadershipSection').getFirst();
      const updated = await require('../models/LeadershipSection').update(
        section?.id || 1,
        req.body,
      );
      return require("../utils/response").successResponse(
        res,
        updated,
        "Leadership section settings updated",
      );
    } catch (error) {
      next(error);
    }
  },
};

/**
 * @swagger
 * /api/admin/about/leadership:
 *   get:
 *     summary: Get all leadership members
 *     tags:
 *       - Admin - About
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Leadership members retrieved successfully
 *   post:
 *     summary: Create new leadership member
 *     tags:
 *       - Admin - About
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - position
 *             properties:
 *               name:
 *                 type: string
 *               position:
 *                 type: string
 *               bio:
 *                 type: string
 *               image_url:
 *                 type: string
 *               email:
 *                 type: string
 *               phone:
 *                 type: string
 *               linkedin_link:
 *                 type: string
 *               instagram_link:
 *                 type: string
 *               is_highlighted:
 *                 type: boolean
 *                 description: Mark this member as highlighted/featured
 *               order_position:
 *                 type: integer
 *               is_active:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: Leadership member created successfully
 */
/**
 * @swagger
 * /api/admin/about/leadership/{id}:
 *   put:
 *     summary: Update leadership member
 *     tags:
 *       - Admin - About
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               position:
 *                 type: string
 *               bio:
 *                 type: string
 *               image_url:
 *                 type: string
 *               email:
 *                 type: string
 *               phone:
 *                 type: string
 *               linkedin_link:
 *                 type: string
 *               instagram_link:
 *                 type: string
 *               is_highlighted:
 *                 type: boolean
 *                 description: Mark this member as highlighted/featured
 *               order_position:
 *                 type: integer
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Leadership member updated successfully
 *   delete:
 *     summary: Delete leadership member
 *     tags:
 *       - Admin - About
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Leadership member deleted successfully
 */
const leadershipController = createGenericController(Leadership, "Leadership");

/**
 * @swagger
 * /api/admin/homepage/donation-cta:
 *   get:
 *     summary: Get donation CTA section
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Donation CTA retrieved successfully
 *   put:
 *     summary: Update donation CTA section
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               button_text:
 *                 type: string
 *               button_url:
 *                 type: string
 *               button_text_2:
 *                 type: string
 *               button_url_2:
 *                 type: string
 *               image_url:
 *                 type: string
 *                 description: Main image for donation CTA section
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Donation CTA updated successfully
 */
// Donation CTA
const donationCtaController = {
  get: async (req, res, next) => {
    try {
      const cta = await DonationCTA.getFirst();
      return require("../utils/response").successResponse(
        res,
        cta,
        "Donation CTA retrieved",
      );
    } catch (error) {
      next(error);
    }
  },
  update: async (req, res, next) => {
    try {
      const cta = await DonationCTA.getFirst();
      const updated = await DonationCTA.update(
        cta?.id || req.params.id,
        req.body,
      );
      return require("../utils/response").successResponse(
        res,
        updated,
        "Donation CTA updated",
      );
    } catch (error) {
      next(error);
    }
  },
};

/**
 * @swagger
 * /api/admin/homepage/closing-cta:
 *   get:
 *     summary: Get closing CTA section
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Closing CTA retrieved successfully
 *   put:
 *     summary: Update closing CTA section
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               button_text:
 *                 type: string
 *               button_url:
 *                 type: string
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Closing CTA updated successfully
 */
// Closing CTA
const closingCtaController = {
  get: async (req, res, next) => {
    try {
      const cta = await ClosingCTA.getFirst();
      return require("../utils/response").successResponse(
        res,
        cta,
        "Closing CTA retrieved",
      );
    } catch (error) {
      next(error);
    }
  },
  update: async (req, res, next) => {
    try {
      const cta = await ClosingCTA.getFirst();
      const updated = await ClosingCTA.update(
        cta?.id || req.params.id,
        req.body,
      );
      return require("../utils/response").successResponse(
        res,
        updated,
        "Closing CTA updated",
      );
    } catch (error) {
      next(error);
    }
  },
};

/**
 * @swagger
 * /api/admin/homepage/statistics:
 *   get:
 *     summary: Get home statistics
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Statistics retrieved successfully
 *   put:
 *     summary: Update home statistics
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               subtitle:
 *                 type: string
 *               trees_planted:
 *                 type: string
 *               volunteers:
 *                 type: string
 *               areas_covered:
 *                 type: string
 *               partners_count:
 *                 type: string
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Statistics updated successfully
 */
// Statistics controller
const statisticsController = {
  get: async (req, res, next) => {
    try {
      const stats = await HomeStatistics.getFirst();
      return require("../utils/response").successResponse(
        res,
        stats,
        "Statistics retrieved",
      );
    } catch (error) {
      next(error);
    }
  },
  update: async (req, res, next) => {
    try {
      const stats = await HomeStatistics.getFirst();
      const updated = await HomeStatistics.update(stats?.id || 1, req.body);
      return require("../utils/response").successResponse(
        res,
        updated,
        "Statistics updated",
      );
    } catch (error) {
      next(error);
    }
  },
};

/**
 * @swagger
 * /api/admin/homepage/programs-section:
 *   get:
 *     summary: Get programs section header
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Programs section retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 data:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                     title:
 *                       type: string
 *                     subtitle:
 *                       type: string
 *                     is_active:
 *                       type: boolean
 *   put:
 *     summary: Update programs section header
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *                 example: Our Programs
 *               subtitle:
 *                 type: string
 *                 example: Making a difference through various initiatives
 *               is_active:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       200:
 *         description: Programs section updated successfully
 */
const programsSectionController = {
  get: async (req, res, next) => {
    try {
      const section = await HomeProgramsSection.getFirst();
      return require("../utils/response").successResponse(
        res,
        section,
        "Programs section retrieved",
      );
    } catch (error) {
      next(error);
    }
  },
  update: async (req, res, next) => {
    try {
      const section = await HomeProgramsSection.getFirst();
      const updated = await HomeProgramsSection.update(
        section?.id || 1,
        req.body,
      );
      return require("../utils/response").successResponse(
        res,
        updated,
        "Programs section updated",
      );
    } catch (error) {
      next(error);
    }
  },
};

/**
 * @swagger
 * /api/admin/homepage/partners-section:
 *   get:
 *     summary: Get partners section header
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Partners section retrieved successfully
 *   put:
 *     summary: Update partners section header
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *                 example: Our Partners
 *               subtitle:
 *                 type: string
 *                 example: Working together for a sustainable future
 *               image_url:
 *                 type: string
 *                 example: /uploads/partners/hero.jpg
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Partners section updated successfully
 */
const partnersSectionController = {
  get: async (req, res, next) => {
    try {
      const section = await HomePartnersSection.getFirst();
      return require("../utils/response").successResponse(
        res,
        section,
        "Partners section retrieved",
      );
    } catch (error) {
      next(error);
    }
  },
  update: async (req, res, next) => {
    try {
      const section = await HomePartnersSection.getFirst();
      const updated = await HomePartnersSection.update(
        section?.id || 1,
        req.body,
      );
      return require("../utils/response").successResponse(
        res,
        updated,
        "Partners section updated",
      );
    } catch (error) {
      next(error);
    }
  },
};

/**
 * @swagger
 * /api/admin/homepage/faq-section:
 *   get:
 *     summary: Get FAQ section header
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: FAQ section retrieved successfully
 *   put:
 *     summary: Update FAQ section header
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *                 example: Frequently Asked Questions
 *               subtitle:
 *                 type: string
 *                 example: Find answers to common questions
 *               image_url:
 *                 type: string
 *                 example: /uploads/faqs/hero.jpg
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: FAQ section updated successfully
 */
const faqSectionController = {
  get: async (req, res, next) => {
    try {
      const section = await HomeFaqSection.getFirst();
      // Include all FAQs (admin view) by default
      const faqs = await FAQ.findAll(null);
      return require("../utils/response").successResponse(
        res,
        { section, items: faqs },
        "FAQ section retrieved",
      );
    } catch (error) {
      next(error);
    }
  },
  update: async (req, res, next) => {
    try {
      const section = await HomeFaqSection.getFirst();
      const updated = await HomeFaqSection.update(section?.id || 1, req.body);
      return require("../utils/response").successResponse(
        res,
        updated,
        "FAQ section updated",
      );
    } catch (error) {
      next(error);
    }
  },
};

/**
 * @swagger
 * /api/admin/homepage/contact-section:
 *   get:
 *     summary: Get contact section
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Contact section retrieved successfully
 *   put:
 *     summary: Update contact section
 *     tags:
 *       - Admin - Homepage
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               address:
 *                 type: string
 *               email:
 *                 type: string
 *               phone:
 *                 type: string
 *               work_hours:
 *                 type: string
 *               is_active:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Contact section updated successfully
 */
// Contact section now uses HomeContactSection model
const contactSectionController = {
  get: async (req, res, next) => {
    try {
      const section = await require('../models/HomeContactSection').getFirst();
      return require("../utils/response").successResponse(
        res,
        section,
        "Contact section settings retrieved",
      );
    } catch (error) {
      next(error);
    }
  },
  update: async (req, res, next) => {
    try {
      const section = await require('../models/HomeContactSection').getFirst();
      const updated = await require('../models/HomeContactSection').update(
        section?.id || 1,
        req.body,
      );
      return require("../utils/response").successResponse(
        res,
        updated,
        "Contact section settings updated",
      );
    } catch (error) {
      next(error);
    }
  },
};

module.exports = {
  heroController,
  visionController,
  missionController,
  impactController,
  impactSectionController,
  donationCtaController,
  closingCtaController,
  historyController,
  historySectionController,
  leadershipController,
  leadershipSectionController,
  statisticsController,
  programsSectionController,
  partnersSectionController,
  faqSectionController,
  contactSectionController,
};
