const Settings = require('../models/Settings');
const ProgramCategory = require('../models/ProgramCategory');
const { successResponse } = require('../utils/response');

/**
 * @swagger
 * /api/footer:
 *   get:
 *     summary: Get footer data
 *     description: Returns all data needed for the website footer including contact information, social media links, and program categories
 *     tags:
 *       - Footer
 *     responses:
 *       200:
 *         description: Footer data retrieved successfully
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
 *                   example: Footer data retrieved
 *                 data:
 *                   type: object
 *                   properties:
 *                     contact:
 *                       type: object
 *                       properties:
 *                         email:
 *                           type: string
 *                           example: info@semestalestari.org
 *                         phones:
 *                           type: array
 *                           items:
 *                             type: string
 *                           example: ["(+62) 21-1234-5678", "(+62) 812-3456-7890"]
 *                         address:
 *                           type: string
 *                           example: Jl. Lingkungan Hijau No. 123, Jakarta Selatan
 *                         work_hours:
 *                           type: string
 *                           example: Monday - Friday 09:00 AM - 05:00 PM
 *                     social_media:
 *                       type: object
 *                       properties:
 *                         facebook:
 *                           type: string
 *                           example: https://facebook.com/semestalestari
 *                         instagram:
 *                           type: string
 *                           example: https://instagram.com/semestalestari
 *                         twitter:
 *                           type: string
 *                           example: https://twitter.com/semestalestari
 *                         youtube:
 *                           type: string
 *                           example: https://youtube.com/@semestalestari
 *                         linkedin:
 *                           type: string
 *                           example: https://linkedin.com/company/semestalestari
 *                         tiktok:
 *                           type: string
 *                           example: https://tiktok.com/@semestalestari
 *                     program_categories:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: integer
 *                           name:
 *                             type: string
 *                           slug:
 *                             type: string
 *                           description:
 *                             type: string
 *                           icon:
 *                             type: string
 *                           order_position:
 *                             type: integer
 */
const getFooterData = async (req, res, next) => {
  try {
    // Fetch all settings in parallel
    const [
      contactEmail,
      contactPhones,
      contactAddress,
      contactWorkHours,
      socialFacebook,
      socialInstagram,
      socialTwitter,
      socialYoutube,
      socialLinkedin,
      socialTiktok,
      programCategories
    ] = await Promise.all([
      Settings.findByKey('contact_email'),
      Settings.findByKey('contact_phones'),
      Settings.findByKey('contact_address'),
      Settings.findByKey('contact_work_hours'),
      Settings.findByKey('social_facebook'),
      Settings.findByKey('social_instagram'),
      Settings.findByKey('social_twitter'),
      Settings.findByKey('social_youtube'),
      Settings.findByKey('social_linkedin'),
      Settings.findByKey('social_tiktok'),
      ProgramCategory.findAll(true)
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
    
    const footerData = {
      contact: {
        email: contactEmail?.value || '',
        phones: phonesArray,
        address: contactAddress?.value || '',
        work_hours: contactWorkHours?.value || ''
      },
      social_media: {
        facebook: socialFacebook?.value || '',
        instagram: socialInstagram?.value || '',
        twitter: socialTwitter?.value || '',
        youtube: socialYoutube?.value || '',
        linkedin: socialLinkedin?.value || '',
        tiktok: socialTiktok?.value || ''
      },
      program_categories: programCategories
    };
    
    return successResponse(res, footerData, 'Footer data retrieved');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getFooterData
};
