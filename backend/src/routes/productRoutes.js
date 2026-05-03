const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');

// Route untuk mendapatkan semua produk
// GET /products
router.get('/', productController.getProducts);

// POST /products/validate-checkout
router.post('/validate-checkout', productController.validateCheckout);

module.exports = router;
