const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const { verifyToken } = require('../middleware/authMiddleware');
const { pool } = require('../config/db');
const { getHistory, addHistory, getTodayStats } = require('../controllers/historyController');
const { updateWeight, getWeightHistory, updateWeeklyGoal } = require('../controllers/profileController');
const { calculateBMR, calculateTDEE } = require('../utils/calorieCalculator');
const { getAddresses, addAddress, updateAddress, deleteAddress } = require('../controllers/addressController');

// GET /users/stats/today
router.get('/stats/today', verifyToken, getTodayStats);

// POST /users/weekly-goal
router.post('/weekly-goal', verifyToken, updateWeeklyGoal);

// GET /users/profile
router.get('/profile', verifyToken, async (req, res) => {
  try {
    console.log('Getting profile for user ID:', req.user.id);

    const [rows] = await pool.execute(
      'SELECT id, full_name, email, weight, height, age, activity_level, diet_goal, daily_calorie_target, role, gender, fitness_goal, target_weight, onboarding_completed, weekly_workout_goal, date_created, photo_url FROM users WHERE id = ?',
      [req.user.id]
    );

    console.log('Raw user data from DB:', rows[0]);

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User tidak ditemukan' });
    }
    const user = rows[0];

    // Convert fitness_goal enum to array
    if (user.fitness_goal) {
      // Convert enum value to readable format
      user.goals = [user.fitness_goal.replace('_', ' ')];
    } else {
      user.goals = [];
    }

    console.log('Processed user data:', user);
    console.log('onboarding_completed value:', user.onboarding_completed);
    console.log('onboarding_completed type:', typeof user.onboarding_completed);

    return res.status(200).json({ success: true, data: user });
  } catch (err) {
    console.error('Get profile error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server: ' + err.message });
  }
});

// PUT /users/profile
router.put('/profile', verifyToken, async (req, res) => {
  try {
    const { gender, goals, currentWeight, targetWeight, height, age, activityLevel, dietGoal } = req.body;
    const userId = req.user.id;

    // Map new diet goals to legacy fitness_goal enum to prevent MySQL error
    let fitnessGoalsValue = null;
    if (dietGoal) {
      const goalMap = {
        'cutting': 'weight_loss',
        'maintenance': 'keep_fit',
        'bulking': 'muscle_gain'
      };
      fitnessGoalsValue = goalMap[dietGoal] || 'keep_fit';
    } else if (goals && goals.length > 0) {
      fitnessGoalsValue = goals[0].replace(' ', '_');
    }

    // Kalkulasi target kalori harian
    let dailyCalorieTarget = null;
    if (currentWeight && height && age && gender && activityLevel) {
      try {
        const bmr = calculateBMR(currentWeight, height, age, gender);
        const tdee = calculateTDEE(bmr, activityLevel);

        dailyCalorieTarget = tdee;
        if (dietGoal === 'cutting') {
          dailyCalorieTarget -= 500;
        } else if (dietGoal === 'bulking') {
          dailyCalorieTarget += 500;
        }

        // SANITY CHECK: Pastikan kalori tidak berada di batas berbahaya (Starvation / Overfeeding ekstrem)
        const genderStr = gender ? gender.toLowerCase() : '';
        const minAllowed = (genderStr === 'female' || genderStr === 'wanita' || genderStr === 'perempuan') ? 1200 : 1500;

        if (dailyCalorieTarget < minAllowed) {
          console.log(`[User Route] Target kalori ${dailyCalorieTarget} dibatasi ke minimum aman: ${minAllowed} kcal.`);
          dailyCalorieTarget = minAllowed;
        } else if (dailyCalorieTarget > 5000) {
          console.log(`[User Route] Target kalori ${dailyCalorieTarget} dibatasi ke maksimum: 5000 kcal.`);
          dailyCalorieTarget = 5000;
        }
      } catch (calcErr) {
        console.error('Error calculating calorie target:', calcErr.message);
      }
    }

    const [result] = await pool.execute(
      `UPDATE users
       SET gender = ?, fitness_goal = ?, weight = ?, target_weight = ?, height = ?, age = ?, activity_level = ?, diet_goal = ?, daily_calorie_target = ?, onboarding_completed = 1
       WHERE id = ?`,
      [
        gender || null,
        fitnessGoalsValue,
        currentWeight || null,
        targetWeight || null,
        height || null,
        age || null,
        activityLevel || null,
        dietGoal || null,
        dailyCalorieTarget,
        userId
      ]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'User tidak ditemukan' });
    }

    // Get updated user data
    const [rows] = await pool.execute(
      'SELECT id, full_name, email, weight, height, age, activity_level, diet_goal, daily_calorie_target, role, gender, fitness_goal, target_weight, onboarding_completed, date_created FROM users WHERE id = ?',
      [userId]
    );

    const updatedUser = rows[0];
    if (updatedUser.fitness_goal) {
      updatedUser.goals = [updatedUser.fitness_goal.replace('_', ' ')];
    } else {
      updatedUser.goals = [];
    }

    return res.status(200).json({
      success: true,
      data: updatedUser,
      message: 'Profil berhasil diperbarui'
    });
  } catch (err) {
    console.error('Update profile error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
});

// PUT /users/height
router.put('/height', verifyToken, async (req, res) => {
  try {
    const { height } = req.body;
    const userId = req.user.id;

    if (height === undefined || height === null) {
      return res.status(400).json({ success: false, message: 'Tinggi badan wajib diisi' });
    }

    const parsedHeight = parseFloat(height);
    if (isNaN(parsedHeight) || parsedHeight < 50 || parsedHeight > 250) {
      return res.status(400).json({
        success: false,
        message: 'Tinggi badan harus antara 50 - 250 cm'
      });
    }

    await pool.execute(
      'UPDATE users SET height = ? WHERE id = ?',
      [parsedHeight, userId]
    );

    return res.status(200).json({
      success: true,
      message: 'Tinggi badan berhasil diperbarui',
      data: { height: parsedHeight }
    });
  } catch (err) {
    console.error('Update height error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
});

// POST /users/weight
router.post('/weight', verifyToken, updateWeight);

// GET /users/weight/history
router.get('/weight/history', verifyToken, getWeightHistory);

// GET /users/history
router.get('/history', verifyToken, getHistory);

// POST /users/history
router.post('/history', verifyToken, addHistory);

// GET /users/addresses
router.get('/addresses', verifyToken, getAddresses);

// POST /users/addresses
router.post('/addresses', verifyToken, addAddress);

// PUT /users/addresses/:id
router.put('/addresses/:id', verifyToken, updateAddress);

// DELETE /users/addresses/:id
router.delete('/addresses/:id', verifyToken, deleteAddress);

// PUT /users/photo
router.put('/photo', verifyToken, async (req, res) => {
  const { photo_base64 } = req.body;

  if (!photo_base64) {
    return res.status(400).json({ success: false, message: 'Foto wajib diisi' });
  }

  const sizeInBytes = Buffer.byteLength(photo_base64, 'utf8');
  if (sizeInBytes > 2 * 1024 * 1024) {
    return res.status(400).json({ success: false, message: 'Ukuran foto maksimal 2MB' });
  }

  try {
    await pool.execute(
      'UPDATE users SET photo_url = ? WHERE id = ?',
      [photo_base64, req.user.id]
    );
    return res.status(200).json({ success: true, message: 'Foto profil berhasil diperbarui' });
  } catch (err) {
    console.error('Update photo error:', err);
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
      'SELECT password FROM users WHERE id = ?',
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
      'UPDATE users SET password = ? WHERE id = ?',
      [hashedPassword, req.user.id]
    );

    return res.status(200).json({ success: true, message: 'Password berhasil diubah' });
  } catch (err) {
    console.error('Change password error:', err);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
});

module.exports = router;