const { pool: db } = require('../config/db');

exports.getWorkouts = async (req, res) => {
    try {
        const category = req.query.category || 'workout';
        const location = req.query.location; // e.g., 'home' or 'gym'

        // Base query
        let query = 'SELECT id, title, difficulty, location_type, duration_minutes FROM workouts WHERE category = ?';
        let queryParams = [category];

        // If the app specifies a location, filter by it OR 'anywhere'
        if (location) {
            query += ' AND (location_type = ? OR location_type = "anywhere")';
            queryParams.push(location);
        }

        const [results] = await db.query(query, queryParams);
        
        res.status(200).json(results);
    } catch (error) {
        console.error("Database error:", error);
        res.status(500).json({ message: "Failed to retrieve workouts", error: error.message });
    }
};

exports.getWorkoutExercises = async (req, res) => {
    try {
        const { id } = req.params;
        const query = `
            SELECT e.id, e.name, e.instructions, we.reps_or_duration 
            FROM workout_exercises we 
            JOIN exercises e ON we.exercise_id = e.id 
            WHERE we.workout_id = ? 
            ORDER BY we.sequence_order
        `;
        const [results] = await db.query(query, [id]);
        res.status(200).json(results);
    } catch (error) {
        console.error("Database error:", error);
        res.status(500).json({ message: "Failed to retrieve exercises", error: error.message });
    }
};