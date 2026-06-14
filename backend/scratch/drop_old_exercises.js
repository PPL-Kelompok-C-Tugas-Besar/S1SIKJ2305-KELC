require('dotenv').config();
const { pool } = require('../src/config/db');

async function dropOld() {
  try {
    await pool.query('DROP TABLE IF EXISTS workout_exercises');
    await pool.query('DROP TABLE IF EXISTS exercises');
    console.log('Old exercises tables dropped successfully.');
    process.exit(0);
  } catch (err) {
    console.error('Error dropping tables:', err);
    process.exit(1);
  }
}
dropOld();
