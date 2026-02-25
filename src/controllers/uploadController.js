const { successResponse, errorResponse } = require('../utils/response');
const { deleteFile, getFilePathFromUrl } = require('../middleware/upload');
const { pool } = require('../config/database');

/**
 * @swagger
 * /api/admin/upload/{entity}:
 *   post:
 *     summary: Upload an image for a specific entity
 *     description: Upload an image file and get the URL back. The image is saved locally in the uploads directory.
 *     tags:
 *       - Admin - Upload
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: entity
 *         required: true
 *         schema:
 *           type: string
 *           enum: [articles, awards, gallery, merchandise, programs, partners, leadership, history, pages, hero, donation, closing, impact_section, vision, donation_cta]
 *         description: Entity type for organizing uploads
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - image
 *             properties:
 *               image:
 *                 type: string
 *                 format: binary
 *                 description: Image file (JPEG, PNG, GIF, WebP, max 5MB)
 *     responses:
 *       200:
 *         description: Image uploaded successfully
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
 *                   example: Image uploaded successfully
 *                 data:
 *                   type: object
 *                   properties:
 *                     url:
 *                       type: string
 *                       example: /uploads/articles/image-1234567890.jpg
 *                     filename:
 *                       type: string
 *                       example: image-1234567890.jpg
 *                     path:
 *                       type: string
 *                       example: uploads/articles/image-1234567890.jpg
 *       400:
 *         description: No file uploaded or invalid file type
 *       401:
 *         description: Unauthorized
 */
const uploadImage = async (req, res, next) => {
  try {
    if (!req.file) {
      return errorResponse(res, 'No file uploaded', 400);
    }

    const entity = req.params.entity || 'general';
    const baseUrl = `${req.protocol}://${req.get('host')}`;
    const fileUrl = `/uploads/${entity}/${req.file.filename}`;

    return successResponse(res, {
      url: fileUrl,
      fullUrl: `${baseUrl}${fileUrl}`,
      filename: req.file.filename,
      path: req.file.path,
      size: req.file.size,
      mimetype: req.file.mimetype
    }, 'Image uploaded successfully');
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/upload/multiple/{entity}:
 *   post:
 *     summary: Upload multiple images for a specific entity
 *     description: Upload multiple image files at once (max 10 files)
 *     tags:
 *       - Admin - Upload
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: entity
 *         required: true
 *         schema:
 *           type: string
 *           enum: [articles, awards, gallery, merchandise, programs, partners, leadership, history, pages, hero, donation, closing, impact_section, vision, donation_cta]
 *         description: Entity type for organizing uploads
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - images
 *             properties:
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *                 description: Image files (max 10 files, each max 5MB)
 *     responses:
 *       200:
 *         description: Images uploaded successfully
 *       400:
 *         description: No files uploaded
 *       401:
 *         description: Unauthorized
 */
const uploadMultipleImages = async (req, res, next) => {
  try {
    if (!req.files || req.files.length === 0) {
      return errorResponse(res, 'No files uploaded', 400);
    }

    const entity = req.params.entity || 'general';
    const baseUrl = `${req.protocol}://${req.get('host')}`;
    
    const uploadedFiles = req.files.map(file => ({
      url: `/uploads/${entity}/${file.filename}`,
      fullUrl: `${baseUrl}/uploads/${entity}/${file.filename}`,
      filename: file.filename,
      path: file.path,
      size: file.size,
      mimetype: file.mimetype
    }));

    return successResponse(res, {
      files: uploadedFiles,
      count: uploadedFiles.length
    }, `${uploadedFiles.length} image(s) uploaded successfully`);
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/upload:
 *   delete:
 *     summary: Delete an uploaded image
 *     description: Delete an image file from the server
 *     tags:
 *       - Admin - Upload
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - url
 *             properties:
 *               url:
 *                 type: string
 *                 example: /uploads/articles/image-1234567890.jpg
 *                 description: URL or path of the image to delete
 *     responses:
 *       200:
 *         description: Image deleted successfully
 *       400:
 *         description: URL is required
 *       404:
 *         description: File not found
 *       401:
 *         description: Unauthorized
 */
const deleteImage = async (req, res, next) => {
  try {
    const { url } = req.body;

    if (!url) {
      return errorResponse(res, 'Image URL is required', 400);
    }

    const filePath = getFilePathFromUrl(url);
    
    if (!filePath) {
      return errorResponse(res, 'Invalid URL', 400);
    }

    const deleted = deleteFile(filePath);

    if (deleted) {
      return successResponse(res, null, 'Image deleted successfully');
    } else {
      return errorResponse(res, 'File not found or already deleted', 404);
    }
  } catch (error) {
    next(error);
  }
};

/**
 * @swagger
 * /api/admin/upload/replace/{entity}:
 *   post:
 *     summary: Replace an existing image with a new one
 *     description: Upload a new image and automatically delete the old one. This is a convenience endpoint that combines upload and delete operations.
 *     tags:
 *       - Admin - Upload
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: entity
 *         required: true
 *         schema:
 *           type: string
 *           enum: [articles, awards, gallery, merchandise, programs, partners, leadership, history, pages, hero, donation, closing, impact_section, vision, donation_cta]
 *         description: Entity type for organizing uploads
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - image
 *               - oldImageUrl
 *             properties:
 *               image:
 *                 type: string
 *                 format: binary
 *                 description: New image file (JPEG, PNG, GIF, WebP, max 5MB)
 *               oldImageUrl:
 *                 type: string
 *                 description: URL of the old image to delete
 *                 example: /uploads/articles/old-image-123.jpg
 *     responses:
 *       200:
 *         description: Image replaced successfully
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
 *                   example: Image replaced successfully
 *                 data:
 *                   type: object
 *                   properties:
 *                     newImage:
 *                       type: object
 *                       properties:
 *                         url:
 *                           type: string
 *                           example: /uploads/articles/new-image-1234567890.jpg
 *                         fullUrl:
 *                           type: string
 *                           example: http://localhost:3000/uploads/articles/new-image-1234567890.jpg
 *                         filename:
 *                           type: string
 *                           example: new-image-1234567890.jpg
 *                         size:
 *                           type: integer
 *                           example: 45678
 *                         mimetype:
 *                           type: string
 *                           example: image/jpeg
 *                     oldImageDeleted:
 *                       type: boolean
 *                       example: true
 *       400:
 *         description: No file uploaded or old image URL missing
 *       401:
 *         description: Unauthorized
 */
const replaceImage = async (req, res, next) => {
  try {
    // Check if new file is uploaded
    if (!req.file) {
      return errorResponse(res, 'No file uploaded', 400);
    }

    // Check if old image URL is provided
    const oldImageUrl = req.body.oldImageUrl;
    if (!oldImageUrl) {
      return errorResponse(res, 'Old image URL is required', 400);
    }

    const entity = req.params.entity || 'general';
    const baseUrl = `${req.protocol}://${req.get('host')}`;
    const newFileUrl = `/uploads/${entity}/${req.file.filename}`;

    // Prepare new image data
    const newImageData = {
      url: newFileUrl,
      fullUrl: `${baseUrl}${newFileUrl}`,
      filename: req.file.filename,
      path: req.file.path,
      size: req.file.size,
      mimetype: req.file.mimetype
    };

    // Try to delete old image
    let oldImageDeleted = false;
    const oldFilePath = getFilePathFromUrl(oldImageUrl);
    
    if (oldFilePath) {
      oldImageDeleted = deleteFile(oldFilePath);
    }

    return successResponse(res, {
      newImage: newImageData,
      oldImageDeleted: oldImageDeleted,
      oldImageUrl: oldImageUrl
    }, 'Image replaced successfully');
  } catch (error) {
    next(error);
  }
};

/**
 * Helper function to update image URL in database
 * This is used by other controllers when updating entities with images
 */
const updateEntityImage = async (tableName, entityId, imageUrl, imageField = 'image_url') => {
  try {
    // Get old image URL
    const [rows] = await pool.query(
      `SELECT ${imageField} FROM ${tableName} WHERE id = ?`,
      [entityId]
    );

    const oldImageUrl = rows[0]?.[imageField];

    // Update with new image URL
    await pool.query(
      `UPDATE ${tableName} SET ${imageField} = ? WHERE id = ?`,
      [imageUrl, entityId]
    );

    // Delete old image if it exists and is different
    if (oldImageUrl && oldImageUrl !== imageUrl) {
      const oldFilePath = getFilePathFromUrl(oldImageUrl);
      if (oldFilePath) {
        deleteFile(oldFilePath);
      }
    }

    return true;
  } catch (error) {
    console.error('Error updating entity image:', error);
    return false;
  }
};

module.exports = {
  uploadImage,
  uploadMultipleImages,
  deleteImage,
  replaceImage,
  updateEntityImage
};
