
const { pool } = require('../src/config/db');
require('dotenv').config();

async function findAdmin() {
  try {
    const [rows] = await pool.query('SELECT email, role FROM users');
    console.log('User list:');
    console.table(rows);
    process.exit(0);
  } catch (err) {
    console.error('DB Error:', err);
    process.exit(1);
  }
}

findAdmin();
