const { pool } = require('../config/db');
const { recalculateUserCalorieTarget } = require('../utils/calorieCalculator');

const PAGE_LIMIT = 10; // jumlah item per halaman

// GET /users/history?limit=10&offset=0
const getHistory = async (req, res) => {
    try {
        // [PKCTB-241] Autentikasi: Mendapatkan identitas user yang sedang login dari JWT token
        const userId = req.user.id;

        // Ambil limit & page dari query params, dengan nilai default
        const limit = Math.min(parseInt(req.query.limit) || PAGE_LIMIT, 50); // maks 50
        const page  = Math.max(parseInt(req.query.page) || 1, 1);
        const offset = (page - 1) * limit;

        // Hitung total data milik user ini, beserta total kalori dan menit
        const [[{ total, total_calories, total_minutes }]] = await pool.execute(
            'SELECT COUNT(*) AS total, SUM(calories_burned) AS total_calories, SUM(duration_minutes) AS total_minutes FROM workout_history WHERE user_id = ?',
            [userId]
        );

        // [PKCTB-241 & PKCTB-242] Filter & Sorting: 
        // 1. Mengembalikan data HANYA milik user_id tersebut (Filter)
        // 2. Diurutkan dari yang terbaru menggunakan ORDER BY date DESC (Sorting)
        const [rows] = await pool.query(
            'SELECT * FROM workout_history WHERE user_id = ? ORDER BY date DESC LIMIT ? OFFSET ?',
            [userId, limit, offset]
        );

        const totalPages = Math.ceil(total / limit);

        return res.status(200).json({
            success: true,
            data: rows,
            pagination: {
                totalData: total,
                totalCalories: parseInt(total_calories) || 0,
                totalMinutes: parseInt(total_minutes) || 0,
                totalPages: totalPages,
                currentPage: page,
                limit: limit,
                hasMore: page < totalPages
            },
        });
    } catch (err) {
        console.error('Get history error:', err);
        return res.status(500).json({ success: false, message: 'Terjadi kesalahan saat mengambil riwayat' });
    }
};

// GET /users/stats/today
const getTodayStats = async (req, res) => {
    let connection;
    try {
        const userId = req.user.id;
        connection = await pool.getConnection();
        await connection.query("SET time_zone = '+07:00'");

        // Jalankan SEMUA kueri sekaligus secara paralel
        const [
            [[user]], 
            [[stats]], 
            [weeklyRows], 
            [streakRows],
            [[{ db_today }]]
        ] = await Promise.all([
            connection.execute('SELECT daily_calorie_target, weekly_workout_goal FROM users WHERE id = ?', [userId]),
            connection.execute(
                `SELECT 
                    COALESCE(SUM(calories_burned), 0) AS today_calories,
                    COALESCE(SUM(duration_minutes), 0) AS today_minutes
                 FROM workout_history 
                 WHERE user_id = ? AND date >= CURDATE()`,
                [userId]
            ),
            connection.execute(
                `SELECT WEEKDAY(date) as day_index, SUM(calories_burned) as day_sum
                 FROM workout_history 
                 WHERE user_id = ? 
                 AND date >= DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY)
                 GROUP BY day_index`,
                [userId]
            ),
            connection.execute(
                `SELECT DISTINCT DATE_FORMAT(date, '%Y-%m-%d') as workout_date 
                 FROM workout_history WHERE user_id = ? 
                 ORDER BY workout_date DESC LIMIT 30`,
                [userId]
            ),
            connection.execute('SELECT CAST(CURDATE() AS CHAR) as db_today')
        ]);

        const targetCals = user?.daily_calorie_target || 0;
        const currentTodayCals = Math.round(parseFloat(stats?.today_calories) || 0);
        
        // Hitung completedDays & streak
        const completedDays = weeklyRows
            .filter(row => Math.round(row.day_sum) >= targetCals)
            .map(row => row.day_index + 1);

        let streak = 0;
        if (streakRows.length > 0) {
            const todayStr = db_today;
            const lastWorkoutDateStr = streakRows[0].workout_date;
            const getDiff = (d1, d2) => Math.round(Math.abs(new Date(d1 + 'T00:00:00Z') - new Date(d2 + 'T00:00:00Z')) / 86400000);
            const diff = getDiff(todayStr, lastWorkoutDateStr);

            if (diff <= 1) {
                streak = 1;
                let current = lastWorkoutDateStr;
                for (let i = 1; i < streakRows.length; i++) {
                    if (getDiff(current, streakRows[i].workout_date) === 1) {
                        streak++;
                        current = streakRows[i].workout_date;
                    } else break;
                }
            }
        }

        return res.status(200).json({
            success: true,
            data: {
                todayCalories: currentTodayCals,
                todayMinutes: Math.round(parseFloat(stats?.today_minutes) || 0),
                dailyCalorieTarget: targetCals, // Kita kirim ini agar frontend tidak perlu tanya profil lagi
                streak: streak,
                hasWorkedOutToday: (targetCals > 0 && currentTodayCals >= targetCals),
                weeklyGoal: user?.weekly_workout_goal || 3,
                completedDays: completedDays
            }
        });
    } catch (err) {
        console.error('Get today stats error:', err);
        return res.status(500).json({ success: false, message: 'Server error' });
    } finally {
        if (connection) connection.release();
    }
};

// POST /users/history
const addHistory = async (req, res) => {
    let connection;
    try {
        const userId = req.user.id;
        const { workout_name, duration_minutes } = req.body;
        let calories_burned = req.body.calories_burned;

        if (!workout_name || duration_minutes === undefined || duration_minutes === null || duration_minutes === '') {
            return res.status(400).json({ success: false, message: 'Nama latihan dan durasi wajib diisi' });
        }

        connection = await pool.getConnection();

        if (!calories_burned) {
            // Hitung otomatis kalori
            // 1. Dapatkan berat badan user
            const [[user]] = await connection.execute('SELECT weight FROM users WHERE id = ?', [userId]);
            const weightKg = user?.weight || 70; // default 70kg jika tidak ada

            // 2. Dapatkan met_value dari tabel exercises berdasarkan nama yang mirip
            const [exercises] = await connection.execute(
                'SELECT met_value FROM exercises WHERE LOWER(name) LIKE LOWER(?) ORDER BY met_value DESC LIMIT 1',
                [`%${workout_name}%`]
            );
            
            let metValue = 5.0; // default met value jika tidak ditemukan
            if (exercises.length > 0) {
                metValue = parseFloat(exercises[0].met_value);
            }

            // 3. Hitung kalori
            // Kalori = Durasi (menit) × (MET × 3.5 × Berat Badan kg) / 200
            calories_burned = Math.round(duration_minutes * (metValue * 3.5 * weightKg) / 200);
        }

        const [result] = await connection.execute(
            'INSERT INTO workout_history (user_id, workout_name, duration_minutes, calories_burned) VALUES (?, ?, ?, ?)',
            [userId, workout_name, duration_minutes, calories_burned]
        );

        // Kalkulasi ulang target kalori
        await recalculateUserCalorieTarget(userId, connection);

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
    } finally {
        if (connection) connection.release();
    }
};

module.exports = { getHistory, addHistory, getTodayStats };
