const ContactMessage = require('../models/ContactMessage');
const Settings = require('../models/Settings');
const { successResponse, errorResponse, paginatedResponse } = require('../utils/response');

/**
 * @swagger
 * /api/contact/info:
 *   get:
 *     summary: Get contact page info
 *     tags:
 *       - Contact
 *     responses:
 *       200:
 *         description: Contact info retrieved
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
 *                     email:
 *                       type: string
 *                       example: info@semestalestari.org
 *                     phones:
 *                       type: array
 *                       items:
 *                         type: string
 *                       example: ["+62 123 4567 890", "+62 987 6543 210"]
 *                     address:
 *                       type: string
 *                       example: "Jl. Lingkungan Hijau No. 123, Jakarta Selatan, DKI Jakarta 12345, Indonesia"
 *                     work_hours:
 *                       type: string
 *                       example: "Monday - Friday: 09:00 AM - 05:00 PM"
 */
const getContactInfo = async (req, res, next) => {
  try {
    const [email, phones, address, workHours] = await Promise.all([
      Settings.findByKey('contact_email'),
      Settings.findByKey('contact_phones'),
      Settings.findByKey('contact_address'),
      Settings.findByKey('contact_work_hours')
    ]);
    
    // Parse phones from JSON string to array
    let phonesArray = [];
    if (phones?.value) {
      try {
        phonesArray = JSON.parse(phones.value);
      } catch (e) {
        // If not JSON, treat as single phone
        phonesArray = [phones.value];
      }
    }
    
    return successResponse(res, {
      email: email?.value || '',
      phones: phonesArray,
      address: address?.value || '',
      work_hours: workHours?.value || ''
    }, 'Contact info retrieved');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/contact/send-message:
 *   post:
 *     summary: Submit contact form message
 *     tags:
 *       - Contact
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - message
 *             properties:
 *               name:
 *                 type: string
 *               email:
 *                 type: string
 *               phone:
 *                 type: string
 *               subject:
 *                 type: string
 *               message:
 *                 type: string
 *     responses:
 *       201:
 *         description: Message sent successfully
 */
const sendMessage = async (req, res, next) => {
  try {
    const message = await ContactMessage.create(req.body);
    return successResponse(res, message, 'Message sent successfully', 201);
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/contact/show-messages:
 *   get:
 *     summary: Get all contact messages
 *     tags:
 *       - Admin - Contact
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - name: page
 *         in: query
 *         schema:
 *           type: integer
 *           default: 1
 *       - name: limit
 *         in: query
 *         schema:
 *           type: integer
 *           default: 10
 *     responses:
 *       200:
 *         description: Messages retrieved successfully
 *   post:
 *     summary: Create contact message (admin)
 *     description: Admin can manually create contact messages
 *     tags:
 *       - Admin - Contact
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
 *               - email
 *               - message
 *             properties:
 *               name:
 *                 type: string
 *               email:
 *                 type: string
 *               phone:
 *                 type: string
 *               subject:
 *                 type: string
 *               message:
 *                 type: string
 *     responses:
 *       201:
 *         description: Message created successfully
 */
const getAllMessages = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    
    const { messages, total } = await ContactMessage.findAll(page, limit);
    
    return paginatedResponse(res, messages, page, limit, total, 'Messages retrieved');
  } catch (error) {
    next(error);
  }
};

const createMessage = async (req, res, next) => {
  try {
    const message = await ContactMessage.create(req.body);
    return successResponse(res, message, 'Message created successfully', 201);
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/contact/show-messages/{id}:
 *   get:
 *     summary: Get single contact message
 *     tags:
 *       - Admin - Contact
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
 *         description: Message retrieved successfully
 *   put:
 *     summary: Update contact message
 *     description: Admin can update message details
 *     tags:
 *       - Admin - Contact
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
 *               name:
 *                 type: string
 *               email:
 *                 type: string
 *               phone:
 *                 type: string
 *               subject:
 *                 type: string
 *               message:
 *                 type: string
 *               is_read:
 *                 type: boolean
 *               is_replied:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Message updated successfully
 *   delete:
 *     summary: Delete contact message
 *     tags:
 *       - Admin - Contact
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
 *         description: Message deleted successfully
 */
const getMessageById = async (req, res, next) => {
  try {
    const message = await ContactMessage.findById(req.params.id);
    
    if (!message) {
      return errorResponse(res, 'Message not found', 404);
    }
    
    return successResponse(res, message, 'Message retrieved');
  } catch (error) {
    next(error);
  }
};

const updateMessage = async (req, res, next) => {
  try {
    const message = await ContactMessage.update(req.params.id, req.body);
    
    if (!message) {
      return errorResponse(res, 'Message not found', 404);
    }
    
    return successResponse(res, message, 'Message updated successfully');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/contact/show-messages/{id}/read:
 *   put:
 *     summary: Mark message as read
 *     tags:
 *       - Admin - Contact
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
 *         description: Message marked as read
 */
const markAsRead = async (req, res, next) => {
  try {
    const message = await ContactMessage.markAsRead(req.params.id);
    
    if (!message) {
      return errorResponse(res, 'Message not found', 404);
    }
    
    return successResponse(res, message, 'Message marked as read');
  } catch (error) {
    next(error);
  }
};

const deleteMessage = async (req, res, next) => {
  try {
    const deleted = await ContactMessage.delete(req.params.id);
    
    if (!deleted) {
      return errorResponse(res, 'Message not found', 404);
    }
    
    return successResponse(res, null, 'Message deleted successfully');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/contact/info:
 *   get:
 *     summary: Get contact info (admin)
 *     tags:
 *       - Admin - Contact
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Contact info retrieved
 *   put:
 *     summary: Update contact info
 *     tags:
 *       - Admin - Contact
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               email:
 *                 type: string
 *                 example: info@semestalestari.org
 *               phones:
 *                 type: array
 *                 items:
 *                   type: string
 *                 example: ["+62 123 4567 890", "+62 987 6543 210"]
 *               address:
 *                 type: string
 *                 example: "Jl. Lingkungan Hijau No. 123, Jakarta Selatan"
 *               work_hours:
 *                 type: string
 *                 example: "Monday - Friday: 09:00 AM - 05:00 PM"
 *     responses:
 *       200:
 *         description: Contact info updated successfully
 */
const getContactInfoAdmin = async (req, res, next) => {
  try {
    const [email, phones, address, workHours] = await Promise.all([
      Settings.findByKey('contact_email'),
      Settings.findByKey('contact_phones'),
      Settings.findByKey('contact_address'),
      Settings.findByKey('contact_work_hours')
    ]);
    
    // Parse phones from JSON string to array
    let phonesArray = [];
    if (phones?.value) {
      try {
        phonesArray = JSON.parse(phones.value);
      } catch (e) {
        phonesArray = [phones.value];
      }
    }
    
    return successResponse(res, {
      email: email?.value || '',
      phones: phonesArray,
      address: address?.value || '',
      work_hours: workHours?.value || ''
    }, 'Contact info retrieved');
  } catch (error) {
    next(error);
  }
};

const updateContactInfo = async (req, res, next) => {
  try {
    const { email, phones, address, work_hours } = req.body;
    
    const updates = [];
    
    if (email !== undefined) {
      updates.push(Settings.upsert('contact_email', email));
    }
    
    if (phones !== undefined) {
      // Store phones as JSON array
      const phonesJson = JSON.stringify(phones);
      updates.push(Settings.upsert('contact_phones', phonesJson));
    }
    
    if (address !== undefined) {
      updates.push(Settings.upsert('contact_address', address));
    }
    
    if (work_hours !== undefined) {
      updates.push(Settings.upsert('contact_work_hours', work_hours));
    }
    
    await Promise.all(updates);
    
    // Return updated data
    const [emailData, phonesData, addressData, workHoursData] = await Promise.all([
      Settings.findByKey('contact_email'),
      Settings.findByKey('contact_phones'),
      Settings.findByKey('contact_address'),
      Settings.findByKey('contact_work_hours')
    ]);
    
    let phonesArray = [];
    if (phonesData?.value) {
      try {
        phonesArray = JSON.parse(phonesData.value);
      } catch (e) {
        phonesArray = [phonesData.value];
      }
    }
    
    return successResponse(res, {
      email: emailData?.value || '',
      phones: phonesArray,
      address: addressData?.value || '',
      work_hours: workHoursData?.value || ''
    }, 'Contact info updated successfully');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getContactInfo,
  sendMessage,
  getAllMessages,
  createMessage,
  getMessageById,
  updateMessage,
  markAsRead,
  deleteMessage,
  getContactInfoAdmin,
  updateContactInfo
};
