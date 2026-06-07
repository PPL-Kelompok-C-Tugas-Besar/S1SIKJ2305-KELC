const { pool } = require('../config/db');

const ensureSavedWorkoutsTable = async () => {
  await pool.execute(`
    CREATE TABLE IF NOT EXISTS saved_workouts (
      user_id VARCHAR(255) NOT NULL,
      workout_id VARCHAR(255) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (user_id, workout_id),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (workout_id) REFERENCES workouts(id) ON DELETE CASCADE
    )
  `);
};

exports.getWorkouts = async (req, res) => {
  try {
    const { location, category, fitness_goal } = req.query;
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

    if (fitness_goal && fitness_goal !== 'all') {
      conditions.push('w.fitness_goal = ?');
      params.push(fitness_goal.toString().toLowerCase());
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
        w.fitness_goal,
        w.calories_burned,
        w.created_at,
        COUNT(DISTINCT we.exercise_id) AS exercise_count,
        GROUP_CONCAT(
          DISTINCT e.equipment_required
          ORDER BY e.equipment_required
          SEPARATOR ', '
        ) AS equipment_summary
      FROM workouts w
      LEFT JOIN workout_exercises we ON we.workout_id = w.id
      LEFT JOIN exercises e ON e.id = we.exercise_id
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
        w.fitness_goal,
        w.calories_burned,
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

exports.getSavedWorkouts = async (req, res) => {
  try {
    await ensureSavedWorkoutsTable();

    const [rows] = await pool.execute(
      'SELECT workout_id FROM saved_workouts WHERE user_id = ? ORDER BY created_at DESC',
      [req.user.id]
    );

    return res.status(200).json({
      success: true,
      data: rows.map((row) => row.workout_id),
    });
  } catch (error) {
    console.error('Get saved workouts error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve saved workouts',
    });
  }
};

exports.saveWorkout = async (req, res) => {
  try {
    await ensureSavedWorkoutsTable();

    const { id } = req.params;
    await pool.execute(
      'INSERT IGNORE INTO saved_workouts (user_id, workout_id) VALUES (?, ?)',
      [req.user.id, id]
    );

    return res.status(200).json({
      success: true,
      message: 'Workout saved',
    });
  } catch (error) {
    console.error('Save workout error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to save workout',
    });
  }
};

exports.unsaveWorkout = async (req, res) => {
  try {
    await ensureSavedWorkoutsTable();

    const { id } = req.params;
    await pool.execute(
      'DELETE FROM saved_workouts WHERE user_id = ? AND workout_id = ?',
      [req.user.id, id]
    );

    return res.status(200).json({
      success: true,
      message: 'Workout removed from saved list',
    });
  } catch (error) {
    console.error('Unsave workout error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to remove saved workout',
    });
  }
};

exports.getWorkoutExercises = async (req, res) => {
  try {
    const { id } = req.params;
    const query = `
      SELECT e.id, e.name, e.instructions, e.base_calories_burn, we.reps_or_duration 
      FROM workout_exercises we 
      JOIN exercises e ON we.exercise_id = e.id 
      WHERE we.workout_id = ? 
      ORDER BY we.sequence_order
    `;
    const [results] = await pool.query(query, [id]);
    res.status(200).json({ success: true, data: results });
  } catch (error) {
    console.error('Get workout exercises error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to retrieve exercises',
      error: error.message 
    });
  }
};

