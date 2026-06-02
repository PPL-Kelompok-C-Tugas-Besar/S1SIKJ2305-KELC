const { pool } = require('../config/db');

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
    try {
        const userId = req.user.id;
        
        // Buat string tanggal hari ini (YYYY-MM-DD) dari Node.js
        const now = new Date();
        const todayStr = now.getFullYear() + '-' + 
                         String(now.getMonth() + 1).padStart(2, '0') + '-' + 
                         String(now.getDate()).padStart(2, '0');

        // 1. Ambil total kalori dan menit untuk HARI INI saja
        const [[{ today_calories, today_minutes }]] = await pool.execute(
            'SELECT SUM(calories_burned) AS today_calories, SUM(duration_minutes) AS today_minutes FROM workout_history WHERE user_id = ? AND DATE(date) = ?',
            [userId, todayStr]
        );

        // 2. Ambil Goal Mingguan dari user
        const [[{ weekly_workout_goal }]] = await pool.execute(
            'SELECT weekly_workout_goal FROM users WHERE id = ?',
            [userId]
        );

        // 3. Hitung Progress Mingguan (Hari apa saja yang sudah workout minggu ini)
        // Senin adalah hari ke-1 (WEEKDAY returns 0 for Mon, 6 for Sun)
        const [weeklyRows] = await pool.execute(
            `SELECT DISTINCT WEEKDAY(date) as day_index 
             FROM workout_history 
             WHERE user_id = ? 
             AND date >= DATE_SUB(CURDATE(), INTERVAL (WEEKDAY(CURDATE())) DAY)`,
            [userId]
        );
        // day_index dari SQL: 0=Mon, 1=Tue, ..., 6=Sun
        // Kita ubah ke 1=Mon, ..., 7=Sun untuk konsistensi jika perlu, tapi 0-indexed juga ok.
        const completedDays = weeklyRows.map(row => row.day_index + 1);

        // 4. Hitung Streak
        const [rows] = await pool.execute(
            "SELECT DISTINCT DATE_FORMAT(date, '%Y-%m-%d') as workout_date FROM workout_history WHERE user_id = ? ORDER BY workout_date DESC",
            [userId]
        );

        let streak = 0;
        let diffSinceLastWorkout = 999; 

        if (rows.length > 0) {
            const lastWorkoutDateStr = rows[0].workout_date;
            
            const getDiffInDays = (d1, d2) => {
                const date1 = new Date(d1 + 'T00:00:00Z');
                const date2 = new Date(d2 + 'T00:00:00Z');
                return Math.round((date1 - date2) / (1000 * 60 * 60 * 24));
            };

            diffSinceLastWorkout = getDiffInDays(todayStr, lastWorkoutDateStr);

            if (diffSinceLastWorkout <= 1) {
                streak = 1;
                let currentDateStr = lastWorkoutDateStr;

                for (let i = 1; i < rows.length; i++) {
                    const prevWorkoutDateStr = rows[i].workout_date;
                    const gap = getDiffInDays(currentDateStr, prevWorkoutDateStr);
                    
                    if (gap === 1) {
                        streak++;
                        currentDateStr = prevWorkoutDateStr;
                    } else {
                        break;
                    }
                }
            }
        }

        return res.status(200).json({
            success: true,
            data: {
                todayCalories: parseInt(today_calories) || 0,
                todayMinutes: parseInt(today_minutes) || 0,
                streak: streak,
                hasWorkedOutToday: diffSinceLastWorkout === 0,
                weeklyGoal: weekly_workout_goal || 3,
                completedDays: completedDays // List of day indices (1-7)
            }
        });
    } catch (err) {
        console.error('Get today stats error:', err);
        return res.status(500).json({ success: false, message: 'Terjadi kesalahan saat mengambil statistik hari ini' });
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

module.exports = { getHistory, addHistory, getTodayStats };
