const express = require('express');
const router  = express.Router();
const { getCheckoutSummary } = require('../controllers/checkoutController');
const { verifyToken }        = require('../middleware/authMiddleware');

// Semua endpoint checkout butuh token login
router.use(verifyToken);

// GET /checkout/summary
// Ambil ringkasan cart untuk ditampilkan di halaman checkout
router.get('/summary', getCheckoutSummary);

module.exports = router;
