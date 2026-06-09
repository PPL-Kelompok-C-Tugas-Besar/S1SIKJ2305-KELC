const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const { verifyToken } = require('../middleware/authMiddleware');
const { pool } = require('../config/db');
const { getHistory, addHistory, getTodayStats } = require('../controllers/historyController');
const { updateWeight, getWeightHistory, updateWeeklyGoal } = require('../controllers/profileController');

// GET /users/stats/today
router.get('/stats/today', verifyToken, getTodayStats);

// POST /users/weekly-goal
router.post('/weekly-goal', verifyToken, updateWeeklyGoal);

// GET /users/profile
router.get('/profile', verifyToken, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT id, full_name, email, weight, role, gender, fitness_goal, target_weight, onboarding_completed, weekly_workout_goal, date_created FROM users WHERE id = ?',
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

// PUT /users/password
router.put('/password', verifyToken, async (req, res) => {
  const { old_password, new_password, confirm_password } = req.body;

  if (!old_password || !new_password || !confirm_password) {
    return res.status(400).json({ success: false, message: 'Semua field wajib diisi' });
  }
  if (new_password.length < 6) {
    return res.status(400).json({ success: false, message: 'Password baru minimal 6 karakter' });
  }
  if (new_password !== confirm_password) {
    return res.status(400).json({ success: false, message: 'Konfirmasi password tidak cocok' });
  }

  try {
    const [rows] = await pool.execute(
      'SELECT password FROM USERS WHERE id = ?',
      [req.user.id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User tidak ditemukan' });
    }

    const isMatch = await bcrypt.compare(old_password, rows[0].password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Password lama tidak sesuai' });
    }

    const hashedPassword = await bcrypt.hash(new_password, 10);
    await pool.execute(
      'UPDATE USERS SET password = ? WHERE id = ?',
      [hashedPassword, req.user.id]
    );

    return res.status(200).json({ success: true, message: 'Password berhasil diubah' });
  } catch (err) {
    console.error('Change password error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
});

module.exports = router;