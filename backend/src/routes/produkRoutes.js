const express = require('express');
const router = express.Router();
const { searchProducts } = require('../controllers/produkController');

// Define search route
router.get('/search', searchProducts);

module.exports = router;
