require('dotenv').config();
const { pool } = require('../src/config/db');

async function check() {
  try {
    const [tables] = await pool.query('SHOW TABLES');
    console.log('Tables in database:', tables.map(t => Object.values(t)[0]));
    
    try {
      const [columns] = await pool.query('DESCRIBE product_reviews');
      console.log('Columns in product_reviews:', columns.map(c => c.Field));
    } catch (e) {
      console.log('product_reviews table describe failed:', e.message);
    }
    
    process.exit(0);
  } catch (err) {
    console.error('Error checking reviews table:', err);
    process.exit(1);
  }
}

check();
