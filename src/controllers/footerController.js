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
 *                         gmaps:
 *                           type: string
 *                           example: https://maps.google.com/?q=-6.200000,106.816666
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
      contactGmaps,
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
      Settings.findByKey('contact_gmaps'),
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
        work_hours: contactWorkHours?.value || '',
        gmaps: contactGmaps?.value || ''
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

/**
 * @swagger
 * /api/admin/footer:
 *   get:
 *     summary: Get footer settings for admin
 *     description: Retrieve all footer-related settings including contact information and social media links in a structured format for admin management
 *     tags:
 *       - Admin - Footer
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Footer settings retrieved successfully
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
 *                   example: Footer settings retrieved
 *                 data:
 *                   type: object
 *                   properties:
 *                     contact:
 *                       type: object
 *                       properties:
 *                         email:
 *                           type: object
 *                           properties:
 *                             key:
 *                               type: string
 *                               example: contact_email
 *                             value:
 *                               type: string
 *                               example: info@semestalestari.com
 *                         phones:
 *                           type: object
 *                           properties:
 *                             key:
 *                               type: string
 *                               example: contact_phones
 *                             value:
 *                               type: string
 *                               example: '["(+62) 21-1234-5678", "(+62) 812-3456-7890"]'
 *                         address:
 *                           type: object
 *                           properties:
 *                             key:
 *                               type: string
 *                               example: contact_address
 *                             value:
 *                               type: string
 *                               example: Jl. Lingkungan Hijau No. 123, Jakarta
 *                         work_hours:
 *                           type: object
 *                           properties:
 *                             key:
 *                               type: string
 *                               example: contact_work_hours
 *                             value:
 *                               type: string
 *                               example: Monday - Friday 9:00 AM - 5:00 PM
 *                         gmaps:
 *                           type: object
 *                           properties:
 *                             key:
 *                               type: string
 *                               example: contact_gmaps
 *                             value:
 *                               type: string
 *                               example: https://maps.google.com/?q=-6.200000,106.816666
 *                     social_media:
 *                       type: object
 *                       properties:
 *                         facebook:
 *                           type: object
 *                           properties:
 *                             key:
 *                               type: string
 *                               example: social_facebook
 *                             value:
 *                               type: string
 *                               example: https://facebook.com/semestalestari
 *                         instagram:
 *                           type: object
 *                           properties:
 *                             key:
 *                               type: string
 *                               example: social_instagram
 *                             value:
 *                               type: string
 *                               example: https://instagram.com/semestalestari
 *                         twitter:
 *                           type: object
 *                           properties:
 *                             key:
 *                               type: string
 *                               example: social_twitter
 *                             value:
 *                               type: string
 *                               example: https://twitter.com/semestalestari
 *                         youtube:
 *                           type: object
 *                           properties:
 *                             key:
 *                               type: string
 *                               example: social_youtube
 *                             value:
 *                               type: string
 *                               example: https://youtube.com/@semestalestari
 *                         linkedin:
 *                           type: object
 *                           properties:
 *                             key:
 *                               type: string
 *                               example: social_linkedin
 *                             value:
 *                               type: string
 *                               example: https://linkedin.com/company/semestalestari
 *                         tiktok:
 *                           type: object
 *                           properties:
 *                             key:
 *                               type: string
 *                               example: social_tiktok
 *                             value:
 *                               type: string
 *                               example: https://tiktok.com/@semestalestari
 *       401:
 *         description: Unauthorized
 *   put:
 *     summary: Update footer settings
 *     description: Update multiple footer settings at once. Provide only the fields you want to update.
 *     tags:
 *       - Admin - Footer
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               contact:
 *                 type: object
 *                 properties:
 *                   email:
 *                     type: string
 *                     example: info@semestalestari.com
 *                   phones:
 *                     type: string
 *                     description: JSON array as string
 *                     example: '["(+62) 21-1234-5678", "(+62) 812-3456-7890"]'
 *                   address:
 *                     type: string
 *                     example: Jl. Lingkungan Hijau No. 123, Jakarta
 *                   work_hours:
 *                     type: string
 *                     example: Monday - Friday 9:00 AM - 5:00 PM
 *                   gmaps:
 *                     type: string
 *                     example: https://maps.google.com/?q=-6.200000,106.816666
 *               social_media:
 *                 type: object
 *                 properties:
 *                   facebook:
 *                     type: string
 *                     example: https://facebook.com/semestalestari
 *                   instagram:
 *                     type: string
 *                     example: https://instagram.com/semestalestari
 *                   twitter:
 *                     type: string
 *                     example: https://twitter.com/semestalestari
 *                   youtube:
 *                     type: string
 *                     example: https://youtube.com/@semestalestari
 *                   linkedin:
 *                     type: string
 *                     example: https://linkedin.com/company/semestalestari
 *                   tiktok:
 *                     type: string
 *                     example: https://tiktok.com/@semestalestari
 *           examples:
 *             update_contact:
 *               summary: Update contact information only
 *               value:
 *                 contact:
 *                   email: newemail@semestalestari.com
 *                   phones: '["(+62) 21-9999-8888"]'
 *                   gmaps: https://maps.google.com/?q=-6.200000,106.816666
 *             update_social:
 *               summary: Update social media links only
 *               value:
 *                 social_media:
 *                   facebook: https://facebook.com/newsemestalestari
 *                   instagram: https://instagram.com/newsemestalestari
 *             update_all:
 *               summary: Update all footer settings
 *               value:
 *                 contact:
 *                   email: info@semestalestari.com
 *                   phones: '["(+62) 21-1234-5678"]'
 *                   address: Jl. Lingkungan Hijau No. 123
 *                   work_hours: Monday - Friday 9:00 AM - 5:00 PM
 *                   gmaps: https://maps.google.com/?q=-6.200000,106.816666
 *                 social_media:
 *                   facebook: https://facebook.com/semestalestari
 *                   instagram: https://instagram.com/semestalestari
 *     responses:
 *       200:
 *         description: Footer settings updated successfully
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
 *                   example: Footer settings updated successfully
 *                 data:
 *                   type: object
 *                   properties:
 *                     updated:
 *                       type: array
 *                       items:
 *                         type: string
 *                       example: ["contact_email", "social_facebook"]
 *       401:
 *         description: Unauthorized
 */
const getFooterAdmin = async (req, res, next) => {
  try {
    // Fetch all footer-related settings
    const [
      contactEmail,
      contactPhones,
      contactAddress,
      contactWorkHours,
      contactGmaps,
      socialFacebook,
      socialInstagram,
      socialTwitter,
      socialYoutube,
      socialLinkedin,
      socialTiktok
    ] = await Promise.all([
      Settings.findByKey('contact_email'),
      Settings.findByKey('contact_phones'),
      Settings.findByKey('contact_address'),
      Settings.findByKey('contact_work_hours'),
      Settings.findByKey('contact_gmaps'),
      Settings.findByKey('social_facebook'),
      Settings.findByKey('social_instagram'),
      Settings.findByKey('social_twitter'),
      Settings.findByKey('social_youtube'),
      Settings.findByKey('social_linkedin'),
      Settings.findByKey('social_tiktok')
    ]);
    
    const footerSettings = {
      contact: {
        email: contactEmail || { key: 'contact_email', value: '' },
        phones: contactPhones || { key: 'contact_phones', value: '[]' },
        address: contactAddress || { key: 'contact_address', value: '' },
        work_hours: contactWorkHours || { key: 'contact_work_hours', value: '' },
        gmaps: contactGmaps || { key: 'contact_gmaps', value: '' }
      },
      social_media: {
        facebook: socialFacebook || { key: 'social_facebook', value: '' },
        instagram: socialInstagram || { key: 'social_instagram', value: '' },
        twitter: socialTwitter || { key: 'social_twitter', value: '' },
        youtube: socialYoutube || { key: 'social_youtube', value: '' },
        linkedin: socialLinkedin || { key: 'social_linkedin', value: '' },
        tiktok: socialTiktok || { key: 'social_tiktok', value: '' }
      }
    };
    
    return successResponse(res, footerSettings, 'Footer settings retrieved');
  } catch (error) {
    next(error);
  }
};

const updateFooterAdmin = async (req, res, next) => {
  try {
    const { contact, social_media } = req.body;
    const updated = [];
    
    // Update contact information
    if (contact) {
      if (contact.email !== undefined) {
        await Settings.upsert('contact_email', contact.email);
        updated.push('contact_email');
      }
      if (contact.phones !== undefined) {
        await Settings.upsert('contact_phones', contact.phones);
        updated.push('contact_phones');
      }
      if (contact.address !== undefined) {
        await Settings.upsert('contact_address', contact.address);
        updated.push('contact_address');
      }
      if (contact.work_hours !== undefined) {
        await Settings.upsert('contact_work_hours', contact.work_hours);
        updated.push('contact_work_hours');
      }
      if (contact.gmaps !== undefined) {
        await Settings.upsert('contact_gmaps', contact.gmaps);
        updated.push('contact_gmaps');
      }
    }
    
    // Update social media links
    if (social_media) {
      if (social_media.facebook !== undefined) {
        await Settings.upsert('social_facebook', social_media.facebook);
        updated.push('social_facebook');
      }
      if (social_media.instagram !== undefined) {
        await Settings.upsert('social_instagram', social_media.instagram);
        updated.push('social_instagram');
      }
      if (social_media.twitter !== undefined) {
        await Settings.upsert('social_twitter', social_media.twitter);
        updated.push('social_twitter');
      }
      if (social_media.youtube !== undefined) {
        await Settings.upsert('social_youtube', social_media.youtube);
        updated.push('social_youtube');
      }
      if (social_media.linkedin !== undefined) {
        await Settings.upsert('social_linkedin', social_media.linkedin);
        updated.push('social_linkedin');
      }
      if (social_media.tiktok !== undefined) {
        await Settings.upsert('social_tiktok', social_media.tiktok);
        updated.push('social_tiktok');
      }
    }
    
    return successResponse(
      res,
      { updated },
      'Footer settings updated successfully'
    );
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getFooterData,
  getFooterAdmin,
  updateFooterAdmin
};
