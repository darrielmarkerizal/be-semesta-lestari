const express = require('express');
const router = express.Router();

const publicRoutes = require('./public');
const adminRoutes = require('./admin');

// Mount routes
router.use('/', publicRoutes);
router.use('/admin', adminRoutes);

module.exports = router;
