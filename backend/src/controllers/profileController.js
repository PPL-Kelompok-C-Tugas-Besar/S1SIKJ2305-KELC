const { pool } = require('../config/db');

// POST /users/weight
const updateWeight = async (req, res) => {
    try {
        const userId = req.user.id;
        const { weight, recorded_date } = req.body;

        if (!weight) {
            return res.status(400).json({ success: false, message: 'Berat badan wajib diisi' });
        }

        // Tanggal default adalah waktu sekarang jika tidak dikirim dari klien
        const dateToLog = recorded_date ? new Date(recorded_date) : new Date();

        // 1. Catat ke tabel user_weight_logs
        await pool.execute(
            'INSERT INTO user_weight_logs (user_id, weight, recorded_date) VALUES (?, ?, ?)',
            [userId, weight, dateToLog]
        );

        // 2. Update kolom weight di profil utama (tabel USERS)
        await pool.execute(
            'UPDATE USERS SET weight = ? WHERE id = ?',
            [weight, userId]
        );

        return res.status(200).json({ 
            success: true, 
            message: 'Berat badan berhasil diperbarui',
            data: {
                weight: weight,
                recorded_date: dateToLog.toISOString()
            }
        });
    } catch (err) {
        console.error('Update weight error:', err);
        return res.status(500).json({ success: false, message: 'Terjadi kesalahan saat memperbarui berat badan' });
    }
};

module.exports = { updateWeight };
