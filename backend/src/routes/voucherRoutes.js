const express = require('express');
const router = express.Router();
const { validateVoucher } = require('../controllers/marketplaceController');
const { verifyToken } = require('../middleware/authMiddleware');

// POST /vouchers/validate
router.post('/validate', verifyToken, validateVoucher);

module.exports = router;
