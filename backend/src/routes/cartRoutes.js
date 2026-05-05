const express = require('express');
const router = express.Router();
const { addToCart, getCart, updateCartItem, removeCartItem, clearCart } = require('../controllers/cartController');
const { verifyToken } = require('../middleware/authMiddleware');

// Validasi token untuk semua route
router.use(verifyToken);

router.post('/', addToCart);
router.get('/', getCart);
router.delete('/clear', clearCart);
router.put('/:id', updateCartItem);
router.delete('/:id', removeCartItem);

module.exports = router;
