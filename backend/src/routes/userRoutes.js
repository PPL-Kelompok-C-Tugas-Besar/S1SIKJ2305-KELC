const express = require('express');
const router = express.Router();
const { verifyToken } = require('../middleware/authMiddleware');
const { pool } = require('../config/db');
const { getHistory, addHistory } = require('../controllers/historyController');

// GET /users/profile
router.get('/profile', verifyToken, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT id, full_name, email, weight, role, date_created FROM USERS WHERE id = ?',
      [req.user.id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User tidak ditemukan' });
    }
    return res.status(200).json({ success: true, data: rows[0] });
  } catch (err) {
    console.error('Get profile error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
});

// GET /users/history
router.get('/history', verifyToken, getHistory);

// POST /users/history
router.post('/history', verifyToken, addHistory);

module.exports = router;