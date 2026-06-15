const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const { getProductReviews, submitReview } = require('../controllers/marketplaceController');
const { verifyToken } = require('../middleware/authMiddleware');

// Route untuk mendapatkan semua produk
// GET /products
router.get('/', productController.getProducts);

// POST /products/validate-checkout
router.post('/validate-checkout', productController.validateCheckout);

// Review routes (called at root-level /products by the frontend)
router.get('/:id/reviews', verifyToken, getProductReviews);
router.post('/:id/reviews', verifyToken, submitReview);

module.exports = router;
