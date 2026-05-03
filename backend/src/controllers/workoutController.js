const { pool } = require('../config/db');

exports.getWorkouts = async (req, res) => {
  try {
    const { location, category } = req.query;
    const conditions = [];
    const params = [];

    if (location && location !== 'all') {
      conditions.push('(w.location_type = ? OR w.location_type = ?)');
      params.push(location.toString().toLowerCase(), 'anywhere');
    }

    if (category && category !== 'all') {
      conditions.push('w.category = ?');
      params.push(category.toString().toLowerCase());
    }

    let query = `
      SELECT
        w.id,
        w.title,
        w.difficulty,
        w.location_type,
        w.category,
        w.description,
        w.duration_minutes,
        w.created_at,
        COUNT(we.exercise_id) AS exercise_count
      FROM workouts w
      LEFT JOIN workout_exercises we ON we.workout_id = w.id
    `;

    if (conditions.length > 0) {
      query += ` WHERE ${conditions.join(' AND ')}`;
    }

    query += `
      GROUP BY
        w.id,
        w.title,
        w.difficulty,
        w.location_type,
        w.category,
        w.description,
        w.duration_minutes,
        w.created_at
      ORDER BY w.category ASC, w.created_at DESC, w.title ASC
    `;

    const [rows] = await pool.execute(query, params);
    return res.status(200).json({ success: true, data: rows });
  } catch (error) {
    console.error('Get workouts error:', error);
    return res.status(500).json({
      success: false,
      message: 'Error fetching workouts',
    });
  }
};
