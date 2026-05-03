require('dotenv').config();
const { pool } = require('./src/config/db');

async function fixCartTable() {
  try {
    console.log('Altering defaultdb.carts user_id column...');
    await pool.execute('ALTER TABLE defaultdb.carts MODIFY user_id VARCHAR(255)');
    console.log('Successfully altered user_id column to VARCHAR(255)');
  } catch(e) {
    console.error('Error altering table:', e);
  } finally {
    process.exit(0);
  }
}

fixCartTable();
