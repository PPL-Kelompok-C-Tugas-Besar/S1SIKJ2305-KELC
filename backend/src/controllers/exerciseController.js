const db = require('../config/db');

exports.getExercises = async (req, res) => {
  try {
    const { body_part, difficulty, location } = req.query;
    let query = 'SELECT * FROM exercises WHERE 1=1';
    const queryParams = [];

    if (body_part) {
      query += ' AND body_part = ?';
      queryParams.push(body_part);
    }
    if (difficulty) {
      query += ' AND difficulty = ?';
      queryParams.push(difficulty);
    }
    if (location) {
      query += ' AND location = ?';
      queryParams.push(location);
    }

    const [rows] = await db.execute(query, queryParams);
    res.status(200).json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error fetching exercises' });
  }
};