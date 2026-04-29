const { pool } = require('../config/db');

// GET /users/history
const getHistory = async (req, res) => {
    try {
        const userId = req.user.id;
        const [rows] = await pool.execute(
            'SELECT * FROM workout_history WHERE user_id = ? ORDER BY date DESC',
            [userId]
        );
        return res.status(200).json({ success: true, data: rows });
    } catch (err) {
        console.error('Get history error:', err);
        return res.status(500).json({ success: false, message: 'Terjadi kesalahan saat mengambil riwayat' });
    }
};

// POST /users/history
const addHistory = async (req, res) => {
    try {
        const userId = req.user.id;
        const { workout_name, duration_minutes, calories_burned } = req.body;

        if (!workout_name || !duration_minutes || !calories_burned) {
            return res.status(400).json({ success: false, message: 'Nama latihan, durasi, dan kalori wajib diisi' });
        }

        const [result] = await pool.execute(
            'INSERT INTO workout_history (user_id, workout_name, duration_minutes, calories_burned) VALUES (?, ?, ?, ?)',
            [userId, workout_name, duration_minutes, calories_burned]
        );

        return res.status(201).json({ 
            success: true, 
            message: 'Riwayat latihan berhasil ditambahkan',
            data: {
                id: result.insertId,
                user_id: userId,
                workout_name,
                duration_minutes,
                calories_burned,
                date: new Date().toISOString()
            }
        });
    } catch (err) {
        console.error('Add history error:', err);
        return res.status(500).json({ success: false, message: 'Terjadi kesalahan saat menyimpan riwayat' });
    }
};

module.exports = { getHistory, addHistory };
