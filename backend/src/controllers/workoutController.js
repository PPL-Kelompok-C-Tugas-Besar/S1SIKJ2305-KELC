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

const normalizeValue = (value = '') => value.toString().trim().toLowerCase();

const normalizeGoal = (value = '') => {
  const normalized = normalizeValue(value).replace(/\s+/g, '_');
  const goalMap = {
    cutting: 'weight_loss',
    bulking: 'muscle_gain',
    maintenance: 'keep_fit',
  };

  return goalMap[normalized] || normalized;
};

const difficultyRank = {
  beginner: 1,
  intermediate: 2,
  advanced: 3,
};

const getWorkoutBaseQuery = () => `
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

const getWorkoutGroupBy = () => `
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
`;

const buildReason = (signals) => {
  if (signals.goal) return `Matches your ${signals.goal.replace('_', ' ')} goal`;
  if (signals.saved) return 'Similar to workouts you saved';
  if (signals.location) return `Fits your ${signals.location} workout preference`;
  if (signals.difficulty) return `Good ${signals.difficulty} difficulty based on your history`;
  if (signals.fresh) return 'Adds variety to your recent routine';
  return 'A balanced pick for your next session';
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

    let query = getWorkoutBaseQuery();

    if (conditions.length > 0) {
      query += ` WHERE ${conditions.join(' AND ')}`;
    }

    query += `${getWorkoutGroupBy()}
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

exports.getRecommendedWorkouts = async (req, res) => {
  try {
    await ensureSavedWorkoutsTable();

    const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 10, 1), 20);
    const userId = req.user.id;

    const [[user]] = await pool.execute(
      `SELECT id, fitness_goal, activity_level, diet_goal, weekly_workout_goal
       FROM users
       WHERE id = ?`,
      [userId]
    );

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const [workouts] = await pool.execute(
      `${getWorkoutBaseQuery()}
       WHERE w.category = ?
       ${getWorkoutGroupBy()}`,
      ['workout']
    );

    const [savedRows] = await pool.execute(
      'SELECT workout_id FROM saved_workouts WHERE user_id = ?',
      [userId]
    );

    const [historyRows] = await pool.execute(
      `SELECT workout_name, duration_minutes, calories_burned, date
       FROM workout_history
       WHERE user_id = ?
       ORDER BY date DESC
       LIMIT 30`,
      [userId]
    );

    const savedIds = new Set(savedRows.map((row) => row.workout_id));
    const workoutsByTitle = new Map(
      workouts.map((workout) => [normalizeValue(workout.title), workout])
    );

    const completedTitles = new Set();
    const recentTitles = new Set();
    const locationCounts = {};
    const difficultyCounts = {};

    historyRows.forEach((history, index) => {
      const title = normalizeValue(history.workout_name);
      if (!title) return;

      completedTitles.add(title);
      if (index < 5) recentTitles.add(title);

      const matchedWorkout = workoutsByTitle.get(title);
      if (!matchedWorkout) return;

      const location = normalizeValue(matchedWorkout.location_type);
      const difficulty = normalizeValue(matchedWorkout.difficulty);

      if (location) locationCounts[location] = (locationCounts[location] || 0) + 1;
      if (difficulty) difficultyCounts[difficulty] = (difficultyCounts[difficulty] || 0) + 1;
    });

    savedRows.forEach((saved) => {
      const workout = workouts.find((item) => item.id === saved.workout_id);
      if (!workout) return;

      const location = normalizeValue(workout.location_type);
      const difficulty = normalizeValue(workout.difficulty);

      if (location) locationCounts[location] = (locationCounts[location] || 0) + 2;
      if (difficulty) difficultyCounts[difficulty] = (difficultyCounts[difficulty] || 0) + 2;
    });

    const preferredLocation = Object.entries(locationCounts)
      .sort((a, b) => b[1] - a[1])[0]?.[0];
    const preferredDifficulty = Object.entries(difficultyCounts)
      .sort((a, b) => b[1] - a[1])[0]?.[0];
    const userGoal = normalizeGoal(user.fitness_goal || user.diet_goal);

    const scoredWorkouts = workouts.map((workout) => {
      let score = 0;
      const signals = {};
      const workoutGoal = normalizeGoal(workout.fitness_goal);
      const workoutLocation = normalizeValue(workout.location_type);
      const workoutDifficulty = normalizeValue(workout.difficulty);
      const workoutTitle = normalizeValue(workout.title);

      if (workoutGoal && userGoal && workoutGoal === userGoal) {
        score += 35;
        signals.goal = workoutGoal;
      }

      if (savedIds.has(workout.id)) {
        score += 28;
        signals.saved = true;
      }

      if (
        preferredLocation &&
        (workoutLocation === preferredLocation || workoutLocation === 'anywhere')
      ) {
        score += 18;
        signals.location = preferredLocation;
      }

      if (preferredDifficulty && workoutDifficulty === preferredDifficulty) {
        score += 15;
        signals.difficulty = preferredDifficulty;
      }

      if (!completedTitles.has(workoutTitle)) {
        score += 12;
        signals.fresh = true;
      }

      if (recentTitles.has(workoutTitle)) score -= 24;

      const preferredRank = difficultyRank[preferredDifficulty] || 0;
      const workoutRank = difficultyRank[workoutDifficulty] || 0;
      if (preferredRank > 0 && workoutRank - preferredRank > 1) score -= 10;

      if (workout.category === 'workout') score += 5;

      return {
        ...workout,
        recommendation_score: score,
        recommendation_reason: buildReason(signals),
      };
    });

    scoredWorkouts.sort((a, b) => {
      if (b.recommendation_score !== a.recommendation_score) {
        return b.recommendation_score - a.recommendation_score;
      }
      return a.title.localeCompare(b.title);
    });

    return res.status(200).json({
      success: true,
      data: scoredWorkouts.slice(0, limit),
    });
  } catch (error) {
    console.error('Get recommended workouts error:', error);
    return res.status(500).json({
      success: false,
      message: 'Error fetching recommended workouts',
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

