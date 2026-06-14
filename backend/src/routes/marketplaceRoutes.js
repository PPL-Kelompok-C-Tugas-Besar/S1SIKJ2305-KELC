const express = require('express');
const router = express.Router();
const { verifyToken } = require('../middleware/authMiddleware');
const {
  getAllProducts,
  getProductById,
  getProductReviews,
  submitReview,
  getAvailableVouchers,
  createOrder,
  getUserOrders,
  getOrderDetails,
  getWishlist,
  addToWishlist,
  removeFromWishlist,
} = require('../controllers/marketplaceController');

// All routes require token authentication
router.get('/products', verifyToken, getAllProducts);
router.get('/products/:id', verifyToken, getProductById);
router.get('/products/:id/reviews', verifyToken, getProductReviews);
router.post('/products/:id/reviews', verifyToken, submitReview);

// Wishlist
router.get('/wishlist', verifyToken, getWishlist);
router.post('/wishlist', verifyToken, addToWishlist);
router.delete('/wishlist/:productId', verifyToken, removeFromWishlist);

// Vouchers
router.get('/vouchers', verifyToken, getAvailableVouchers);

// Orders
router.post('/orders', verifyToken, createOrder);
router.get('/orders', verifyToken, getUserOrders);
router.get('/orders/:id', verifyToken, getOrderDetails);

module.exports = router;
