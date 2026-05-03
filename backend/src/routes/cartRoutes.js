const express = require('express');
const router = express.Router();
const { addToCart } = require('../controllers/cartController');
const { verifyToken } = require('../middleware/authMiddleware');

// POST /cart
router.post('/', verifyToken, addToCart);

module.exports = router;
