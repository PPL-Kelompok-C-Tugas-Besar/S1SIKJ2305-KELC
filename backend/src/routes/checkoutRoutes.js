const express = require('express');
const router = express.Router();
const { getCheckoutSummary, placeOrder, getUserOrders } = require('../controllers/checkoutController');
const { verifyToken } = require('../middleware/authMiddleware');

// Semua route checkout butuh token
router.use(verifyToken);

// GET /checkout/summary — ambil ringkasan checkout dari cart user
router.get('/summary', getCheckoutSummary);

// POST /checkout/order — simpan pesanan dan hapus dari cart
router.post('/order', placeOrder);

// GET /checkout/orders — ambil semua data order milik user
router.get('/orders', getUserOrders);

module.exports = router;
